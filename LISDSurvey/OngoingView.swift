import SwiftUI
import FirebaseAuth

struct OngoingView: View {
    @EnvironmentObject var surveyStore: SurveyStore

    private var ongoingSurveys: [(SurveyModel, SurveyProgress)] {
        surveyStore.surveyProgressStates.compactMap { (surveyID, progress) in
            guard !progress.isCompleted,
                  progress.selectedAnswers.count > 0,
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
                    OngoingHeaderView(
                        title: "Ongoing Surveys",
                        subtitle: "You have \(ongoingSurveys.count) surveys in progress"
                    )
                    .padding(.horizontal)

                    if ongoingSurveys.isEmpty {
                        Text("No surveys in progress.")
                            .font(.subheadline)
                            .foregroundColor(AppColors.textSecondary)
                            .padding()
                    } else {
                        VStack(spacing: 18) {
                            ForEach(ongoingSurveys, id: \.0.id) { (survey, progress) in
                                NavigationLink(destination: SurveyView(survey: survey)) {
                                    OngoingSurveyCardView(survey: survey, progress: progress)
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

                Text("Progress: \(progress.selectedAnswers.count)/\(survey.questions.count)")
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

struct OngoingHeaderView: View {
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
