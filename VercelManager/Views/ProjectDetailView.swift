import SwiftUI

struct ProjectDetailView: View {
    @EnvironmentObject private var model: AppModel
    let project: VercelProject

    @State private var deployments: [VercelDeployment] = []
    @State private var loading = false
    @State private var errorMessage: String?

    private func load() async {
        loading = true
        errorMessage = nil
        defer { loading = false }

        do {
            deployments = try await model.deployments(for: project)
        } catch {
            errorMessage = error.localizedDescription
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
}
