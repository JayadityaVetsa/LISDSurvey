import SwiftUI
import FirebaseAuth
import FirebaseCore
import GoogleSignIn
import GoogleSignInSwift

struct AuthView: View {
    @Binding var isLoggedIn: Bool
    @State private var selectedTab = 0
    @State private var email = ""
    @State private var password = ""
    @State private var rememberMe = false
    @State private var errorMessage = ""
    @State private var showAlert = false
    @State private var isLoading = false
    @FocusState private var passwordFocused: Bool

    var body: some View {
        ZStack {
            AppColors.background.ignoresSafeArea()

            VStack(alignment: .leading, spacing: 0) {
                Spacer().frame(height: 40)

                Button(action: {}) {
                    Image(systemName: "chevron.left")
                        .foregroundColor(AppColors.primary)
                        .font(.system(size: 24, weight: .semibold))
                        .padding(.leading, 16)
                }

                Spacer().frame(height: 20)

                Text(selectedTab == 0 ? "Welcome Back!" : "Create Account")
                    .font(.system(size: 32, weight: .bold, design: .rounded))
                    .foregroundColor(AppColors.textPrimary)
                    .padding(.horizontal, 16)

                Text(selectedTab == 0 ? "Sign in to continue" : "Join us to start managing surveys")
                    .font(.system(size: 16, weight: .medium, design: .rounded))
                    .foregroundColor(AppColors.textSecondary)
                    .padding(.horizontal, 16)
                    .padding(.top, 8)

                Spacer().frame(height: 30)

                VStack(spacing: 20) {
                    Picker("", selection: $selectedTab) {
                        Text("Login").tag(0)
                        Text("Register").tag(1)
                    }
                    .pickerStyle(.segmented)
                    .padding(.horizontal, 16)

                    HStack {
                        Image(systemName: "envelope")
                            .foregroundColor(AppColors.textSecondary)
                            .font(.system(size: 18))
                        TextField("Email Address", text: $email)
                            .font(.system(size: 16, design: .rounded))
                            .keyboardType(.emailAddress)
                            .textInputAutocapitalization(.never)
                            .disableAutocorrection(true)
                            .foregroundColor(AppColors.textPrimary)
                    }
                    .padding(.vertical, 12)
                    .padding(.horizontal, 16)
                    .background(AppColors.cardBackground)
                    .clipShape(RoundedRectangle(cornerRadius: 12))
                    .overlay(RoundedRectangle(cornerRadius: 12).stroke(AppColors.primary.opacity(0.2), lineWidth: 1))
                    .shadow(color: .gray.opacity(0.1), radius: 4, x: 0, y: 2)
                    .padding(.horizontal, 16)

                    HStack {
                        Image(systemName: "lock")
                            .foregroundColor(AppColors.textSecondary)
                            .font(.system(size: 18))
                        SecureField("Password", text: $password)
                            .font(.system(size: 16, design: .rounded))
                            .foregroundColor(AppColors.textPrimary)
                            .focused($passwordFocused)
                        Button(action: { passwordFocused.toggle() }) {
                            Image(systemName: passwordFocused ? "eye.slash" : "eye")
                                .foregroundColor(AppColors.textSecondary)
                                .font(.system(size: 18))
                        }
                    }
                    .padding(.vertical, 12)
                    .padding(.horizontal, 16)
                    .background(AppColors.cardBackground)
                    .clipShape(RoundedRectangle(cornerRadius: 12))
                    .overlay(RoundedRectangle(cornerRadius: 12).stroke(AppColors.primary.opacity(0.2), lineWidth: 1))
                    .shadow(color: .gray.opacity(0.1), radius: 4, x: 0, y: 2)
                    .padding(.horizontal, 16)

                    HStack {
                        Button(action: { rememberMe.toggle() }) {
                            HStack(spacing: 8) {
                                Image(systemName: rememberMe ? "checkmark.square.fill" : "square")
                                    .foregroundColor(rememberMe ? AppColors.accent : AppColors.textSecondary)
                                    .font(.system(size: 18))
                                Text("Remember me")
                                    .font(.system(size: 15, weight: .medium, design: .rounded))
                                    .foregroundColor(AppColors.textPrimary)
                            }
                        }
                        Spacer()
                        Button("Forgot Password?") {
                            // Forgot password logic here
                        }
                        .font(.system(size: 15, weight: .medium, design: .rounded))
                        .foregroundColor(AppColors.primary)
                    }
                    .padding(.horizontal, 16)

                    Button(action: handleAuth) {
                        if isLoading {
                            ProgressView()
                                .progressViewStyle(CircularProgressViewStyle(tint: .white))
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 16)
                        } else {
                            Text(selectedTab == 0 ? "Login" : "Register")
                                .font(.system(size: 18, weight: .semibold, design: .rounded))
                                .foregroundColor(.white)
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 16)
                        }
                    }
                    .background(AppColors.accent)
                    .clipShape(RoundedRectangle(cornerRadius: 12))
                    .shadow(color: .gray.opacity(0.2), radius: 4, x: 0, y: 2)
                    .padding(.horizontal, 16)

                    HStack {
                        Rectangle().frame(height: 1).foregroundColor(.gray.opacity(0.3))
                        Text("Or login with")
                            .font(.footnote)
                            .foregroundColor(.gray)
                        Rectangle().frame(height: 1).foregroundColor(.gray.opacity(0.3))
                    }
                    .padding(.horizontal, 16)

                    Button(action: handleGoogleSignIn) {
                        HStack(spacing: 12) {
                            Image("google_logo")
                                .resizable()
                                .frame(width: 20, height: 20)
                            Text("Sign in with Google")
                                .font(.system(size: 16, weight: .semibold, design: .rounded))
                                .foregroundColor(AppColors.textPrimary)
                        }
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(AppColors.cardBackground)
                        .cornerRadius(12)
                        .overlay(
                            RoundedRectangle(cornerRadius: 12)
                                .stroke(AppColors.primary.opacity(0.2), lineWidth: 1)
                        )
                        .shadow(color: .gray.opacity(0.1), radius: 4, x: 0, y: 2)
                    }
                    .padding(.horizontal, 16)
                }
                .padding(.vertical, 24)
                .background(AppColors.cardBackground)
                .clipShape(RoundedRectangle(cornerRadius: 24))
                .shadow(color: .gray.opacity(0.1), radius: 6, x: 0, y: 3)
                .padding(.horizontal, 8)

                Spacer()
            }

