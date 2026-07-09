import SwiftUI

struct SettingsTab: View {
    @AppStorage("notificationsEnabled") private var notificationsEnabled = false
    @AppStorage("dailyChallengeHour") private var dailyChallengeHour = 9
    @AppStorage("dailyChallengeMinute") private var dailyChallengeMinute = 0

    @State private var showResetConfirm = false
    @State private var showPermissionDeniedAlert = false

    private var store = SessionStore.shared

    private var challengeTime: Binding<Date> {
        Binding(
            get: {
                var comps = DateComponents()
                comps.hour = dailyChallengeHour
                comps.minute = dailyChallengeMinute
                return Calendar.current.date(from: comps) ?? Date()
            },
            set: { newDate in
                let comps = Calendar.current.dateComponents([.hour, .minute], from: newDate)
                dailyChallengeHour = comps.hour ?? 9
                dailyChallengeMinute = comps.minute ?? 0
                if notificationsEnabled {
                    NotificationService.shared.scheduleDailyChallenge(at: comps)
                }
            }
        )
    }

    var body: some View {
        Form {
            Section("Daily Challenge") {
                Toggle("Notifications", isOn: $notificationsEnabled)
                    .onChange(of: notificationsEnabled) { _, enabled in
                        if enabled {
                            NotificationService.shared.requestPermission { granted in
                                if granted {
                                    let comps = DateComponents(hour: dailyChallengeHour, minute: dailyChallengeMinute)
                                    NotificationService.shared.scheduleDailyChallenge(at: comps)
                                } else {
                                    notificationsEnabled = false
                                    showPermissionDeniedAlert = true
                                }
                            }
                        } else {
                            NotificationService.shared.cancelDailyChallenge()
                        }
                    }

                DatePicker("Pick a time for a challenge", selection: challengeTime, displayedComponents: .hourAndMinute)
                    .disabled(!notificationsEnabled)

                if notificationsEnabled {
                    Text("You'll get a daily reminder at your chosen time to come back and beat your score.")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }

            Section {
                Button("Reset All Stats", role: .destructive) {
                    showResetConfirm = true
                }
            }
        }
        .navigationTitle("Settings")
        .confirmationDialog(
            "This will permanently delete all recorded games. Continue?",
            isPresented: $showResetConfirm,
            titleVisibility: .visible
        ) {
            Button("Reset All Stats", role: .destructive) {
                store.resetAll()
            }
            Button("Cancel", role: .cancel) {}
        }
        .alert("Notifications Disabled", isPresented: $showPermissionDeniedAlert) {
            Button("Open Settings") {
                if let url = URL(string: UIApplication.openSettingsURLString) {
                    UIApplication.shared.open(url)
                }
            }
            Button("Cancel", role: .cancel) {}
        } message: {
            Text("Notifications are turned off for TapFrenzy. To get your daily challenge reminder, enable notifications for this app in iOS Settings.")
        }
    }
}
