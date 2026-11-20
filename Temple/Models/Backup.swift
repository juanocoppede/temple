import Foundation
import SwiftData

/// Full-data JSON backup. Runs once per day (the first time the app is opened that day) and on demand.
struct BackupFile: Codable {
    struct Ex: Codable { var name, muscleGroup, equipment: String; var weightKg: Double; var targetSets, targetReps: Int; var isTimed: Bool }
    struct Blk: Codable { var order: Int; var isCircuit: Bool; var circuitName: String?; var exerciseNames: [String] }
    struct Pl: Codable { var name: String; var blocks: [Blk] }
    struct St: Codable { var exerciseName: String; var weightKg: Double; var reps, setNumber: Int; var circuitName: String?; var date: Date }
    struct Se: Codable { var date: Date; var planName: String?; var sets: [St] }
    struct Me: Codable { var date: Date; var slot, name: String; var grams, kcal, proteinG: Double }
    var app = "Temple", version = 1
    var exportedAt: Date
    var targets: [Double]            // [kcal, protein]
    var exercises: [Ex], plans: [Pl], sessions: [Se], looseSets: [St], meals: [Me]
}

enum Backup {
    static let folderKey = "backupFolderBookmark", lastKey = "backupLastDate", keep = 14

    static func build(_ ctx: ModelContext) -> Data? {
        func all<T: PersistentModel>(_ t: T.Type) -> [T] { (try? ctx.fetch(FetchDescriptor<T>())) ?? [] }
        func st(_ s: SetLog) -> BackupFile.St { .init(exerciseName: s.exerciseName, weightKg: s.weightKg, reps: s.reps, setNumber: s.setNumber, circuitName: s.circuitName, date: s.date) }
        let sessions = all(WorkoutSession.self)
        let inSession = Set(sessions.flatMap { $0.sets.map(\.persistentModelID) })
        let t = all(Targets.self).first
        let f = BackupFile(
            exportedAt: .now, targets: [t?.kcal ?? 2400, t?.proteinG ?? 150],
            exercises: all(Exercise.self).map { .init(name: $0.name, muscleGroup: $0.muscleGroup, equipment: $0.equipment, weightKg: $0.weightKg, targetSets: $0.targetSets, targetReps: $0.targetReps, isTimed: $0.isTimed) },
            plans: all(Plan.self).map { p in .init(name: p.name, blocks: p.blocks.sorted { $0.order < $1.order }.map { .init(order: $0.order, isCircuit: $0.isCircuit, circuitName: $0.circuitName, exerciseNames: $0.exerciseNames) }) },
            sessions: sessions.map { s in .init(date: s.date, planName: s.planName, sets: s.sets.map(st)) },
            looseSets: all(SetLog.self).filter { !inSession.contains($0.persistentModelID) }.map(st),
            meals: all(MealEntry.self).map { .init(date: $0.date, slot: $0.slotRaw, name: $0.name, grams: $0.grams, kcal: $0.kcal, proteinG: $0.proteinG) })
        let enc = JSONEncoder(); enc.dateEncodingStrategy = .iso8601; enc.outputFormatting = [.prettyPrinted, .sortedKeys]
        return try? enc.encode(f)
    }

    /// Chosen folder (e.g. iCloud Drive) or, failing that, the app's own Documents/Backups (visible in the Files app).
    static func withDestination(_ body: (URL) -> Bool) -> Bool {
        if let data = UserDefaults.standard.data(forKey: folderKey) {
            var stale = false
            if let url = try? URL(resolvingBookmarkData: data, bookmarkDataIsStale: &stale), url.startAccessingSecurityScopedResource() {
                defer { url.stopAccessingSecurityScopedResource() }
                if body(url) { return true }
            }
        }
        guard let docs = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first else { return false }
        let dir = docs.appendingPathComponent("Backups", isDirectory: true)
        try? FileManager.default.createDirectory(at: dir, withIntermediateDirectories: true)
        return body(dir)
    }

    @discardableResult static func run(_ ctx: ModelContext) -> Bool {
        guard let data = build(ctx) else { return false }
        let fmt = DateFormatter(); fmt.dateFormat = "yyyy-MM-dd"; fmt.locale = Locale(identifier: "en_US_POSIX")
        let name = "Temple-backup-\(fmt.string(from: .now)).json"
        let ok = withDestination { dir in
            do {
                try data.write(to: dir.appendingPathComponent(name), options: .atomic)
                let files = ((try? FileManager.default.contentsOfDirectory(at: dir, includingPropertiesForKeys: nil)) ?? [])
                    .filter { $0.lastPathComponent.hasPrefix("Temple-backup-") }.sorted { $0.lastPathComponent > $1.lastPathComponent }
                for old in files.dropFirst(keep) { try? FileManager.default.removeItem(at: old) }
                return true
            } catch { return false }
        }
        if ok { UserDefaults.standard.set(Date(), forKey: lastKey) }
        return ok
    }

    static func runDailyIfNeeded(_ ctx: ModelContext) {
        if let last = UserDefaults.standard.object(forKey: lastKey) as? Date, Calendar.current.isDateInToday(last) { return }
        run(ctx)
    }

    static func setFolder(_ url: URL) {
        guard url.startAccessingSecurityScopedResource() else { return }
        defer { url.stopAccessingSecurityScopedResource() }
        if let b = try? url.bookmarkData() { UserDefaults.standard.set(b, forKey: folderKey) }
    }
}
