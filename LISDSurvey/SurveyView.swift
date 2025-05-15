import SwiftUI

// Move to top to ensure it's in scope
struct SurveyButtonStyle: ButtonStyle {
    let backgroundColor: Color

    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.headline)
            .foregroundColor(.white)
            .padding(.horizontal, 24)
            .padding(.vertical, 12)
            .background(backgroundColor)
            .clipShape(Capsule())
            .opacity(configuration.isPressed ? 0.8 : 1.0)
    }
}

struct SurveyView: View {
    @State private var currentQuestionIndex = 0
    @State private var selectedAnswer: String?
    @State private var survey: Survey
    @State private var hasWatchedVideo = false
    @Environment(\.dismiss) var dismiss

    init(survey: Survey) {
        self._survey = State(initialValue: survey)
    }

    var body: some View {
        VStack(spacing: 0) {
            if !hasWatchedVideo {
                VideoPlaceholderView(hasWatchedVideo: $hasWatchedVideo)
            } else {
                ProgressHeader
                    .padding(.bottom)

                QuestionView
                    .padding(.horizontal)

                Spacer()

                NavigationControls
                    .padding()
            }
        }
        .navigationTitle(survey.title)
        .navigationBarTitleDisplayMode(.inline)
        .background(AppColors.background.ignoresSafeArea())
    }

    private var ProgressHeader: some View {
        VStack {
            Text("\(currentQuestionIndex + 1)/\(survey.questions.count)")
                .font(.subheadline)
                .foregroundColor(AppColors.textSecondary)

            ProgressView(value: Double(currentQuestionIndex + 1), total: Double(survey.questions.count))
                .progressViewStyle(LinearProgressViewStyle(tint: AppColors.accent))
        }
        .padding()
        .background(AppColors.cardBackground)
    }

    private var QuestionView: some View {
        VStack(alignment: .leading, spacing: 25) {
            Text(survey.questions[currentQuestionIndex].text)
                .font(.title2)
                .fontWeight(.bold)

            ForEach(survey.questions[currentQuestionIndex].options, id: \.self) { option in
                AnswerOption(option: option)
            }
        }
    }

    private func AnswerOption(option: String) -> some View {
        Button {
            selectedAnswer = option
            survey.progress = currentQuestionIndex + 1
        } label: {
            HStack {
                Text(option)
                    .foregroundColor(selectedAnswer == option ? .white : AppColors.textPrimary)

                Spacer()

                if selectedAnswer == option {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundColor(.white)
                }
            }
            .padding()
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(selectedAnswer == option ? AppColors.accent : AppColors.cardBackground)
            )
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(AppColors.primary.opacity(0.2), lineWidth: 1)
            )
        }
    }

    private var NavigationControls: some View {
        HStack {
            if currentQuestionIndex > 0 {
                Button("Previous") {
                    withAnimation {
                        currentQuestionIndex -= 1
                        selectedAnswer = nil
                    }
                }
                .buttonStyle(SurveyButtonStyle(backgroundColor: AppColors.primary))
            }

            Spacer()

            if currentQuestionIndex < survey.questions.count - 1 {
                Button("Next") {
                    withAnimation {
                        currentQuestionIndex += 1
                        selectedAnswer = nil
                    }
                }
                .buttonStyle(SurveyButtonStyle(backgroundColor: AppColors.accent))
            } else {
                Button("Submit") {
                    // Step 2 will add survey state tracking here
                    dismiss()
                }
                .buttonStyle(SurveyButtonStyle(backgroundColor: AppColors.accent))
            }
        }
    }
}

// MARK: - Video Placeholder View
struct VideoPlaceholderView: View {
    @Binding var hasWatchedVideo: Bool

    var body: some View {
        VStack(spacing: 20) {
            Text("Watch This Video Before Starting")
                .font(.title2)
                .fontWeight(.bold)
                .padding(.top)

            RoundedRectangle(cornerRadius: 16)
                .fill(Color.gray.opacity(0.3))
                .frame(height: 200)
                .overlay(
                    Image(systemName: "play.rectangle.fill")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 60)
                        .foregroundColor(.gray)
                )
                .padding()

            Button(action: {
                hasWatchedVideo = true
            }) {
                Text("Start Survey")
                    .frame(maxWidth: .infinity)
            }
            .buttonStyle(SurveyButtonStyle(backgroundColor: AppColors.accent))
            .padding(.horizontal)
        }
        .padding()
    }
}
