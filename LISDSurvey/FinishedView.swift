import SwiftUI

struct FinishedView: View {
    private var completedSurveys: [Survey] {
        Survey.mockSurveys.filter { $0.progress == $0.total }
    }
    
    var body: some View {
        NavigationStack {
            VStack(alignment: .leading, spacing: 0) {
                ScrollView {
                    VStack(alignment: .leading, spacing: 0) {
                        HeaderView(
                            title: "Completed Surveys",
                            subtitle: "\(completedSurveys.count) completed surveys"
                        )
                        
                        SurveyListView(surveys: completedSurveys)
                    }
                }
            }
            .background(AppColors.background.ignoresSafeArea())
        }
    }
}

// Add these components at the bottom of the file
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

private struct SurveyListView: View {
    let surveys: [Survey]
    
    var body: some View {
        VStack(spacing: 18) {
            ForEach(surveys) { survey in
                SurveyCardView(survey: survey)
            }
        }
        .padding(.horizontal)
        .padding(.top, 16)
        .padding(.bottom, 24)
    }
}

#Preview {
    FinishedView()
}
