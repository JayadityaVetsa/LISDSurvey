import SwiftUI

struct OngoingView: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            // Optional: You can add a similar top bar here if you want
            ScrollView {
                VStack(alignment: .leading, spacing: 0) {
                    Text("Ongoing Surveys")
                        .font(.system(size: 26, weight: .bold))
                        .foregroundColor(.black)
                        .padding(.horizontal)
                        .padding(.top, 24)

                    Text("2 surveys in progress")
                        .font(.system(size: 15))
                        .foregroundColor(.gray)
                        .padding(.horizontal)
                        .padding(.top, 1)

                    VStack(spacing: 18) {
                        SurveyCardView(image: "leaf", title: "Food Survey", progress: 4, total: 15)
                        SurveyCardView(image: "person.2", title: "Business survey", progress: 1, total: 10)
                    }
                    .padding(.horizontal)
                    .padding(.top, 16)
                }
            }
        }
        .background(Color(.systemGray6).ignoresSafeArea())
    }
}
