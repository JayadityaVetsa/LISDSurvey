import SwiftUI

struct OngoingView: View {
    @EnvironmentObject var surveyStore: SurveyStore
    
    private var ongoingSurveys: [Survey] {
        surveyStore.allSurveys.filter { survey in
            let state = surveyStore.surveyStates[survey.id]
            return state != nil && state!.progress > 0 && !state!.isCompleted
        }
    }
    
    var body: some View {
        NavigationStack {
            VStack(alignment: .leading, spacing: 0) {
                ScrollView {
                    VStack(alignment: .leading, spacing: 0) {
                        HeaderView(
                            title: "Ongoing Surveys",
                            subtitle: "\(ongoingSurveys.count) surveys in progress"
                        )
                        
                        SurveyListView(surveys: ongoingSurveys)
                    }
                }
            }
            .background(AppColors.background.ignoresSafeArea())
        }
    }
}

struct OngoingSurveyCardView: View {
    @EnvironmentObject var surveyStore: SurveyStore
    let survey: Survey
    
    private var state: SurveyState {
        surveyStore.surveyStates[survey.id] ?? SurveyState()
    }
    
    var body: some View {
        HStack {
            Image(systemName: survey.image)
                .resizable()
                .scaledToFit()
                .frame(width: 40, height: 40)
                .padding(.trailing, 12)
                .foregroundColor(AppColors.accent)
            
            VStack(alignment: .leading) {
                Text(survey.title)
                    .font(.headline)
                    .foregroundColor(AppColors.textPrimary)
                Text("Progress: \(state.progress)/\(survey.questions.count)")
                    .font(.subheadline)
                    .foregroundColor(AppColors.textSecondary)
            }
            Spacer()
            Image(systemName: "chevron.right")
                .foregroundColor(AppColors.textSecondary.opacity(0.7))
        }
        .padding()
        .background(AppColors.cardBackground)
        .cornerRadius(12)
    }
}
