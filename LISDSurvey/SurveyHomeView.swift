import SwiftUI

struct SurveyHomeView: View {
    @EnvironmentObject var surveyStore: SurveyStore

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 0) {
                    HeaderView(
                        title: "All Surveys",
                        subtitle: "\(surveyStore.availableSurveys.count) available surveys"
                    )

                    SurveyListView(surveys: surveyStore.availableSurveys)
                }
            }
            .background(AppColors.background.ignoresSafeArea())
        }
    }
}

struct HeaderView: View {
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
