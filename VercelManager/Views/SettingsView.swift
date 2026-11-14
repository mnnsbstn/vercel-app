import SwiftUI

struct SettingsView: View {
    @EnvironmentObject private var model: AppModel
    @State private var confirmSignOut = false

    private var appVersionLabel: String {
        let version = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "0.9.0"
        let build = Bundle.main.infoDictionary?["CFBundleVersion"] as? String ?? "1"
        return "Vercel Manager · Version \(version) (\(build))"
    }

    var body: some View {
        NavigationStack {
            Form {
                Section("VERBINDUNG") {
                    LabeledContent("Benutzer") {
                        Text(model.user?.username ?? model.user?.email ?? "Verbunden")
                    }

                    Picker("Vercel-Account", selection: Binding(
                        get: { model.scopeID },
                        set: { scope in
                            Task { await model.selectScope(scope) }
                        }
                    )) {
                        Text("Persönlicher Account").tag("")
                        ForEach(model.teams) { team in
                            Text(team.name).tag(team.id)
                        }
                    }
                    .pickerStyle(.navigationLink)
                    .disabled(model.isRefreshing || model.isConnecting)
                }

                Section("SICHERHEIT") {
                    Label("Token nur im iOS-Schlüsselbund", systemImage: "lock.shield")
                    Label("Direkte, verschlüsselte Vercel-API-Verbindung", systemImage: "checkmark.shield")
                }

                Section {
                    Button("Verbindung trennen", role: .destructive) {
                        confirmSignOut = true
                    }
                } footer: {
                    Text("Beim Trennen wird der gespeicherte Token vom Gerät gelöscht.")
                }

                Section {
                    Text(appVersionLabel)
                        .foregroundStyle(AppStyle.secondaryText)
                } footer: {
                    Text(
                        "Inoffizielle App von Drittanbietern — nicht von Vercel Inc. betrieben oder unterstützt. Vercel ist eine eingetragene Marke der jeweiligen Inhaber."
                    )
                }
            }
            .scrollContentBackground(.hidden)
            .background(AppStyle.background)
            .navigationTitle("Einstellungen")
            .confirmationDialog(
                "Von Vercel abmelden?",
                isPresented: $confirmSignOut,
                titleVisibility: .visible
            ) {
                Button("Abmelden", role: .destructive) {
                    model.signOut()
                }
            }
        }
    }
}
