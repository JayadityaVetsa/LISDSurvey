import SwiftUI

struct SurveyView: View {
    @Environment(\.dismiss) var dismiss
    @EnvironmentObject var surveyStore: SurveyStore
    let survey: Survey
    
    @State private var hasWatchedVideo = false
    @State private var surveyState: SurveyState
    @State private var selectedAnswer: String?
    
    init(survey: Survey) {
        self.survey = survey
        self._surveyState = State(initialValue: SurveyState())
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
        .onAppear { loadState() }
        .onDisappear { saveState() }
        .navigationTitle(survey.title)
        .navigationBarTitleDisplayMode(.inline)
        .background(AppColors.background.ignoresSafeArea())
    }
    
    private var ProgressHeader: some View {
        VStack {
            Text("\(surveyState.currentQuestionIndex + 1)/\(survey.questions.count)")
                .font(.subheadline)
                .foregroundColor(AppColors.textSecondary)
            
            ProgressView(value: Double(surveyState.currentQuestionIndex + 1), total: Double(survey.questions.count))
                .progressViewStyle(LinearProgressViewStyle(tint: AppColors.accent))
        }
        .padding()
        .background(AppColors.cardBackground)
    }
    
    private var QuestionView: some View {
        VStack(alignment: .leading, spacing: 25) {
            Text(survey.questions[surveyState.currentQuestionIndex].text)
                .font(.title2)
                .fontWeight(.bold)
            
            ForEach(survey.questions[surveyState.currentQuestionIndex].options, id: \.self) { option in
                AnswerOption(option: option)
            }
        }
    }
    
    private func AnswerOption(option: String) -> some View {
        Button {
            selectedAnswer = option
            surveyState.selectedAnswers[surveyState.currentQuestionIndex] = option
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
            if surveyState.currentQuestionIndex > 0 {
                Button("Previous") {
                    withAnimation {
                        surveyState.currentQuestionIndex -= 1
                        selectedAnswer = surveyState.selectedAnswers[surveyState.currentQuestionIndex]
                    }
                }
                .buttonStyle(SurveyButtonStyle(backgroundColor: AppColors.primary))
            }
            
            Spacer()
            
            if surveyState.currentQuestionIndex < survey.questions.count - 1 {
                Button("Next") {
                    withAnimation {
                        surveyState.currentQuestionIndex += 1
                        selectedAnswer = surveyState.selectedAnswers[surveyState.currentQuestionIndex]
                    }
                }
                .buttonStyle(SurveyButtonStyle(backgroundColor: AppColors.accent))
            } else {
                Button("Submit") {
                    surveyState.isCompleted = true
                    saveState()
                    dismiss()
                }
                .buttonStyle(SurveyButtonStyle(backgroundColor: AppColors.accent))
            }
        }
    }
    
    private func loadState() {
        if let savedState = surveyStore.surveyStates[survey.id] {
            surveyState = savedState
            selectedAnswer = surveyState.selectedAnswers[surveyState.currentQuestionIndex]
        }
    }
    
    private func saveState() {
        surveyStore.surveyStates[survey.id] = surveyState
        surveyStore.saveStates()
    }
}

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
