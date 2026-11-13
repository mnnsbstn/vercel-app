import SwiftUI

struct ConnectView: View {
    @EnvironmentObject private var model: AppModel
    @Environment(\.openURL) private var openURL
    @State private var token = ""

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 26) {
                Spacer(minLength: 54)

                Image(systemName: "triangle.fill")
                    .font(.system(size: 40, weight: .thin))
                    .rotationEffect(.degrees(180))
                    .frame(width: 62, height: 62)
                    .background(.white, in: RoundedRectangle(cornerRadius: 16))
                    .foregroundStyle(.black)

                VStack(alignment: .leading, spacing: 10) {
                    Text("Vercel Manager")
                        .font(.system(size: 38, weight: .bold))
                    Text("Deine Projekte und Deployments. Jederzeit im Blick.")
                        .font(.title3)
                        .foregroundStyle(AppStyle.secondaryText)
                }

                VStack(alignment: .leading, spacing: 15) {
                    Text("VERCEL VERBINDEN")
                        .font(.caption.weight(.semibold))
                        .tracking(2)
                        .foregroundStyle(AppStyle.secondaryText)

                    SecureField("Personal Access Token", text: $token)
                        .textContentType(.password)
                        .textInputAutocapitalization(.never)
                        .autocorrectionDisabled()
                        .padding(15)
                        .background(AppStyle.surface, in: RoundedRectangle(cornerRadius: 12))
                        .overlay {
                            RoundedRectangle(cornerRadius: 12)
                                .strokeBorder(AppStyle.border)
                        }
                        .accessibilityLabel("Vercel Personal Access Token")

                    if let error = model.errorMessage {
                        ErrorNotice(message: error)
                    }

                    Button {
                        Task { await model.signIn(with: token) }
                    } label: {
                        HStack {
                            Spacer()
                            if model.isConnecting {
                                ProgressView().tint(.black)
                            } else {
                                Text("Verbinden").fontWeight(.semibold)
                                Image(systemName: "arrow.right")
                            }
                            Spacer()
                        }
                        .padding(16)
                        .foregroundStyle(.black)
                        .background(.white, in: RoundedRectangle(cornerRadius: 12))
                    }
                    .buttonStyle(.plain)
                    .disabled(model.isConnecting || token.isEmpty)
                    .opacity(token.isEmpty ? 0.5 : 1)

                    Button("Token bei Vercel erstellen") {
                        guard let url = URL(string: "https://vercel.com/account/tokens") else {
                            return
                        }
                        openURL(url)
                    }
                    .font(.subheadline)
                    .foregroundStyle(.white)
                }
                .vercelCard()

                Label(
                    "Dein Token wird ausschließlich im iOS-Schlüsselbund gespeichert. Die App greift direkt auf die offizielle Vercel-API zu.",
                    systemImage: "lock.shield"
                )
                .font(.caption)
                .foregroundStyle(AppStyle.secondaryText)
                .fixedSize(horizontal: false, vertical: true)
            }
            .padding(22)
        }
        .background(AppStyle.background)
        .onChange(of: model.isAuthenticated) { _, connected in
            if connected { token = "" }
        }
    }
}
