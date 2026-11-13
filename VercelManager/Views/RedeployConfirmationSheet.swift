import SwiftUI

struct RedeployConfirmationSheet: View {
    let deployment: VercelDeployment
    let accountLabel: String
    let isSubmitting: Bool
    let onConfirm: () -> Void
    let onCancel: () -> Void

    var body: some View {
        NavigationStack {
            List {
                Section {
                    LabeledContent("Account", value: accountLabel)
                    LabeledContent("Projekt", value: deployment.name ?? "Unbekannt")
                    LabeledContent("Quell-Deployment", value: deployment.uid)
                    LabeledContent("Zielumgebung", value: deployment.environmentLabel)
                    if let version = deployment.versionSummary {
                        LabeledContent("Version", value: version)
                    }
                } header: {
                    Text("Redeploy-Zusammenfassung")
                } footer: {
                    Text(
                        "Es wird genau ein neues Deployment ausgelöst. Einstellungen und Umgebung werden vom Quell-Deployment übernommen (offizielles Vercel-Redeploy)."
                    )
                }

                if deployment.isProductionTarget {
                    Section {
                        Label {
                            Text(
                                "Production-Redeploy kann den Live-Traffic beeinflussen. Bitte nur auf einem Testprojekt oder nach bewusster Freigabe ausführen."
                            )
                        } icon: {
                            Image(systemName: "exclamationmark.triangle.fill")
                                .foregroundStyle(.orange)
                        }
                    }
                }
            }
            .navigationTitle("Redeploy bestätigen")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Abbrechen", action: onCancel)
                        .disabled(isSubmitting)
                }
                ToolbarItem(placement: .confirmationAction) {
                    if isSubmitting {
                        ProgressView()
                    } else {
                        Button("Redeploy starten", action: onConfirm)
                            .fontWeight(.semibold)
                    }
                }
            }
            .interactiveDismissDisabled(isSubmitting)
        }
        .presentationDetents([.medium, .large])
    }
}
