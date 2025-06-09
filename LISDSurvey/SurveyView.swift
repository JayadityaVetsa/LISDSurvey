import SwiftUI
import FirebaseAuth
import FirebaseFirestore

struct SurveyView: View {
    @Environment(\.dismiss) var dismiss
    @EnvironmentObject var surveyStore: SurveyStore

    let survey: SurveyModel

    @State private var hasWatchedVideo = false
    @State private var selectedAnswer: String?

    private var currentUserID: String? {
        Auth.auth().currentUser?.uid
    }

    private var currentProgress: SurveyProgress {
        surveyStore.surveyProgressStates[survey.id] ?? SurveyProgress()
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
        .onAppear {
            selectedAnswer = currentProgress.selectedAnswers[currentProgress.currentQuestionIndex]
        }
        .navigationTitle(survey.title)
        .navigationBarTitleDisplayMode(.inline)
        .background(AppColors.background.ignoresSafeArea())
    }

    private var ProgressHeader: some View {
        let index = currentProgress.currentQuestionIndex + 1
        let total = survey.questions.count

        return VStack {
            Text("\(index)/\(total)")
                .font(.subheadline)
                .foregroundColor(AppColors.textSecondary)

            ProgressView(value: Double(index), total: Double(total))
                .progressViewStyle(LinearProgressViewStyle(tint: AppColors.accent))
        }
        .padding()
        .background(AppColors.cardBackground)
    }

    private var QuestionView: some View {
        VStack(alignment: .leading, spacing: 25) {
            Text(survey.questions[currentProgress.currentQuestionIndex].text)
                .font(.title2)
                .fontWeight(.bold)

            ForEach(survey.questions[currentProgress.currentQuestionIndex].options, id: \.self) { option in
                AnswerOption(option: option)
            }
        }
    }

    private func AnswerOption(option: String) -> some View {
        Button {
            selectedAnswer = option
            var updated = currentProgress
            updated.selectedAnswers[updated.currentQuestionIndex] = option
            surveyStore.surveyProgressStates[survey.id] = updated
            surveyStore.persistProgress()
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
            if currentProgress.currentQuestionIndex > 0 {
                Button("Previous") {
                    var updated = currentProgress
                    updated.currentQuestionIndex -= 1
                    selectedAnswer = updated.selectedAnswers[updated.currentQuestionIndex]
                    surveyStore.surveyProgressStates[survey.id] = updated
                    surveyStore.persistProgress()
                }
                .buttonStyle(SurveyButtonStyle(backgroundColor: AppColors.primary))
            }

            Spacer()

            if currentProgress.currentQuestionIndex < survey.questions.count - 1 {
                Button("Next") {
                    var updated = currentProgress
                    updated.currentQuestionIndex += 1
                    selectedAnswer = updated.selectedAnswers[updated.currentQuestionIndex]
                    surveyStore.surveyProgressStates[survey.id] = updated
                    surveyStore.persistProgress()
                }
                .buttonStyle(SurveyButtonStyle(backgroundColor: AppColors.accent))
            } else {
                Button("Submit") {
                    var updated = currentProgress
                    updated.isCompleted = true
                    surveyStore.surveyProgressStates[survey.id] = updated
                    surveyStore.persistProgress()
                    submitToFirestore(updated)
                    dismiss()
                }
                .buttonStyle(SurveyButtonStyle(backgroundColor: AppColors.accent))
            }
        }
    }

    private func submitToFirestore(_ progress: SurveyProgress) {
        guard let userId = currentUserID else { return }
        let db = Firestore.firestore()

        db.collection("userCompletions")
            .document(userId)
            .collection("surveys")
            .document(survey.id.uuidString)
            .setData([
                "isCompleted": progress.isCompleted,
                "selectedAnswers": progress.selectedAnswers.mapKeys { "\($0)" }
            ]) { error in
                if let error = error {
                    print("Error saving userCompletions: \(error.localizedDescription)")
                }
            }

        let surveyRef = db.collection("surveyResponses").document(survey.id.uuidString)
        for (index, answer) in progress.selectedAnswers {
            surveyRef
                .collection("questions")
                .document("\(index)")
                .collection("answers")
                .addDocument(data: [
                    "option": answer,
                    "userId": userId,
                    "timestamp": Timestamp()
                ]) { error in
                    if let error = error {
                        print("Error adding response: \(error.localizedDescription)")
                    }
                }
        }

        surveyStore.logUserCompletion(userId: userId, surveyId: survey.id, progress: progress)
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

extension Dictionary where Key == Int {
    func mapKeys<T: Hashable>(_ transform: (Key) -> T) -> [T: Value] {
        Dictionary<T, Value>(uniqueKeysWithValues: self.map { (transform($0.key), $0.value) })
    }
}
