import SwiftUI

struct OngoingView: View {
    private var ongoingSurveys: [Survey] {
        Survey.mockSurveys.filter { survey in
            survey.progress > 0 && survey.progress < survey.total
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

private struct HeaderView: View {
    let title: String
    let subtitle: String
    
    var body: some View {
        VStack(alignment: .leading, spacing: 1) {
            Text(title)
                .font(.system(size: 26, weight: .bold))
                .foregroundColor(AppColors.textPrimary)
                .padding(.horizontal)
                .padding(.top, 24)
            
            Text(subtitle)
                .font(.system(size: 15))
                .foregroundColor(AppColors.textSecondary)
                .padding(.horizontal)
                .padding(.top, 1)
        }
    }
}

private struct SurveyListView: View {
    let surveys: [Survey]
    
    var body: some View {
        VStack(spacing: 18) {
            ForEach(surveys) { survey in
                SurveyCardView(survey: survey)
            }
        }
        .padding(.horizontal)
        .padding(.top, 16)
        .padding(.bottom, 24)
    }
}

#Preview {
    OngoingView()
}
