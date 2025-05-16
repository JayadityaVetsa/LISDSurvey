import SwiftUI

struct SurveyListView: View {
    let surveys: [Survey]
    
    var body: some View {
        VStack(spacing: 18) {
            ForEach(surveys) { survey in
                NavigationLink(destination: SurveyView(survey: survey)) {
                    SurveyCardView(survey: survey)
                }
            }
        }
        .padding(.horizontal)
        .padding(.top, 16)
        .padding(.bottom, 24)
    }
}
