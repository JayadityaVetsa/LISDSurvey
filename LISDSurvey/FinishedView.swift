import SwiftUI

struct FinishedView: View {
    @EnvironmentObject var surveyStore: SurveyStore
    @State private var expandedSurveyID: UUID? = nil
    
    private var completedSurveys: [Survey] {
        surveyStore.allSurveys.filter { survey in
            let state = surveyStore.surveyStates[survey.id]
            return state != nil && state!.isCompleted
        }
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

struct CompletedSurveyCardView: View {
    @EnvironmentObject var surveyStore: SurveyStore
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
                        VStack(alignment: .leading, spacing: 12) {
                            Text(question.text)
                                .font(.headline)
                                .foregroundColor(AppColors.textSecondary)
                                .padding(.bottom, 4)

                            let results = survey.mockResults[index]
                            let total = results.values.reduce(0, +)
                            
                            ForEach(question.options, id: \.self) { option in
                                let count = results[option] ?? 0
                                let percentage = total > 0 ? CGFloat(count) / CGFloat(total) : 0
                                
                                HStack(spacing: 12) {
                                    Text(option)
                                        .font(.subheadline)
                                        .frame(width: 100, alignment: .leading)
                                        .foregroundColor(AppColors.textPrimary)
                                    
                                    GeometryReader { geo in
                                        RoundedRectangle(cornerRadius: 4)
                                            .fill(AppColors.accent.opacity(0.3))
                                            .frame(width: geo.size.width * percentage, height: 20)
                                            .overlay(
                                                Text("\(Int(percentage * 100))%")
                                                    .font(.system(size: 12))
                                                    .foregroundColor(.white)
                                                    .padding(.trailing, 4),
                                                alignment: .trailing
                                            )
                                    }
                                    .frame(height: 20)
                                }
                            }
                        }
                        .padding(.vertical, 8)
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

// Update the Survey struct with realistic mock results
extension Survey {
    var mockResults: [[String: Int]] {
        questions.map { question in
            // Custom percentages based on question type
            if question.text.contains("travel") {
                return ["Weekly": 15, "Monthly": 20, "Yearly": 60, "Never": 5]
            }
            else if question.text.contains("vegetables") {
                return ["Daily": 45, "Weekly": 30, "Occasionally": 20, "Never": 5]
            }
            else if question.text.contains("exercise") {
                return ["Daily": 25, "3x/week": 40, "Weekly": 25, "Never": 10]
            }
            // Default case
            return question.options.reduce(into: [:]) { dict, option in
                dict[option] = Int.random(in: 5...30)
            }
        }
    }
}
