import SwiftUI

struct MonthGrid: View {
    @Binding var month: Date
    let marked: Set<Date>            // start-of-day dates to highlight
    var onSelect: ((Date) -> Void)? = nil

    private var cal: Calendar { var c = Calendar.current; c.firstWeekday = 2; return c }   // week starts Monday
    private var first: Date { cal.date(from: cal.dateComponents([.year, .month], from: month)) ?? month }
    private var cells: [Date?] {
        let range = cal.range(of: .day, in: .month, for: first) ?? 1..<31
        let lead = (cal.component(.weekday, from: first) - cal.firstWeekday + 7) % 7
        var out: [Date?] = Array<Date?>(repeating: nil, count: lead)
        for d in range { out.append(cal.date(byAdding: .day, value: d - 1, to: first)) }
        return out
    }
    private var title: String { first.formatted(.dateTime.month(.wide).year()) }

    var body: some View {
        VStack(spacing: 12) {
            HStack {
                Text(title).font(.system(size: 17, weight: .semibold))
                Spacer()
                Button { shift(-1) } label: { Image(systemName: "chevron.left").frame(width: 44, height: 44) }
                Button { shift(1) } label: { Image(systemName: "chevron.right").frame(width: 44, height: 44) }
            }.foregroundStyle(Color.yolk)
            HStack(spacing: 0) {
                ForEach(["M", "T", "W", "T", "F", "S", "S"].indices, id: \.self) { i in
                    Text(["M", "T", "W", "T", "F", "S", "S"][i]).font(.system(size: 12, weight: .medium)).foregroundStyle(Color.textSecondary).frame(maxWidth: .infinity)
                }
            }
            LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 0), count: 7), spacing: 6) {
                ForEach(cells.indices, id: \.self) { i in
                    if let d = cells[i] {
                        let isMarked = marked.contains(cal.startOfDay(for: d))
                        let isToday = cal.isDateInToday(d)
                        Button { onSelect?(d) } label: {
                            Text("\(cal.component(.day, from: d))").font(.system(size: 15, weight: isMarked ? .semibold : .regular)).monospacedDigit()
                                .foregroundStyle(isMarked ? Color.yolkInk : Color.textPrimary)
                                .frame(width: 36, height: 36)
                                .background(isMarked ? Color.yolk : Color.clear, in: Circle())
                                .overlay(Circle().stroke(Color.yolk, lineWidth: isToday && !isMarked ? 1.5 : 0))
                        }.buttonStyle(.plain).frame(maxWidth: .infinity)
                    } else { Color.clear.frame(height: 36) }
                }
            }
        }
        .contentShape(Rectangle())
        .simultaneousGesture(DragGesture(minimumDistance: 30).onEnded { v in
            guard abs(v.translation.width) > 50, abs(v.translation.width) > abs(v.translation.height) * 1.5 else { return }
            withAnimation(.easeInOut(duration: 0.2)) { shift(v.translation.width < 0 ? 1 : -1) }
        })
    }
    private func shift(_ n: Int) { month = cal.date(byAdding: .month, value: n, to: first) ?? month }
}
