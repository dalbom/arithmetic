import SwiftUI

struct DigitSliderView: View {
    let label: LocalizedStringKey
    @Binding var value: Int
    let range: ClosedRange<Int>
    let freeLimit: Int?

    init(_ label: LocalizedStringKey, value: Binding<Int>, range: ClosedRange<Int> = 1...8, freeLimit: Int? = nil) {
        self.label = label
        self._value = value
        self.range = range
        self.freeLimit = freeLimit
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            HStack {
                Text(label)
                    .font(.subheadline)
                Spacer()
                Text("\(value)")
                    .font(.subheadline.monospacedDigit().bold())
                    .foregroundStyle(.blue)
            }

            HStack(spacing: 4) {
                ForEach(range.lowerBound...range.upperBound, id: \.self) { num in
                    Button {
                        value = num
                    } label: {
                        Text("\(num)")
                            .font(.callout.bold())
                            .frame(width: 32, height: 32)
                            .background(
                                value == num
                                    ? Color.accentColor
                                    : (isLocked(num) ? Color(.systemGray6) : Color(.systemGray5))
                            )
                            .foregroundStyle(value == num ? .white : (isLocked(num) ? .secondary : .primary))
                            .clipShape(Circle())
                            .overlay(alignment: .topTrailing) {
                                if isLocked(num) {
                                    Image(systemName: "lock.fill")
                                        .font(.system(size: 7))
                                        .foregroundStyle(.secondary)
                                        .offset(x: 2, y: -2)
                                }
                            }
                    }
                    .buttonStyle(.borderless)
                }
            }
        }
    }

    private func isLocked(_ num: Int) -> Bool {
        guard let freeLimit else { return false }
        return num > freeLimit
    }
}
