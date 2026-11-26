import SwiftUI

struct ClientAuthView: View {
    let auth: AuthService
    @State private var isSignUp = false
    @State private var email = ""
    @State private var password = ""
    @State private var name = ""

    var body: some View {
        NavigationStack {
            VStack(spacing: PTTheme.Spacing.xl) {
                VStack(spacing: PTTheme.Spacing.sm) {
                    Image(systemName: "heart.fill")
                        .font(.system(size: 56))
                        .foregroundStyle(PTTheme.Colors.accent)
                    Text("PTMode").font(PTTheme.Typography.largeTitle)
                    Text("Your personal training, in your pocket.")
                        .font(PTTheme.Typography.subheadline)
                        .foregroundStyle(PTTheme.Colors.textSecondary)
                }
                .padding(.top, 40)

                VStack(spacing: PTTheme.Spacing.md) {
                    if isSignUp {
                        TextField("Full name", text: $name).padding()
                            .background(PTTheme.Colors.surface)
                            .clipShape(RoundedRectangle(cornerRadius: PTTheme.Radius.md))
                    }
                    TextField("Email", text: $email).textInputAutocapitalization(.never).keyboardType(.emailAddress).padding()
                        .background(PTTheme.Colors.surface).clipShape(RoundedRectangle(cornerRadius: PTTheme.Radius.md))
                    SecureField("Password", text: $password).padding()
                        .background(PTTheme.Colors.surface).clipShape(RoundedRectangle(cornerRadius: PTTheme.Radius.md))
                    if let err = auth.errorMessage {
                        Text(err).font(PTTheme.Typography.caption).foregroundStyle(PTTheme.Colors.danger)
                    }
                    PTButton(isSignUp ? "Create Account" : "Sign In", isLoading: auth.isLoading) {
                        Task {
                            if isSignUp {
                                await auth.signUp(email: email, password: password, role: .client, fullName: name)
                            } else {
                                await auth.signIn(email: email, password: password)
                            }
                        }
                    }
                }
                .padding(.horizontal, PTTheme.Spacing.lg)

                Button(isSignUp ? "Already have an account? Sign in" : "New here? Create account") { isSignUp.toggle() }
                    .font(PTTheme.Typography.subheadline).foregroundStyle(PTTheme.Colors.primary)

                Spacer()
            }
            .background(PTTheme.Colors.background.ignoresSafeArea())
        }
    }
}
