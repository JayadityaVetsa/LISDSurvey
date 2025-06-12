// SurveyCardView.swift
import SwiftUI

struct SurveyCardView: View {
    let survey: SurveyModel
    let progress: SurveyProgress
    @EnvironmentObject var surveyStore: SurveyStore

    var body: some View {
        NavigationLink(destination: SurveyView(survey: survey)) {
            HStack(spacing: 16) {
                icon
                VStack(alignment: .leading, spacing: 8) {
                    infoSection
                    dateTimeSection
                    CountdownView(endTime: survey.endTime) {
                        surveyStore.markSurveyAsExpired(surveyId: survey.id)
                    }
                }
                Spacer()
            }
            .padding()
            .background(AppColors.cardBackground)
            .cornerRadius(18)
            .shadow(color: AppColors.textSecondary.opacity(0.08), radius: 4, x: 0, y: 2)
        }
        .buttonStyle(PlainButtonStyle())
    }

    private var icon: some View {
        Image(systemName: survey.image)
            .resizable()
            .scaledToFit()
            .frame(width: 44, height: 44)
            .foregroundColor(AppColors.textPrimary)
            .background(AppColors.cardBackground)
            .clipShape(RoundedRectangle(cornerRadius: 12))
            .shadow(color: AppColors.textSecondary.opacity(0.1), radius: 1, x: 0, y: 1)
    }

    private var infoSection: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(survey.title)
                .font(.system(size: 17, weight: .semibold))
                .foregroundColor(AppColors.textPrimary)

            HStack {
                ProgressView(value: Double(progress.progress), total: Double(max(survey.questions.count, 1)))
                    .accentColor(AppColors.accent)
                    .frame(height: 6)
                    .frame(maxWidth: 120)

                Text(progress.isCompleted ? "Completed" : "\(progress.progress)/\(survey.questions.count)")
                    .font(.system(size: 14))
                    .foregroundColor(AppColors.textSecondary)
            }
        }
    }

    private var dateTimeSection: some View {
        VStack(alignment: .leading, spacing: 2) {
            Text("Starts: \(survey.startTime.formatted(date: .abbreviated, time: .shortened))")
                .font(.caption)
                .foregroundColor(.gray)
            Text("Ends: \(survey.endTime.formatted(date: .abbreviated, time: .shortened))")
                .font(.caption)
                .foregroundColor(.gray)
        }
    }
}
