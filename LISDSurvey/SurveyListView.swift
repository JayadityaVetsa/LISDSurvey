import SwiftUI

struct SurveyListView: View {
    @EnvironmentObject var surveyStore: SurveyStore
    let surveys: [SurveyModel]

    var body: some View {
        let filteredSurveys = surveys.filter { survey in
            let isLocallyCompleted = surveyStore.surveyProgressStates[survey.id]?.isCompleted ?? false
            let isRemotelyCompleted = surveyStore.completedSurveyIds.contains(survey.id)
            return !isLocallyCompleted && !isRemotelyCompleted
        }

        VStack(spacing: 18) {
            ForEach(filteredSurveys) { survey in
                let progress = surveyStore.surveyProgressStates[survey.id] ?? SurveyProgress()
                NavigationLink(destination: SurveyView(survey: survey)) {
                    SurveyCardView(survey: survey, progress: progress)
                }
                .buttonStyle(PlainButtonStyle())
            }
        }
        .padding(.horizontal)
        .padding(.top, 16)
        .padding(.bottom, 24)
    }
}
