import SwiftUI

struct SurveyCardView: View {
    @EnvironmentObject var surveyStore: SurveyStore
    let survey: Survey
    
    private var state: SurveyState {
        surveyStore.surveyStates[survey.id] ?? SurveyState()
    }
    
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
                        ProgressView(value: Double(state.progress), total: Double(survey.questions.count))
                            .accentColor(AppColors.accent)
                            .frame(height: 6)
                            .frame(maxWidth: 120)
                        
                        Text(state.isCompleted ? "Completed" : "\(state.progress)/\(survey.questions.count)")
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
