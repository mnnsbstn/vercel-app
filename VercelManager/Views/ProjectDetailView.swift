import SwiftUI

struct ProjectDetailView: View {
    @EnvironmentObject private var model: AppModel
    let project: VercelProject

    @State private var deployments: [VercelDeployment] = []
    @State private var hasMoreDeployments = false
    @State private var loadedDeploymentPages = 0
    @State private var loading = false
    @State private var errorMessage: String?

    private func load() async {
        loading = true
        errorMessage = nil
        defer { loading = false }

        do {
            let page = try await model.deployments(for: project)
            deployments = page.deployments
            hasMoreDeployments = page.hasMorePages
            loadedDeploymentPages = page.loadedPages
        } catch {
            errorMessage = NetworkUserMessage.text(for: error)
        }
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 22) {
                VStack(alignment: .leading, spacing: 10) {
                    Text(project.name)
                        .font(.system(size: 30, weight: .bold))
                    Label(project.framework ?? "Framework nicht hinterlegt", systemImage: "curlybraces")
                        .font(.subheadline)
                        .foregroundStyle(AppStyle.secondaryText)
                    if let updated = project.updatedAt {
                        Label {
                            Text("Aktualisiert \(updated.vercelDate, style: .relative)")
                        } icon: {
                            Image(systemName: "clock")
                        }
                        .font(.caption)
                        .foregroundStyle(AppStyle.secondaryText)
                    }
                }
                .vercelCard()

                HStack {
                    Text("Deployments")
                        .font(.title3.weight(.semibold))
                    Spacer()
                    if loading { ProgressView().tint(.white) }
                }

                if let errorMessage {
                    ErrorNotice(message: errorMessage)
                }

                if !deployments.isEmpty {
                    Text(projectDeploymentsSummary)
                        .font(.caption)
                        .foregroundStyle(AppStyle.secondaryText)
                }

                if hasMoreDeployments {
                    Label(
                        "Weitere Deployments existieren (App-Limit: \(DeploymentsPagination.maxProjectDeployments)).",
                        systemImage: "info.circle"
                    )
                    .font(.caption)
                    .foregroundStyle(.orange)
                }

                if deployments.isEmpty && !loading {
                    EmptyNotice(
                        title: "Keine Deployments gefunden",
                        message: "Die letzten Deployments dieses Projekts erscheinen hier.",
                        icon: "shippingbox"
                    )
                } else {
                    LazyVStack(spacing: 10) {
                        ForEach(deployments) { deployment in
                            NavigationLink {
                                DeploymentDetailView(deployment: deployment)
                            } label: {
                                DeploymentRow(deployment: deployment)
                            }
                            .buttonStyle(.plain)
                        }
                    }
                }
            }
            .padding(18)
        }
        .background(AppStyle.background)
        .navigationBarTitleDisplayMode(.inline)
        .task(id: model.scopeID) { await load() }
        .refreshable { await load() }
    }

    private var projectDeploymentsSummary: String {
        var parts = ["\(deployments.count) Deployment\(deployments.count == 1 ? "" : "s")"]
        if loadedDeploymentPages > 1 {
            parts.append("\(loadedDeploymentPages) API-Seiten")
        }
        return parts.joined(separator: " · ")
    }
}
