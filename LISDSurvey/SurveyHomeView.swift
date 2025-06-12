import SwiftUI

struct SurveyHomeView: View {
    @EnvironmentObject var surveyStore: SurveyStore

    private var filteredSurveys: [SurveyModel] {
        surveyStore.availableSurveys.filter { survey in
            !(surveyStore.surveyProgressStates[survey.id]?.isCompleted ?? false) &&
            !surveyStore.completedSurveyIds.contains(survey.id)
        }
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 16) {
                    SurveyHomeHeaderView(
                        title: "All Surveys",
                        subtitle: "\(filteredSurveys.count) available surveys"
                    )
                    .padding(.horizontal)

                    if filteredSurveys.isEmpty {
                        Text("No available surveys at this time.")
                            .font(.subheadline)
                            .foregroundColor(AppColors.textSecondary)
                            .padding(.horizontal)
                    } else {
                        SurveyListView(surveys: filteredSurveys)
                            .padding(.horizontal)
                    }
                }
                .padding(.top)
            }
            .background(AppColors.background.ignoresSafeArea())
            .navigationTitle("Surveys")
            .navigationBarTitleDisplayMode(.inline)
        }
    }
}

struct SurveyHomeHeaderView: View {
    let title: String
    let subtitle: String

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(title)
                .font(.title)
                .fontWeight(.bold)
                .foregroundColor(AppColors.textPrimary)

            Text(subtitle)
                .font(.subheadline)
                .foregroundColor(AppColors.textSecondary)
        }
    }
}
