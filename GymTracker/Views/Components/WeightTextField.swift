import SwiftUI

// MARK: - WeightTextField
// A numeric text field for entering weight or reps.
// Shows the unit label (kg or reps) next to the input.
struct WeightTextField: View {
    let label: String
    @Binding var value: Double
    var unit: String = "kg"
    var range: ClosedRange<Double> = 0...999

    var body: some View {
        HStack(spacing: 4) {
            Text(label)
                .foregroundStyle(.secondary)
                .font(.caption)

            TextField(label, value: $value, format: .number.precision(.fractionLength(1)))
                .keyboardType(.decimalPad)
                .textFieldStyle(.roundedBorder)
                .frame(width: 70)
                .multilineTextAlignment(.center)

            Text(unit)
                .foregroundStyle(.secondary)
                .font(.caption)
        }
    }
}

// MARK: - RepsTextField
// Similar but for integer rep values.
struct RepsTextField: View {
    let label: String
    @Binding var value: Int
    var range: ClosedRange<Int> = 1...999

    var body: some View {
        HStack(spacing: 4) {
            Text(label)
                .foregroundStyle(.secondary)
                .font(.caption)

            TextField(label, value: $value, format: .number)
                .keyboardType(.numberPad)
                .textFieldStyle(.roundedBorder)
                .frame(width: 60)
                .multilineTextAlignment(.center)

            Text("reps")
                .foregroundStyle(.secondary)
                .font(.caption)
        }
    }
}

#Preview {
    VStack {
        WeightTextField(label: "Weight", value: .constant(60.0))
        RepsTextField(label: "Reps", value: .constant(10))
    }
    .padding()
}
