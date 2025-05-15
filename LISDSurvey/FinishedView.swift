import SwiftUI

struct FinishedView: View {
    @State private var expandedSurveyID: UUID? = nil
    
    private var completedSurveys: [Survey] {
        Survey.mockSurveys.filter { $0.progress == $0.total }
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 0) {
                    HeaderView(
                        title: "Completed Surveys",
                        subtitle: "\(completedSurveys.count) completed surveys"
                    )

                    VStack(spacing: 18) {
                        ForEach(completedSurveys) { survey in
                            CompletedSurveyCardView(
                                survey: survey,
                                isExpanded: expandedSurveyID == survey.id,
                                onToggle: {
                                    withAnimation {
                                        expandedSurveyID = (expandedSurveyID == survey.id) ? nil : survey.id
                                    }
                                }
                            )
                        }
                    }
                    .padding(.horizontal)
                    .padding(.top, 16)
                    .padding(.bottom, 24)
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

private struct CompletedSurveyCardView: View {
    let survey: Survey
    let isExpanded: Bool
    let onToggle: () -> Void

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Button(action: onToggle) {
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

                    Image(systemName: isExpanded ? "chevron.up" : "chevron.down")
                        .foregroundColor(AppColors.textSecondary)
                }
                .padding()
                .background(AppColors.cardBackground)
                .cornerRadius(12)
            }

            if isExpanded {
                VStack(alignment: .leading, spacing: 16) {
                    ForEach(Array(zip(survey.questions.indices, survey.questions)), id: \.0) { (index, question) in
                        VStack(alignment: .leading, spacing: 8) {
                            Text(question.text)
                                .font(.headline)
                                .foregroundColor(AppColors.textSecondary)

                            let result = survey.mockResults[index]
                            ForEach(question.options, id: \.self) { option in
                                let count = result[option] ?? 0
                                HStack {
                                    Text(option)
                                        .font(.subheadline)
                                        .frame(width: 100, alignment: .leading)
                                        .foregroundColor(AppColors.textPrimary)

                                    GeometryReader { geo in
                                        RoundedRectangle(cornerRadius: 4)
                                            .fill(AppColors.accent)
                                            .frame(width: CGFloat(count) / 30 * geo.size.width, height: 10)
                                    }
                                    .frame(height: 10)

                                    Text("\(count)")
                                        .font(.caption)
                                        .foregroundColor(AppColors.textSecondary)
                                }
                            }
                        }
                    }
                }
                .padding(.horizontal, 12)
                .padding(.bottom, 8)
                .transition(.opacity.combined(with: .slide))
            }
        }
        .animation(.easeInOut(duration: 0.25), value: isExpanded)
    }
}
