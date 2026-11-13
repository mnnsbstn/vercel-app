import SwiftUI

struct DashboardView: View {
    @EnvironmentObject private var model: AppModel

    private var readyCount: Int {
        model.recentDeployments.filter { $0.currentState == "READY" }.count
    }

    private var problemCount: Int {
        model.recentDeployments.filter {
            $0.currentState == "ERROR" || $0.currentState == "CANCELED"
        }.count
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 23) {
                    VStack(alignment: .leading, spacing: 6) {
                        Text(model.accountLabel.uppercased())
                            .font(.caption.weight(.semibold))
                            .tracking(1.8)
                            .foregroundStyle(AppStyle.secondaryText)
                        Text("Alles im Blick.")
                            .font(.system(size: 32, weight: .bold))
                    }

                    LazyVGrid(columns: [
                        GridItem(.flexible(), spacing: 12),
                        GridItem(.flexible(), spacing: 12)
                    ], spacing: 12) {
                        MetricCard(title: "Projekte", value: "\(model.projects.count)", symbol: "square.stack")
                        MetricCard(title: "Letzte Deployments", value: "\(model.recentDeployments.count)", symbol: "arrow.triangle.2.circlepath")
                        MetricCard(title: "Davon bereit", value: "\(readyCount)", symbol: "checkmark.circle")
                        MetricCard(title: "Davon problematisch", value: "\(problemCount)", symbol: "exclamationmark.triangle")
                    }

                    if let error = model.errorMessage {
                        ErrorNotice(message: error)
                    }

                    if let summary = model.deploymentsLoadSummary {
                        Text(summary)
                            .font(.caption)
                            .foregroundStyle(AppStyle.secondaryText)
                    }

                    if model.deploymentsHasMorePages {
                        Label(
                            "Nicht alle Account-Deployments geladen (max. \(DeploymentsPagination.maxAccountDeployments)).",
                            systemImage: "info.circle"
                        )
                        .font(.caption)
                        .foregroundStyle(.orange)
                    }

                    HStack {
                        Text("Aktuelle Deployments")
                            .font(.title3.weight(.semibold))
                        Spacer()
                        if model.isRefreshing {
                            ProgressView().tint(.white)
                        }
                    }

                    if model.recentDeployments.isEmpty && !model.isRefreshing {
                        EmptyNotice(
                            title: "Keine Deployments",
                            message: "Ziehe nach unten, um die Daten neu zu laden.",
                            icon: "square.stack.3d.up.slash"
                        )
                    } else {
                        LazyVStack(spacing: 11) {
                            ForEach(model.recentDeployments) { deployment in
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
            .navigationTitle("Übersicht")
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        Task { await model.refresh() }
                    } label: {
                        Image(systemName: "arrow.clockwise")
                    }
                    .disabled(model.isRefreshing)
                    .accessibilityLabel("Aktualisieren")
                }
            }
            .refreshable { await model.refresh() }
        }
    }
}
