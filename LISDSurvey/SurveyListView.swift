import SwiftUI

struct SurveyListView: View {
    @EnvironmentObject var surveyStore: SurveyStore
    let surveys: [SurveyModel]
    
    var body: some View {
        VStack(spacing: 18) {
            ForEach(surveys) { survey in
                let progress = surveyStore.surveyProgressStates[survey.id] ?? SurveyProgress()
                NavigationLink(destination: SurveyView(survey: survey)) {
                    SurveyCardView(survey: survey, progress: progress)
                }
            }
        }
        .padding(.horizontal)
        .padding(.top, 16)
        .padding(.bottom, 24)
    }
}
