import SwiftUI

struct AuthView: View {
    @Binding var isLoggedIn: Bool
    @State private var selectedTab = 0
    @State private var email = ""
    @State private var password = ""
    @State private var rememberMe = false
    @FocusState private var passwordFocused: Bool

    var body: some View {
        ZStack {
            AppColors.background.ignoresSafeArea()
            VStack(alignment: .leading, spacing: 0) {
                Spacer().frame(height: 40)
                Button(action: {
                    // Back action
                }) {
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
                    // Segmented control
                    Picker("", selection: $selectedTab) {
                        Text("Login").tag(0)
                        Text("Register").tag(1)
                    }
                    .pickerStyle(.segmented)
                    .padding(.horizontal, 16)
                    // Email Field
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
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(AppColors.primary.opacity(0.2), lineWidth: 1)
                    )
                    .shadow(color: .gray.opacity(0.1), radius: 4, x: 0, y: 2)
                    .padding(.horizontal, 16)
                    // Password Field
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
                    .overlay(
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(AppColors.primary.opacity(0.2), lineWidth: 1)
                    )
                    .shadow(color: .gray.opacity(0.1), radius: 4, x: 0, y: 2)
                    .padding(.horizontal, 16)
                    // Remember me and Forgot password
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
                        Button(action: {
                            // Forgot password action
                        }) {
                            Text("Forgot Password?")
                                .font(.system(size: 15, weight: .medium, design: .rounded))
                                .foregroundColor(AppColors.primary)
                        }
                    }
                    .padding(.horizontal, 16)
                    // Login Button
                    Button(action: {
                        isLoggedIn = true
                    }) {
                        Text(selectedTab == 0 ? "Login" : "Register")
                            .font(.system(size: 18, weight: .semibold, design: .rounded))
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 16)
                            .background(AppColors.accent)
                            .clipShape(RoundedRectangle(cornerRadius: 12))
                            .shadow(color: .gray.opacity(0.2), radius: 4, x: 0, y: 2)
                    }
                    .padding(.horizontal, 16)
                    // Or login with
                    HStack {
                        Rectangle()
                            .frame(height: 1)
                            .foregroundColor(AppColors.textSecondary.opacity(0.3))
                        Text("Or login with")
                            .font(.system(size: 14, weight: .medium, design: .rounded))
                            .foregroundColor(AppColors.textSecondary)
                        Rectangle()
                            .frame(height: 1)
                            .foregroundColor(AppColors.textSecondary.opacity(0.3))
                    }
                    .padding(.horizontal, 16)
                    // Social buttons
                    SocialLoginView()
                }
                .padding(.vertical, 24)
                .background(AppColors.cardBackground)
                .clipShape(RoundedRectangle(cornerRadius: 24))
                .shadow(color: .gray.opacity(0.1), radius: 6, x: 0, y: 3)
                .padding(.horizontal, 8)
                Spacer()
            }
        }
    }
}

#Preview {
    AuthView(isLoggedIn: .constant(false))
}
