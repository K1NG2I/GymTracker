import SwiftUI

// MARK: - SettingsView
// App settings: units, rest timer defaults, data management.
// Can be added as a 6th tab or as a gear icon in the tab bar.
struct SettingsView: View {
    @AppStorage("defaultRestDuration") private var defaultRestDuration: Int = 90
    @AppStorage("useKilograms") private var useKilograms: Bool = true
    @AppStorage("hapticEnabled") private var hapticEnabled: Bool = true

    @State private var showingResetAlert = false

    var body: some View {
        NavigationStack {
            Form {
                Section("Rest Timer") {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Default Rest Duration")

                        Stepper("\(defaultRestDuration) seconds",
                                value: $defaultRestDuration,
                                in: 30...300,
                                step: 15)
                    }
                }

                Section("Units") {
                    Toggle("Use Kilograms", isOn: $useKilograms)

                    if !useKilograms {
                        HStack {
                            Text("Weight displayed in")
                            Spacer()
                            Text("Pounds (lbs)")
                                .foregroundStyle(.secondary)
                        }
                    }
                }

                Section("Feedback") {
                    Toggle("Haptic Feedback", isOn: $hapticEnabled)
                }

                Section("Data") {
                    Button(role: .destructive) {
                        showingResetAlert = true
                    } label: {
                        Label("Reset All Data", systemImage: "trash")
                    }

                    Button {
                        exportData()
                    } label: {
                        Label("Export Data (CSV)", systemImage: "square.and.arrow.up")
                    }
                }

                Section("About") {
                    HStack {
                        Text("Version")
                        Spacer()
                        Text("1.0.0")
                            .foregroundStyle(.secondary)
                    }

                    HStack {
                        Text("Built with")
                        Spacer()
                        Text("Swift & SwiftData")
                            .foregroundStyle(.secondary)
                    }
                }
            }
            .navigationTitle("Settings")
            .alert("Reset All Data?", isPresented: $showingResetAlert) {
                Button("Cancel", role: .cancel) {}
                Button("Reset", role: .destructive) {
                    resetAllData()
                }
            } message: {
                Text("This will delete all exercises, templates, workouts, and sets. This cannot be undone.")
            }
        }
    }

    // MARK: - Data management

    private func resetAllData() {
        // This would need access to the ModelContainer
        // For now, clear UserDefaults and show a message
        UserDefaults.standard.removeObject(forKey: "seedDataLoaded")
        // In a real app, you'd delete all SwiftData objects here
    }

    private func exportData() {
        // Placeholder: generate CSV and show share sheet
        // In a real app, fetch all sessions/sets and format as CSV
    }
}

#Preview {
    SettingsView()
}
