import SwiftUI

struct DeploymentDetailView: View {
    @Environment(\.openURL) private var openURL
    let deployment: VercelDeployment

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
                }

                Text("Weitere Aktionen wie Redeploy, Build-Logs und Rollback folgen in einer späteren Version. Diese Version ändert keine produktiven Deployments.")
                    .font(.footnote)
                    .foregroundStyle(AppStyle.secondaryText)
                    .fixedSize(horizontal: false, vertical: true)
            }
            .padding(18)
        }
        .background(AppStyle.background)
        .navigationTitle("Deployment")
        .navigationBarTitleDisplayMode(.inline)
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