            if isLoading {
                Color.black.opacity(0.25).ignoresSafeArea()
                ProgressView().scaleEffect(1.5)
            }
        }
        .onAppear {
            // If the user is already authenticated, bypass AuthView
            if Auth.auth().currentUser != nil {
                isLoggedIn = true
            }
        }
        .alert(isPresented: $showAlert) {
            Alert(title: Text("Error"), message: Text(errorMessage), dismissButton: .default(Text("OK")))
        }
    }

    private func handleAuth() {
        errorMessage = ""
        isLoading = true

        let trimmedEmail = email.trimmingCharacters(in: .whitespacesAndNewlines)
        let trimmedPassword = password.trimmingCharacters(in: .whitespacesAndNewlines)

        guard !trimmedEmail.isEmpty, !trimmedPassword.isEmpty else {
            errorMessage = "Email and password cannot be empty."
            showAlert = true
            isLoading = false
            return
        }

        if selectedTab == 0 {
            Auth.auth().signIn(withEmail: trimmedEmail, password: trimmedPassword) { result, error in
                isLoading = false
                if let error = error as NSError? {
                    switch AuthErrorCode(rawValue: error.code) {
                    case .userNotFound:
                        errorMessage = "No account found. Please register instead."
                        selectedTab = 1
                    case .invalidEmail:
                        errorMessage = "Please enter a valid email."
                    case .wrongPassword:
                        errorMessage = "Incorrect password."
                    case .userDisabled:
                        errorMessage = "This account has been disabled."
                    default:
                        errorMessage = error.localizedDescription
                    }
                    showAlert = true
                } else {
                    isLoggedIn = true
                }
            }
        } else {
            Auth.auth().createUser(withEmail: trimmedEmail, password: trimmedPassword) { result, error in
                isLoading = false
                if let error = error as NSError? {
                    switch AuthErrorCode(rawValue: error.code) {
                    case .emailAlreadyInUse:
                        errorMessage = "Account already exists. Please log in."
                        selectedTab = 0
                    case .invalidEmail:
                        errorMessage = "Please enter a valid email."
                    case .weakPassword:
                        errorMessage = "Password must be at least 6 characters."
                    default:
                        errorMessage = error.localizedDescription
                    }
                    showAlert = true
                } else {
                    isLoggedIn = true
                }
            }
        }
    }

    private func handleGoogleSignIn() {
        guard let clientID = FirebaseApp.app()?.options.clientID else {
            errorMessage = "Missing client ID."
            showAlert = true
            return
        }

        let config = GIDConfiguration(clientID: clientID)

        guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
              let rootViewController = windowScene.windows.first?.rootViewController else {
            errorMessage = "Unable to access root view controller."
            showAlert = true
            return
        }

        isLoading = true

        GIDSignIn.sharedInstance.signIn(withPresenting: rootViewController) { result, error in
            isLoading = false

            if let error = error {
                errorMessage = error.localizedDescription
                showAlert = true
                return
            }

            guard let user = result?.user,
                  let idToken = user.idToken?.tokenString else {
                errorMessage = "Google sign-in failed."
                showAlert = true
                return
            }

            let accessToken = user.accessToken.tokenString

            let credential = GoogleAuthProvider.credential(withIDToken: idToken,
                                                           accessToken: accessToken)

            Auth.auth().signIn(with: credential) { result, error in
                if let error = error {
                    errorMessage = error.localizedDescription
                    showAlert = true
                } else {
                    isLoggedIn = true
                }
            }
        }
    }
}

#Preview {
    AuthView(isLoggedIn: .constant(false))
}
