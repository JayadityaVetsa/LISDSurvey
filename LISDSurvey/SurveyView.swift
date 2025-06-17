// SurveyView.swift
// LISDSurvey – updated to show human‑readable countdown (e.g. "Closes in: 1d 2h")

import SwiftUI
import FirebaseAuth

struct SurveyView: View {
    @Environment(\.dismiss) var dismiss
    @EnvironmentObject var surveyStore: SurveyStore

    let survey: SurveyModel

    // MARK: – Local UI State
    @State private var hasWatchedVideo = false
    @State private var selectedAnswer: String = ""
    @State private var timerText: String = ""
    @State private var timer: Timer?
    @State private var hasExpired = false

    // Current progress or a fresh stub
    private var currentProgress: SurveyProgress {
        surveyStore.surveyProgressStates[survey.id] ?? SurveyProgress()
    }

    // MARK: – Timer helpers
    private func updateTimerText() {
        let now = Date()

        // Not yet started
        if now < survey.startTime {
            timerText = "Survey starts at \(formattedDate(survey.startTime))"
            return
        }

        // Expired
        if now > survey.endTime {
            timerText = "Survey ended at \(formattedDate(survey.endTime))"
            hasExpired = true
            timer?.invalidate()
            surveyStore.markSurveyAsExpired(surveyId: survey.id)
            return
        }

        // Active → show friendly remaining time
        let remaining = survey.endTime.timeIntervalSince(now)
        timerText = "Closes in: \(formattedRemaining(remaining))"
    }

    /// "6d 4h" → when > 24h, "2h 15m" → when > 1h, else "45m"
    private func formattedRemaining(_ interval: TimeInterval) -> String {
        let totalMinutes = Int(interval / 60)
        let days = totalMinutes / 1440
        let hours = (totalMinutes % 1440) / 60
        let minutes = totalMinutes % 60

        if days > 0 {
            return "\(days)d \(hours)h"
        } else if hours > 0 {
            return "\(hours)h \(minutes)m"
        } else {
            return "\(minutes)m"
        }
    }

