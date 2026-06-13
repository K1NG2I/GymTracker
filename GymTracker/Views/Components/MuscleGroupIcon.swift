import SwiftUI

// MARK: - MuscleGroupIcon
// Displays the SF Symbol icon for a muscle group, with its color.
struct MuscleGroupIcon: View {
    let muscleGroup: MuscleGroup
    var size: CGFloat = 24

    var body: some View {
        Image(systemName: muscleGroup.iconName)
            .font(.system(size: size))
            .foregroundStyle(Color.muscleGroupColor(muscleGroup))
    }
}

#Preview {
    HStack {
        MuscleGroupIcon(muscleGroup: .chest)
        MuscleGroupIcon(muscleGroup: .legs)
        MuscleGroupIcon(muscleGroup: .back)
    }
}
