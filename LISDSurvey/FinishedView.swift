import SwiftUI
import FirebaseAuth

struct FinishedView: View {
    @EnvironmentObject var surveyStore: SurveyStore

    private var completedSurveys: [(SurveyModel, SurveyProgress)] {
        surveyStore.surveyProgressStates.compactMap { (surveyID, progress) in
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
                VStack(alignment: .leading, spacing: 16) {
                    FinishedHeaderView(
                        title: "Completed Surveys",
                        subtitle: "You have completed \(completedSurveys.count) surveys"
                    )
                    .padding(.horizontal)

                    if completedSurveys.isEmpty {
                        Text("You haven't completed any surveys yet.")
                            .font(.subheadline)
                            .foregroundColor(AppColors.textSecondary)
                            .padding()
                    } else {
                        VStack(spacing: 16) {
                            ForEach(completedSurveys, id: \.0.id) { (survey, _) in
                                NavigationLink(destination: SurveyResultsView(survey: survey)) {
                                    CompletedSurveyCardView(survey: survey)
                                }
                                .buttonStyle(PlainButtonStyle())
                            }
                        }
                        .padding(.horizontal)
                        .padding(.bottom)
                    }
                }
                .padding(.top)
            }
            .background(AppColors.background.ignoresSafeArea())
        }
    }
}

struct CompletedSurveyCardView: View {
    let survey: SurveyModel

    var body: some View {
        HStack(spacing: 16) {
            Image(systemName: survey.image)
                .resizable()
                .scaledToFit()
                .frame(width: 30, height: 30)
                .foregroundColor(AppColors.accent)

            Text(survey.title)
                .font(.headline)
                .foregroundColor(AppColors.textPrimary)

            Spacer()

            Image(systemName: "checkmark.circle.fill")
                .foregroundColor(.green)
        }
        .padding()
        .background(AppColors.cardBackground)
        .cornerRadius(12)
        .shadow(color: AppColors.textSecondary.opacity(0.05), radius: 2, x: 0, y: 1)
    }
}

struct FinishedHeaderView: View {
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
