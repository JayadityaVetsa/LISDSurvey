import SwiftUI
import FirebaseAuth

struct OngoingView: View {
    @EnvironmentObject var surveyStore: SurveyStore

    private var currentUserID: String? {
        Auth.auth().currentUser?.uid
    }

    private var ongoingSurveys: [(SurveyModel, SurveyProgress)] {
        guard let uid = currentUserID,
              let completions = surveyStore.userSurveyCompletion[uid] else { return [] }

        return completions.compactMap { (surveyID, progress) in
            guard !progress.isCompleted, progress.progress > 0,
                  let survey = surveyStore.availableSurveys.first(where: { $0.id == surveyID }) else {
                return nil
            }
            return (survey, progress)
        }
    }

    var body: some View {
        NavigationStack {
            VStack(alignment: .leading, spacing: 0) {
                ScrollView {
                    VStack(alignment: .leading, spacing: 0) {
                        HeaderView(
                            title: "Ongoing Surveys",
                            subtitle: "You have \(ongoingSurveys.count) surveys in progress"
                        )

                        VStack(spacing: 18) {
                            ForEach(ongoingSurveys, id: \.0.id) { (survey, progress) in
                                NavigationLink(destination: SurveyView(survey: survey)) {
                                    OngoingSurveyCardView(survey: survey, progress: progress)
                                }
                            }
                        }
                        .padding(.horizontal)
                        .padding(.top, 8)
                    }
                }
            }
            .background(AppColors.background.ignoresSafeArea())
        }
    }
}

struct OngoingSurveyCardView: View {
    let survey: SurveyModel
    let progress: SurveyProgress

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
                Text("Progress: \(progress.progress)/\(survey.questions.count)")
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

