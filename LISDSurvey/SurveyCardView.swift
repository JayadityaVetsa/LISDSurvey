import SwiftUI

struct SurveyCardView: View {
    let survey: Survey
    
    var body: some View {
        NavigationLink(destination: SurveyView(survey: survey)) {
            HStack(spacing: 16) {
                Image(systemName: survey.image)
                    .resizable()
                    .scaledToFit()
                    .frame(width: 44, height: 44)
                    .foregroundColor(AppColors.textPrimary)
                    .background(AppColors.cardBackground)
                    .clipShape(RoundedRectangle(cornerRadius: 12))
                    .shadow(color: AppColors.textSecondary.opacity(0.1), radius: 1, x: 0, y: 1)
                
                VStack(alignment: .leading, spacing: 6) {
                    Text(survey.title)
                        .font(.system(size: 17, weight: .semibold))
                        .foregroundColor(AppColors.textPrimary)
                    
                    HStack {
                        ProgressView(value: Float(survey.progress), total: Float(survey.total))
                            .accentColor(AppColors.accent)
                            .frame(height: 6)
                            .frame(maxWidth: 120)
                        
                        Text("\(survey.progress)/\(survey.total)")
                            .font(.system(size: 14))
                            .foregroundColor(AppColors.textSecondary)
                    }
                }
                Spacer()
            }
            .padding()
            .background(AppColors.cardBackground)
            .cornerRadius(18)
            .shadow(color: AppColors.textSecondary.opacity(0.08), radius: 4, x: 0, y: 2)
        }
        .buttonStyle(PlainButtonStyle())
    }
}
