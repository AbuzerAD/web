import SwiftUI

struct TrainerAuthView: View {
    let auth: AuthService
    @State private var isSignUp = false
    @State private var email = ""
    @State private var password = ""
    @State private var name = ""

    var body: some View {
        NavigationStack {
            VStack(spacing: PTTheme.Spacing.xl) {
                VStack(spacing: PTTheme.Spacing.sm) {
                    Image(systemName: "figure.strengthtraining.traditional")
                        .font(.system(size: 56))
                        .foregroundStyle(PTTheme.Colors.primary)
                    Text("PTMode Trainer").font(PTTheme.Typography.largeTitle)
                    Text("Build workouts. Coach clients. Track progress.")
                        .font(PTTheme.Typography.subheadline)
                        .foregroundStyle(PTTheme.Colors.textSecondary)
                }
                .padding(.top, 40)

                VStack(spacing: PTTheme.Spacing.md) {
                    if isSignUp {
                        TextField("Full name", text: $name)
                            .textContentType(.name)
                            .padding()
                            .background(PTTheme.Colors.surface)
                            .clipShape(RoundedRectangle(cornerRadius: PTTheme.Radius.md))
                    }
                    TextField("Email", text: $email)
                        .textContentType(.emailAddress)
                        .textInputAutocapitalization(.never)
                        .keyboardType(.emailAddress)
                        .padding()
                        .background(PTTheme.Colors.surface)
                        .clipShape(RoundedRectangle(cornerRadius: PTTheme.Radius.md))
                    SecureField("Password", text: $password)
                        .textContentType(.password)
                        .padding()
                        .background(PTTheme.Colors.surface)
                        .clipShape(RoundedRectangle(cornerRadius: PTTheme.Radius.md))

                    if let err = auth.errorMessage {
                        Text(err).font(PTTheme.Typography.caption).foregroundStyle(PTTheme.Colors.danger)
                    }

                    PTButton(isSignUp ? "Create Account" : "Sign In", isLoading: auth.isLoading) {
                        Task {
                            if isSignUp {
                                await auth.signUp(email: email, password: password, role: .trainer, fullName: name)
                            } else {
                                await auth.signIn(email: email, password: password)
                            }
                        }
                    }
                }
                .padding(.horizontal, PTTheme.Spacing.lg)

                Button(isSignUp ? "Already have an account? Sign in" : "New here? Create account") {
                    isSignUp.toggle()
                }
                .font(PTTheme.Typography.subheadline)
                .foregroundStyle(PTTheme.Colors.primary)

                Spacer()
            }
            .background(PTTheme.Colors.background.ignoresSafeArea())
        }
    }
}
