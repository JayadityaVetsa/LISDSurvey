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
            Color.black.ignoresSafeArea()
            VStack(alignment: .leading, spacing: 0) {
                Spacer().frame(height: 40)
                Button(action: {
                    // Back action
                }) {
                    Image(systemName: "chevron.left")
                        .foregroundColor(.white)
                        .font(.title2)
                        .padding(.leading, 8)
                }
                Spacer().frame(height: 10)
                Text("Go ahead and set up\nyour account")
                    .font(.system(size: 28, weight: .bold))
                    .foregroundColor(.white)
                    .multilineTextAlignment(.leading)
                    .padding(.horizontal)
                Text("Sign in-up to enjoy the best managing experience")
                    .font(.system(size: 16))
                    .foregroundColor(.gray)
                    .padding(.horizontal)
                    .padding(.top, 8)
                Spacer().frame(height: 30)
                VStack(spacing: 24) {
                    // Segmented control
                    HStack {
                        Button(action: { selectedTab = 0 }) {
                            Text("Login")
                                .fontWeight(.semibold)
                                .foregroundColor(selectedTab == 0 ? .black : .gray)
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 10)
                                .background(
                                    Group {
                                        if selectedTab == 0 {
                                            Color.white.clipShape(Capsule())
                                        } else {
                                            Color.clear
                                        }
                                    }
                                )
                        }
                        Button(action: { selectedTab = 1 }) {
                            Text("Register")
                                .fontWeight(.semibold)
                                .foregroundColor(selectedTab == 1 ? .black : .gray)
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 10)
                                .background(
                                    Group {
                                        if selectedTab == 1 {
                                            Color.white.opacity(0.4).clipShape(Capsule())
                                        } else {
                                            Color.clear
                                        }
                                    }
                                )
                        }
                    }
                    .background(Color.white.opacity(0.15))
                    .clipShape(Capsule())
                    .padding(.horizontal, 8)
                    HStack {
                        Image(systemName: "envelope")
                            .foregroundColor(.gray)
                        TextField("Email Address", text: $email)
                            .keyboardType(.emailAddress)
                            .autocapitalization(.none)
                            .disableAutocorrection(true)
                    }
                    .padding()
                    .background(Color(.systemGray6))
                    .cornerRadius(12)
                    // Password Field
                    HStack {
                        Image(systemName: "lock")
                            .foregroundColor(.gray)
                        SecureField("Password", text: $password)
                            .focused($passwordFocused)
                        Button(action: { passwordFocused.toggle() }) {
                            Image(systemName: passwordFocused ? "eye.slash" : "eye")
                                .foregroundColor(.gray)
                        }
                    }
                    .padding()
                    .background(Color(.systemGray6))
                    .cornerRadius(12)
                    // Remember me and Forgot password
                    HStack {
                        Button(action: { rememberMe.toggle() }) {
                            HStack(spacing: 8) {
                                Image(systemName: rememberMe ? "checkmark.square.fill" : "square")
                                    .foregroundColor(rememberMe ? .green : .gray)
                                Text("Remember me")
                                    .font(.system(size: 15))
                                    .foregroundColor(.black)
                            }
                        }
                        Spacer()
                        Button(action: {
                            // Forgot password action
                        }) {
                            Text("Forgot Password?")
                                .font(.system(size: 15))
                                .foregroundColor(.green)
                        }
                    }
                    // Login Button
                    Button(action: {
                        isLoggedIn = true // <-- This triggers navigation to MainTabView
                    }) {
                        Text("Login")
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .frame(height: 50)
                            .background(Color(.systemGreen))
                            .cornerRadius(25)
                    }
                    // Or login with
                    HStack {
                        Rectangle()
                            .frame(height: 1)
                            .foregroundColor(.gray.opacity(0.3))
                        Text("Or login with")
                            .font(.system(size: 14))
                            .foregroundColor(.gray)
                        Rectangle()
                            .frame(height: 1)
                            .foregroundColor(.gray.opacity(0.3))
                    }
                    // Social buttons
                    SocialLoginView()
                }
                .padding()
                .background(Color.white)
                .cornerRadius(30)
                .padding(.horizontal)
                .padding(.top, 30)
                Spacer()
            }
        }
    }
}
