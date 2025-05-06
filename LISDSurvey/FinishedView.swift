import SwiftUI

struct FinishedView: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            ScrollView {
                VStack(alignment: .leading, spacing: 0) {
                    Text("Completed Surveys")
                        .font(.system(size: 26, weight: .bold))
                        .foregroundColor(.black)
                        .padding(.horizontal)
                        .padding(.top, 24)

                    Text("1 completed survey")
                        .font(.system(size: 15))
                        .foregroundColor(.gray)
                        .padding(.horizontal)
                        .padding(.top, 1)

                    VStack(spacing: 18) {
                        SurveyCardView(image: "car", title: "Travel Survey", progress: 5, total: 5)
                    }
                    .padding(.horizontal)
                    .padding(.top, 16)
                }
            }
        }
        .background(Color(.systemGray6).ignoresSafeArea())
    }
}