    private func formattedDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .short
        formatter.timeStyle = .short
        formatter.timeZone = .current
        return formatter.string(from: date)
    }

    // MARK: – View Body
    var body: some View {
        if surveyStore.completedSurveyIds.contains(survey.id) || currentProgress.isCompleted {
            CompletedView
        } else if hasExpired {
            ExpiredView
        } else {
            ActiveSurveyView
        }
    }

    // ─────────────────────────────────────────────────────────────
    // MARK: – Sub‑views

    private var CompletedView: some View {
        VStack {
            Text("You've already completed this survey.")
                .font(.title2).fontWeight(.semibold).padding()
            Image(systemName: "checkmark.circle.fill")
                .resizable().frame(width: 60, height: 60)
                .foregroundColor(.green).padding()
        }
        .navigationTitle(survey.title)
        .navigationBarTitleDisplayMode(.inline)
        .background(AppColors.background.ignoresSafeArea())
    }

    private var ExpiredView: some View {
        VStack(spacing: 20) {
            Text("⏰ Survey Time Expired")
                .font(.title2).fontWeight(.bold).padding(.top)
            Text("You didn’t complete this survey in time, but you can still view the results.")
                .multilineTextAlignment(.center).padding(.horizontal)
            Image(systemName: "clock.arrow.circlepath")
                .resizable().frame(width: 60, height: 60)
                .foregroundColor(.orange)
        }
        .padding()
        .navigationTitle(survey.title)
        .navigationBarTitleDisplayMode(.inline)
        .background(AppColors.background.ignoresSafeArea())
    }

    private var ActiveSurveyView: some View {
        VStack(spacing: 0) {
            if !hasWatchedVideo {
                VideoPlaceholderView(hasWatchedVideo: $hasWatchedVideo)
            } else {
                ProgressHeader
                Text(timerText)
                    .font(.footnote).foregroundColor(.gray).padding(.bottom, 4)
                QuestionView
                Spacer()
                NavigationControls
            }
        }
        .onAppear {
            selectedAnswer = currentProgress.selectedAnswers[currentProgress.currentQuestionIndex] ?? ""
            updateTimerText()
            timer = Timer.scheduledTimer(withTimeInterval: 60, repeats: true) { _ in
                updateTimerText()
            }
        }
        .onDisappear {
            timer?.invalidate(); timer = nil
        }
        .navigationTitle(survey.title)
        .navigationBarTitleDisplayMode(.inline)
        .background(AppColors.background.ignoresSafeArea())
    }

    // MARK: – Header & Question rendering (unchanged except for import fixes)
    private var ProgressHeader: some View {
        let index = currentProgress.currentQuestionIndex + 1
        let total = survey.questions.count
        return VStack {
            Text("\(index)/\(total)")
                .font(.subheadline).foregroundColor(AppColors.textSecondary)
            ProgressView(value: Double(index), total: Double(total))
                .progressViewStyle(LinearProgressViewStyle(tint: AppColors.accent))
        }
        .padding().background(AppColors.cardBackground)
    }

    private var QuestionView: some View {
        let questionIndex = currentProgress.currentQuestionIndex
        guard survey.questions.indices.contains(questionIndex) else {
            return AnyView(Text("Invalid question index").padding())
        }
        let question = survey.questions[questionIndex]
        return AnyView(VStack(alignment: .leading, spacing: 25) {
            Text(question.text).font(.title2).fontWeight(.bold)
            Group {
                if question.type == .multipleChoice {
                    ForEach(question.options, id: \ .self) { option in
                        AnswerOption(option: option)
                    }
                } else if question.type == .freeResponse {
                    TextEditor(text: Binding(get: { selectedAnswer }, set: { newVal in
                        selectedAnswer = newVal
                        var updated = currentProgress
                        updated.selectedAnswers[updated.currentQuestionIndex] = newVal
                        surveyStore.surveyProgressStates[survey.id] = updated
                        surveyStore.saveProgress(surveyId: survey.id, progress: updated)
                    }))
                    .frame(height: 150).padding()
                    .background(AppColors.cardBackground)
                    .cornerRadius(12)
                    .overlay(RoundedRectangle(cornerRadius: 12).stroke(AppColors.primary.opacity(0.2), lineWidth: 1))
                }
            }
        }.padding(.horizontal))
    }

    private func AnswerOption(option: String) -> some View {
        Button {
            selectedAnswer = option
            var updated = currentProgress
            updated.selectedAnswers[updated.currentQuestionIndex] = option
            surveyStore.surveyProgressStates[survey.id] = updated
            surveyStore.saveProgress(surveyId: survey.id, progress: updated)
        } label: {
            HStack {
                Text(option).foregroundColor(selectedAnswer == option ? .white : AppColors.textPrimary)
                Spacer()
                if selectedAnswer == option {
                    Image(systemName: "checkmark.circle.fill").foregroundColor(.white)
                }
            }
            .padding()
            .background(RoundedRectangle(cornerRadius: 12).fill(selectedAnswer == option ? AppColors.accent : AppColors.cardBackground))
            .overlay(RoundedRectangle(cornerRadius: 12).stroke(AppColors.primary.opacity(0.2), lineWidth: 1))
        }
    }

    // MARK: – Navigation controls (unchanged)
    private var NavigationControls: some View {
        HStack {
            if currentProgress.currentQuestionIndex > 0 {
                Button("Previous") {
                    var updated = currentProgress
                    updated.currentQuestionIndex -= 1
                    selectedAnswer = updated.selectedAnswers[updated.currentQuestionIndex] ?? ""
                    surveyStore.surveyProgressStates[survey.id] = updated
                    surveyStore.saveProgress(surveyId: survey.id, progress: updated)
                }
                .buttonStyle(SurveyButtonStyle(backgroundColor: AppColors.primary))
            }
            Spacer()
            if currentProgress.currentQuestionIndex < survey.questions.count - 1 {
                Button("Next") {
                    var updated = currentProgress
                    updated.currentQuestionIndex += 1
                    selectedAnswer = updated.selectedAnswers[updated.currentQuestionIndex] ?? ""
                    surveyStore.surveyProgressStates[survey.id] = updated
                    surveyStore.saveProgress(surveyId: survey.id, progress: updated)
                }
                .buttonStyle(SurveyButtonStyle(backgroundColor: AppColors.accent))
            } else {
                Button("Submit") {
                    let finalProgress = currentProgress
                    surveyStore.submitSurvey(surveyId: survey.id, answers: finalProgress.selectedAnswers)
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                        surveyStore.loadSurveyProgress()
                    }
                    dismiss()
                }
                .buttonStyle(SurveyButtonStyle(backgroundColor: AppColors.accent))
            }
        }
        .padding()
    }
}

// MARK: – Styles & Placeholder (unchanged from your original)
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
                .font(.title2).fontWeight(.bold).padding(.top)
            RoundedRectangle(cornerRadius: 16)
                .fill(Color.gray.opacity(0.3)).frame(height: 200)
                .overlay(Image(systemName: "play.rectangle.fill").resizable().scaledToFit().frame(width: 60).foregroundColor(.gray))
                .padding()
            Button(action: { hasWatchedVideo = true }) {
                Text("Start Survey").frame(maxWidth: .infinity)
            }
            .buttonStyle(SurveyButtonStyle(backgroundColor: AppColors.accent))
            .padding(.horizontal)
        }.padding()
    }
}
