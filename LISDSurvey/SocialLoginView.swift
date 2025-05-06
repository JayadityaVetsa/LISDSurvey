import SwiftUI

struct SocialLoginView: View {
    var body: some View {
        HStack(spacing: 16) {
            // Google Button
            Button(action: {
                // Google login action
            }) {
                HStack(spacing: 8) {
                    Image(systemName: "g.circle") // Fallback to SF Symbol
                        .resizable()
                        .scaledToFit()
                        .frame(width: 20, height: 20)
                        .foregroundColor(AppColors.primary)
                    Text("Google")
                        .font(.system(size: 15, weight: .medium, design: .rounded))
                        .foregroundColor(AppColors.textPrimary)
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 12)
                .background(AppColors.cardBackground)
                .clipShape(RoundedRectangle(cornerRadius: 12))
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(AppColors.primary.opacity(0.2), lineWidth: 1)
                )
                .shadow(color: .gray.opacity(0.1), radius: 4, x: 0, y: 2)
            }
            // Facebook Button
            Button(action: {
                // Facebook login action
            }) {
                HStack(spacing: 8) {
                    Image(systemName: "f.circle") // Fallback to SF Symbol
                        .resizable()
                        .scaledToFit()
                        .frame(width: 20, height: 20)
                        .foregroundColor(AppColors.primary)
                    Text("Facebook")
                        .font(.system(size: 15, weight: .medium, design: .rounded))
                        .foregroundColor(AppColors.textPrimary)
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 12)
                .background(AppColors.cardBackground)
                .clipShape(RoundedRectangle(cornerRadius: 12))
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(AppColors.primary.opacity(0.2), lineWidth: 1)
                )
                .shadow(color: .gray.opacity(0.1), radius: 4, x: 0, y: 2)
            }
        }
        .padding(.horizontal, 16)
    }
}

#Preview {
    SocialLoginView()
}
