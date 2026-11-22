import Foundation
import UIKit

struct FoodItem: Codable, Identifiable {
    var id = UUID()
    var name: String
    var grams: Double
    var kcal: Double
    var proteinG: Double
    enum CodingKeys: String, CodingKey { case name, grams, kcal, proteinG = "protein_g" }
}

enum AIError: LocalizedError {
    case notConfigured, failed(String)
    var errorDescription: String? {
        switch self {
        case .notConfigured: return "Set the AI proxy URL in Nutrition → settings."
        case .failed(let m): return m
        }
    }
}

enum AIService {
    static func analyze(text: String, image: UIImage?) async throws -> [FoodItem] {
        let urlString = UserDefaults.standard.string(forKey: "proxyURL") ?? ""
        guard let url = URL(string: urlString), !urlString.isEmpty else { throw AIError.notConfigured }
        var payload: [String: String] = [:]
        if !text.isEmpty { payload["text"] = text }
        if let image, let data = resized(image, maxSide: 1024).jpegData(compressionQuality: 0.6) { payload["imageBase64"] = data.base64EncodedString() }
        guard !payload.isEmpty else { throw AIError.failed("Add a description or a photo.") }
        var req = URLRequest(url: url)
        req.httpMethod = "POST"
        req.setValue("application/json", forHTTPHeaderField: "content-type")
        if let secret = UserDefaults.standard.string(forKey: "proxySecret"), !secret.isEmpty { req.setValue(secret, forHTTPHeaderField: "x-app-secret") }
        req.httpBody = try JSONSerialization.data(withJSONObject: payload)
        req.timeoutInterval = 90
        var data = Data(), code = 0
        for attempt in 0..<4 {                      // Gemini sometimes answers 503 "high demand": retry a few times
            let (d, resp) = try await URLSession.shared.data(for: req)
            data = d; code = (resp as? HTTPURLResponse)?.statusCode ?? 0
            let body = String(data: d, encoding: .utf8) ?? ""
            let busy = code == 429 || code == 503 || (code == 502 && (body.contains("503") || body.contains("429") || body.contains("UNAVAILABLE")))
            if code == 200 || !busy || attempt == 3 { break }
            try await Task.sleep(nanoseconds: UInt64(2 + attempt * 2) * 1_000_000_000)
        }
        guard code == 200 else {
            let body = String(data: data, encoding: .utf8) ?? ""
            if code == 429 || code == 503 || body.contains("UNAVAILABLE") || body.contains("high demand") {
                throw AIError.failed("The AI model is busy right now. Try again in a minute.")
            }
            throw AIError.failed("AI service error \(code): \(body.prefix(200))")
        }
        struct Reply: Decodable { let items: [FoodItem] }
        return try JSONDecoder().decode(Reply.self, from: data).items
    }

    private static func resized(_ img: UIImage, maxSide: CGFloat) -> UIImage {
        let longest = max(img.size.width, img.size.height)
        guard longest > maxSide else { return img }
        let k = maxSide / longest
        let size = CGSize(width: img.size.width * k, height: img.size.height * k)
        return UIGraphicsImageRenderer(size: size).image { _ in img.draw(in: CGRect(origin: .zero, size: size)) }
    }
}
