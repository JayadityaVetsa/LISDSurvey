import SwiftUI

struct SurveyResultsView: View {
    @EnvironmentObject var surveyStore: SurveyStore
    let survey: SurveyModel

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 24) {
                headerView

                ForEach(Array(survey.questions.enumerated()), id: \.offset) { index, question in
                    QuestionResultView(question: question, results: result(for: index))
                }
            }
            .padding(.horizontal)
        }
        .navigationTitle("Survey Results")
        .navigationBarTitleDisplayMode(.inline)
        .background(AppColors.background.ignoresSafeArea())
        .onAppear {
            surveyStore.beginLiveResultsSyncForSurvey(survey.id, questionCount: survey.questions.count)
        }
    }

    private var headerView: some View {
        Text("Results for \(survey.title)")
            .font(.title)
            .fontWeight(.bold)
            .padding(.top)
    }

    private func result(for index: Int) -> [String: Int] {
        surveyStore.aggregatedSurveyResults[survey.id]?[index] ?? [:]
    }
}
struct QuestionResultView: View {
    let question: QuestionModel
    let results: [String: Int]

    private var totalVotes: Int {
        results.values.reduce(0, +)
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(question.text)
                .font(.headline)
                .foregroundColor(AppColors.textSecondary)

            if results.isEmpty {
                Text("Waiting for responses...")
                    .font(.footnote)
                    .foregroundColor(.gray)
            } else {
                ForEach(question.options, id: \.self) { option in
                    OptionResultView(option: option, count: results[option] ?? 0, total: totalVotes)
                }
            }
        }
        .padding(.bottom, 12)
    }
}

struct OptionResultView: View {
    let option: String
    let count: Int
    let total: Int

    private var percentage: CGFloat {
        total > 0 ? CGFloat(count) / CGFloat(total) : 0
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            HStack {
                Text(option)
                    .font(.subheadline)
                    .foregroundColor(AppColors.textPrimary)
                Spacer()
                Text("\(count) vote\(count == 1 ? "" : "s")")
                    .font(.caption)
                    .foregroundColor(AppColors.textSecondary)
            }

            GeometryReader { geo in
                ZStack(alignment: .leading) {
                    RoundedRectangle(cornerRadius: 4)
                        .fill(AppColors.accent.opacity(0.2))
                        .frame(height: 20)

                    RoundedRectangle(cornerRadius: 4)
                        .fill(AppColors.accent)
                        .frame(width: geo.size.width * percentage, height: 20)
                        .animation(.easeInOut(duration: 0.25), value: percentage)
                        .overlay(
                            Text("\(Int(percentage * 100))%")
                                .font(.caption2)
                                .foregroundColor(.white)
                                .padding(.horizontal, 4),
                            alignment: .trailing
                        )
                }
            }
            .frame(height: 20)
        }
    }
}
