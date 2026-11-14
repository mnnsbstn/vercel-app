import SwiftUI

struct SettingsView: View {
    @EnvironmentObject private var model: AppModel
    @State private var confirmSignOut = false

    var body: some View {
        NavigationStack {
            Form {
                Section {
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
                    .accessibilityHint(
                        model.isRefreshing
                            ? "Account wird gerade aktualisiert"
                            : "Wechselt zwischen persönlichem Account und Teams"
                    )
                } header: {
                    Text("VERBINDUNG")
                } footer: {
                    if model.isRefreshing {
                        Text("Projekte und Deployments werden für den gewählten Account geladen.")
                    }
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
                    Text("Vercel Manager · Version 0.1")
                        .foregroundStyle(AppStyle.secondaryText)
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
