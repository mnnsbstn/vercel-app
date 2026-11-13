import SwiftUI

struct ProjectsView: View {
    @EnvironmentObject private var model: AppModel
    @State private var search = ""

    private var filtered: [VercelProject] {
        guard !search.isEmpty else { return model.projects }
        return model.projects.filter {
            $0.name.localizedCaseInsensitiveContains(search) ||
            ($0.framework?.localizedCaseInsensitiveContains(search) ?? false)
        }
    }

    var body: some View {
        NavigationStack {
            List {
                if let error = model.errorMessage {
                    ErrorNotice(message: error)
                        .listRowBackground(Color.clear)
                        .listRowSeparator(.hidden)
                }

                if filtered.isEmpty && !model.isRefreshing {
                    EmptyNotice(
                        title: search.isEmpty ? "Keine Projekte" : "Keine Treffer",
                        message: search.isEmpty
                            ? "In diesem Account wurden keine Projekte gefunden."
                            : "Versuche einen anderen Suchbegriff.",
                        icon: "magnifyingglass"
                    )
                    .listRowBackground(Color.clear)
                    .listRowSeparator(.hidden)
                }

                ForEach(filtered) { project in
                    NavigationLink {
                        ProjectDetailView(project: project)
                    } label: {
                        ProjectRow(project: project)
                    }
                    .listRowInsets(.init(top: 5, leading: 16, bottom: 5, trailing: 16))
                    .listRowBackground(Color.clear)
                    .listRowSeparator(.hidden)
                }
            }
            .listStyle(.plain)
            .scrollContentBackground(.hidden)
            .background(AppStyle.background)
            .navigationTitle("Projekte")
            .searchable(text: $search, prompt: "Projekt oder Framework")
            .refreshable { await model.refresh() }
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    if model.isRefreshing { ProgressView().tint(.white) }
                }
            }
        }
    }
}
