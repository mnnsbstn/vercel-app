import SwiftUI

@main
struct VercelManagerApp: App {
    @StateObject private var model = AppModel()

    var body: some Scene {
        WindowGroup {
            RootView()
                .environmentObject(model)
                .preferredColorScheme(.dark)
                .task {
                    await model.bootstrap()
                }
        }
    }
}

private struct RootView: View {
    @EnvironmentObject private var model: AppModel
    @Environment(\.accessibilityReduceMotion) private var reduceMotion

    var body: some View {
        Group {
            if model.isAuthenticated {
                MainTabView()
            } else {
                ConnectView()
            }
        }
        .animation(reduceMotion ? nil : .easeInOut(duration: 0.2), value: model.isAuthenticated)
    }
}

private struct MainTabView: View {
    var body: some View {
        TabView {
            DashboardView()
                .tabItem {
                    Label("Übersicht", systemImage: "square.grid.2x2")
                }

            ProjectsView()
                .tabItem {
                    Label("Projekte", systemImage: "square.stack")
                }

            SettingsView()
                .tabItem {
                    Label("Einstellungen", systemImage: "gearshape")
                }
        }
        .tint(.white)
    }
}
