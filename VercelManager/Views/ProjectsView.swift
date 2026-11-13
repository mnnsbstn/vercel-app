import SwiftUI

struct ProjectsView: View {
    @EnvironmentObject private var model: AppModel
    @State private var search = ""

    private var filtered: [VercelProject] {
        ProjectSearchFilter.matching(model.projects, query: search)
    }

    private var isInitialLoading: Bool {
        model.isRefreshing && model.projects.isEmpty && model.errorMessage == nil
    }

    var body: some View {
        NavigationStack {
            List {
                if let summary = model.projectsLoadSummary {
                    Text(summary)
                        .font(.caption)
                        .foregroundStyle(AppStyle.secondaryText)
                        .listRowBackground(Color.clear)
                        .listRowSeparator(.hidden)
                        .accessibilityLabel(summary)
                }

                if model.projectsHasMorePages {
                    Label(
                        "Vercel liefert mehr Projekte als in dieser App geladen werden (max. \(ProjectsPagination.maxLoadedProjects)).",
                        systemImage: "info.circle"
                    )
                    .font(.caption)
                    .foregroundStyle(.orange)
                    .listRowBackground(Color.clear)
                    .listRowSeparator(.hidden)
                }

                if let error = model.errorMessage {
                    ErrorNotice(message: error)
                        .listRowBackground(Color.clear)
                        .listRowSeparator(.hidden)
                }

                if isInitialLoading {
                    HStack {
                        Spacer()
                        ProgressView("Projekte laden …")
                            .tint(.white)
                        Spacer()
                    }
                    .listRowBackground(Color.clear)
                    .listRowSeparator(.hidden)
                }

                if filtered.isEmpty && !isInitialLoading {
                    EmptyNotice(
                        title: search.isEmpty ? "Keine Projekte" : "Keine Treffer",
                        message: emptyMessage,
                        icon: "magnifyingglass"
                    )
                    .listRowBackground(Color.clear)
                    .listRowSeparator(.hidden)
                }

                if !filtered.isEmpty {
                    Section {
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
                    } header: {
                        Text(sectionHeader)
                    }
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
                    if model.isRefreshing && !model.projects.isEmpty {
                        ProgressView().tint(.white)
                    }
                }
            }
        }
    }

    private var sectionHeader: String {
        if search.isEmpty {
            return "\(filtered.count) Projekte"
        }
        return "\(filtered.count) Treffer · \(model.projects.count) geladen"
    }

    private var emptyMessage: String {
        if !search.isEmpty {
            return "Kein Projekt entspricht „\(search)“. Suche gilt nur über bereits geladene Einträge."
        }
        if model.isRefreshing {
            return "Projekte werden geladen …"
        }
        return "In diesem Account wurden keine Projekte gefunden."
    }
}
