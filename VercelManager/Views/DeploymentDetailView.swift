import SwiftUI
#if canImport(UIKit)
import UIKit
#endif

struct DeploymentDetailView: View {
    @Environment(\.openURL) private var openURL
    @EnvironmentObject private var model: AppModel
    let deployment: VercelDeployment

    @State private var logEvents: [VercelDeploymentEvent] = []
    @State private var logsLoading = false
    @State private var logsError: String?
    @State private var copyConfirmation = false

    private func loadLogs() async {
        logsLoading = true
        logsError = nil
        defer { logsLoading = false }

        do {
            logEvents = try await model.deploymentEvents(for: deployment)
        } catch {
            logsError = NetworkUserMessage.text(for: error)
        }
    }

    private var combinedLogText: String {
        logEvents
            .sorted { ($0.createdAt ?? .distantPast) < ($1.createdAt ?? .distantPast) }
            .map(\.message)
            .joined(separator: "\n")
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                VStack(alignment: .leading, spacing: 14) {
                    Text(deployment.name ?? "Deployment")
                        .font(.system(size: 30, weight: .bold))
                    StatusBadge(state: deployment.currentState)

                    infoRow("Umgebung", deployment.environmentLabel)
                    infoRow("Deployment-ID", deployment.uid)

                    if let created = deployment.created {
                        infoRow(
                            "Erstellt",
                            created.vercelDate.formatted(date: .abbreviated, time: .shortened)
                        )
                    }
                    if let hostname = deployment.url {
                        infoRow("Hostname", hostname)
                    }
                }
                .vercelCard()

                if let url = deployment.deploymentURL {
                    Button {
                        openURL(url)
                    } label: {
                        Label("Deployment öffnen", systemImage: "arrow.up.right")
                            .font(.headline)
                            .frame(maxWidth: .infinity)
                            .padding(16)
                    }
                    .buttonStyle(.plain)
                    .foregroundStyle(.black)
                    .background(.white, in: RoundedRectangle(cornerRadius: 14))
                    .accessibilityLabel("Deployment-URL im Browser öffnen")
                }

                VStack(alignment: .leading, spacing: 12) {
                    HStack {
                        Text("Build-Logs")
                            .font(.title3.weight(.semibold))
                        Spacer()
                        if logsLoading {
                            ProgressView().tint(.white)
                        } else if !logEvents.isEmpty {
                            Button {
                                copyLogs()
                            } label: {
                                Label("Kopieren", systemImage: "doc.on.doc")
                                    .font(.subheadline.weight(.medium))
                            }
                            .buttonStyle(.bordered)
                            .tint(.white)
                            .accessibilityLabel("Gesamte Build-Logs kopieren")
                        }
                    }

                    if let logsError {
                        ErrorNotice(message: logsError)
                    }

                    if logEvents.isEmpty && !logsLoading && logsError == nil {
                        EmptyNotice(
                            title: "Keine Log-Einträge",
                            message: "Vercel hat für dieses Deployment keine Build-Events zurückgegeben (z. B. abgelaufene Retention).",
                            icon: "text.alignleft"
                        )
                    } else if !logEvents.isEmpty {
                        LazyVStack(alignment: .leading, spacing: 8) {
                            ForEach(logEvents) { event in
                                DeploymentLogLine(event: event)
                            }
                        }
                        .vercelCard()
                    }
                }

                Text("Redeploy und Rollback sind bewusst noch nicht verfügbar und erfordern eine separate Freigabe.")
                    .font(.footnote)
                    .foregroundStyle(AppStyle.secondaryText)
                    .fixedSize(horizontal: false, vertical: true)
            }
            .padding(18)
        }
        .background(AppStyle.background)
        .navigationTitle("Deployment")
        .navigationBarTitleDisplayMode(.inline)
        .task(id: deployment.uid) { await loadLogs() }
        .refreshable { await loadLogs() }
        .alert("In Zwischenablage kopiert", isPresented: $copyConfirmation) {
            Button("OK", role: .cancel) {}
        }
    }

    private func copyLogs() {
        #if canImport(UIKit)
        UIPasteboard.general.string = combinedLogText
        copyConfirmation = true
        #endif
    }

    private func infoRow(_ title: String, _ value: String) -> some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(title.uppercased())
                .font(.caption2.weight(.semibold))
                .tracking(1)
                .foregroundStyle(AppStyle.secondaryText)
            Text(value)
                .font(.subheadline)
                .textSelection(.enabled)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}

private struct DeploymentLogLine: View {
    let event: VercelDeploymentEvent

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            HStack(spacing: 8) {
                Text(event.typeLabel)
                    .font(.caption2.weight(.semibold))
                    .padding(.horizontal, 8)
                    .padding(.vertical, 4)
                    .background(Color.white.opacity(0.08), in: Capsule())
                if let createdAt = event.createdAt {
                    Text(createdAt, style: .time)
                        .font(.caption2)
                        .foregroundStyle(AppStyle.secondaryText)
                }
                Spacer(minLength: 0)
            }
            Text(event.message)
                .font(.system(.footnote, design: .monospaced))
                .foregroundStyle(.white)
                .textSelection(.enabled)
                .frame(maxWidth: .infinity, alignment: .leading)
        }
        .padding(.vertical, 4)
        .accessibilityElement(children: .combine)
        .accessibilityLabel("\(event.typeLabel): \(event.message)")
    }
}
