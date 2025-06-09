import SwiftUI
import FirebaseAuth

struct FinishedView: View {
    @EnvironmentObject var surveyStore: SurveyStore

    private var currentUserID: String? {
        Auth.auth().currentUser?.uid
    }

    private var completedSurveys: [(SurveyModel, SurveyProgress)] {
        guard let uid = currentUserID,
              let completions = surveyStore.userSurveyCompletion[uid] else { return [] }

        return completions.compactMap { (surveyID, progress) in
            guard progress.isCompleted,
                  let survey = surveyStore.availableSurveys.first(where: { $0.id == surveyID }) else {
                return nil
            }
            return (survey, progress)
        }
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 0) {
                    HeaderView(
                        title: "Completed Surveys",
                        subtitle: "You have completed \(completedSurveys.count) surveys"
                    )

                    VStack(spacing: 18) {
                        ForEach(completedSurveys, id: \.0.id) { (survey, _) in
                            NavigationLink(destination: SurveyResultsView(survey: survey)) {
                                CompletedSurveyCardView(survey: survey)
                            }
                            .buttonStyle(PlainButtonStyle())
                        }
                    }
                    .padding(.horizontal)
                    .padding(.top, 8)
                    .padding(.bottom, 24)
                }
            }
            .background(AppColors.background.ignoresSafeArea())
        }
    }
}

struct CompletedSurveyCardView: View {
    let survey: SurveyModel

    var body: some View {
        HStack {
            Image(systemName: survey.image)
                .resizable()
                .scaledToFit()
                .frame(width: 30, height: 30)
                .foregroundColor(AppColors.accent)

            Text(survey.title)
                .font(.headline)
                .foregroundColor(AppColors.textPrimary)
            Spacer()
        }
        .padding()
        .background(AppColors.cardBackground)
        .cornerRadius(12)
    }
}
