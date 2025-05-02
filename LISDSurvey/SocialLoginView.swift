import SwiftUI

struct SocialLoginView: View {
    var body: some View {
        VStack(spacing: 20) {
            // Social buttons
            HStack(spacing: 16) {
                // Google Button
                Button(action: {
                    // Google login action
                }) {
                    HStack(spacing: 8) {
                        Image("google_logo") // Add your Google logo asset here
                            .resizable()
                            .frame(width: 20, height: 20)
                        Text("Google")
                            .foregroundColor(.black)
                            .fontWeight(.medium)
                    }
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.white)
                    .overlay(
                        RoundedRectangle(cornerRadius: 25)
                            .stroke(Color.gray.opacity(0.3), lineWidth: 1)
                    )
                }
                
                // Facebook Button
                Button(action: {
                    // Facebook login action
                }) {
                    HStack(spacing: 8) {
                        Image("facebook_logo") // Add your Facebook logo asset here
                            .resizable()
                            .frame(width: 20, height: 20)
                        Text("Facebook")
                            .foregroundColor(.black)
                            .fontWeight(.medium)
                    }
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.white)
                    .overlay(
                        RoundedRectangle(cornerRadius: 25)
                            .stroke(Color.gray.opacity(0.3), lineWidth: 1)
                    )
                }
            }
        }
        .padding(.horizontal)
    }
}
