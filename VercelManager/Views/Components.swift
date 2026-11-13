import SwiftUI

enum AppStyle {
    static let background = Color.black
    static let surface = Color(white: 0.095)
    static let border = Color.white.opacity(0.14)
    static let secondaryText = Color(white: 0.63)
}

extension View {
    func vercelCard() -> some View {
        self
            .padding(16)
            .frame(maxWidth: .infinity, alignment: .leading)
            .background(AppStyle.surface, in: RoundedRectangle(cornerRadius: 18))
            .overlay {
                RoundedRectangle(cornerRadius: 18)
                    .strokeBorder(AppStyle.border, lineWidth: 1)
            }
    }
}

struct StatusBadge: View {
    let state: String

    private var color: Color {
        switch state.uppercased() {
        case "READY": return .green
        case "ERROR", "CANCELED": return .red
        case "BUILDING", "INITIALIZING", "QUEUED": return .orange
        case "BLOCKED": return .purple
        default: return .gray
        }
    }

    private var label: String {
        switch state.uppercased() {
        case "READY": return "Bereit"
        case "ERROR": return "Fehler"
        case "CANCELED": return "Abgebrochen"
        case "BUILDING": return "Build läuft"
        case "QUEUED": return "In Warteschlange"
        case "INITIALIZING": return "Initialisierung"
        case "BLOCKED": return "Blockiert"
        default: return state.capitalized
        }
    }

    var body: some View {
        HStack(spacing: 6) {
            Circle().fill(color).frame(width: 7, height: 7)
            Text(label).font(.caption.weight(.medium))
        }
        .foregroundStyle(color)
        .padding(.horizontal, 10)
        .padding(.vertical, 7)
        .background(color.opacity(0.12), in: Capsule())
        .accessibilityElement(children: .combine)
    }
}

struct MetricCard: View {
    let title: String
    let value: String
    let symbol: String

    var body: some View {
        VStack(alignment: .leading, spacing: 18) {
            Image(systemName: symbol)
                .font(.title3)
                .foregroundStyle(AppStyle.secondaryText)
            Text(value)
                .font(.system(size: 32, weight: .semibold, design: .rounded))
                .contentTransition(.numericText())
            Text(title)
                .font(.footnote)
                .foregroundStyle(AppStyle.secondaryText)
        }
        .vercelCard()
    }
}

struct DeploymentRow: View {
    let deployment: VercelDeployment

    var body: some View {
        VStack(alignment: .leading, spacing: 9) {
            HStack(alignment: .top) {
                VStack(alignment: .leading, spacing: 5) {
                    Text(deployment.name ?? "Deployment")
                        .font(.headline)
                        .foregroundStyle(.white)
                        .lineLimit(1)
                    HStack(spacing: 6) {
                        Text(deployment.environmentLabel)
                        if let branch = deployment.branchLabel {
                            Text("·")
                            Text(branch)
                                .lineLimit(1)
                        }
                    }
                    .font(.caption)
                    .foregroundStyle(AppStyle.secondaryText)
                }
                Spacer(minLength: 8)
                StatusBadge(state: deployment.currentState)
            }

            HStack(spacing: 6) {
                Image(systemName: "clock")
                if let created = deployment.created {
                    Text(created.vercelDate, style: .relative)
                } else {
                    Text("Zeit unbekannt")
                }
            }
            .font(.caption)
            .foregroundStyle(AppStyle.secondaryText)
        }
        .vercelCard()
    }
}

struct ProjectRow: View {
    let project: VercelProject

    var body: some View {
        HStack(alignment: .center, spacing: 14) {
            Image(systemName: "square.stack.3d.up")
                .font(.title3)
                .frame(width: 42, height: 42)
                .background(Color.white.opacity(0.08), in: RoundedRectangle(cornerRadius: 12))

            VStack(alignment: .leading, spacing: 5) {
                Text(project.name)
                    .font(.headline)
                    .foregroundStyle(.white)
                    .lineLimit(1)
                Text(project.framework ?? "Kein Framework angegeben")
                    .font(.caption)
                    .foregroundStyle(AppStyle.secondaryText)
                if let updated = project.updatedAt {
                    Text("Aktualisiert \(updated.vercelDate, style: .relative)")
                        .font(.caption2)
                        .foregroundStyle(AppStyle.secondaryText.opacity(0.85))
                }
            }
            Spacer(minLength: 4)
            Image(systemName: "chevron.right")
                .font(.caption.weight(.bold))
                .foregroundStyle(AppStyle.secondaryText)
        }
        .vercelCard()
    }
}

struct ErrorNotice: View {
    let message: String

    var body: some View {
        Label(message, systemImage: "exclamationmark.triangle")
            .font(.subheadline)
            .foregroundStyle(.orange)
            .frame(maxWidth: .infinity, alignment: .leading)
            .vercelCard()
    }
}

struct EmptyNotice: View {
    let title: String
    let message: String
    let icon: String

    var body: some View {
        VStack(spacing: 12) {
            Image(systemName: icon)
                .font(.largeTitle)
                .foregroundStyle(AppStyle.secondaryText)
            Text(title).font(.headline)
            Text(message)
                .font(.subheadline)
                .foregroundStyle(AppStyle.secondaryText)
                .multilineTextAlignment(.center)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 44)
    }
}
