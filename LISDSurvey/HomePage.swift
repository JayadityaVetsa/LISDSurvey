import SwiftUI

struct HomePage: View {
    @State private var showProfile = false
    @State private var searchText = ""

    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            // Top bar with profile
            HStack {
                Button(action: { showProfile = true }) {
                    ZStack {
                        Circle()
                            .fill(Color.gray.opacity(0.2))
                            .frame(width: 38, height: 38)
                        Text("JS")
                            .font(.system(size: 16, weight: .medium))
                            .foregroundColor(.gray)
                    }
                }
                .padding(.leading, 4)
                .sheet(isPresented: $showProfile) {
                    ProfilePage()
                }

                Spacer()
                Text("Home")
                    .font(.system(size: 20, weight: .semibold))
                Spacer()
                HStack(spacing: 18) {
                    Image(systemName: "chart.bar")
                        .font(.system(size: 18))
                        .foregroundColor(.gray)
                    Image(systemName: "bell")
                        .font(.system(size: 18))
                        .foregroundColor(.gray)
                }
                .padding(.trailing, 4)
            }
            .padding(.horizontal)
            .padding(.top, 12)

            // Search bar
            HStack {
                Image(systemName: "magnifyingglass")
                    .foregroundColor(.gray)
                TextField("Search", text: $searchText)
                    .font(.system(size: 16))
            }
            .padding()
            .background(Color.gray.opacity(0.12))
            .cornerRadius(12)
            .padding(.horizontal)
            .padding(.top, 8)

            // Tab bar (Home, Ongoing, Finished) - not needed here, handled by TabView

            // Main content
            ScrollView {
                VStack(alignment: .leading, spacing: 0) {
                    Text("Today's Surveys")
                        .font(.system(size: 26, weight: .bold))
                        .foregroundColor(.black)
                        .padding(.horizontal)
                        .padding(.top, 16)

                    Text("5 upcoming surveys")
                        .font(.system(size: 15))
                        .foregroundColor(.gray)
                        .padding(.horizontal)
                        .padding(.top, 1)

                    SurveyCategoriesView()
                        .padding(.horizontal)
                        .padding(.top, 16)

                    Text("All Surveys")
                        .font(.system(size: 20, weight: .bold))
                        .foregroundColor(.black)
                        .padding(.horizontal)
                        .padding(.top, 24)

                    VStack(spacing: 18) {
                        SurveyCardView(image: "leaf", title: "Food Survey", progress: 4, total: 15)
                        SurveyCardView(image: "person.2", title: "Business survey", progress: 1, total: 10)
                        SurveyCardView(image: "car", title: "Travel Survey", progress: 4, total: 5)
                    }
                    .padding(.horizontal)
                    .padding(.top, 8)
                    .padding(.bottom, 24)
                }
            }
        }
        .background(Color(.systemGray6).ignoresSafeArea())
    }
}

// SurveyCategoriesView and SurveyCardView can be reused across all pages
struct SurveyCategoriesView: View {
    let categories = [
        ("Science", Color(red: 0.80, green: 0.87, blue: 1.0)),
        ("Social", Color(red: 1.0, green: 0.87, blue: 0.87)),
        ("Tech", Color(red: 0.87, green: 1.0, blue: 0.90)),
        ("Gaming", Color(red: 0.80, green: 0.87, blue: 1.0)),
        ("History", Color(red: 1.0, green: 0.87, blue: 0.87)),
        ("Analytics", Color(red: 0.87, green: 1.0, blue: 0.90))
    ]

    var body: some View {
        LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 14) {
            ForEach(categories, id: \.0) { (name, color) in
                Text(name)
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(.black)
                    .padding(.vertical, 14)
                    .frame(maxWidth: .infinity)
                    .background(color)
                    .cornerRadius(16)
            }
        }
    }
}

struct SurveyCardView: View {
    var image: String
    var title: String
    var progress: Int
    var total: Int

    var body: some View {
        HStack(spacing: 16) {
            Image(systemName: image)
                .resizable()
                .scaledToFit()
                .frame(width: 44, height: 44)
                .foregroundColor(.black)
                .background(Color.white)
                .clipShape(RoundedRectangle(cornerRadius: 12))
                .shadow(color: .gray.opacity(0.1), radius: 1, x: 0, y: 1)

            VStack(alignment: .leading, spacing: 6) {
                Text(title)
                    .font(.system(size: 17, weight: .semibold))
                    .foregroundColor(.black)
                HStack {
                    ProgressView(value: Float(progress), total: Float(total))
                        .accentColor(.blue)
                        .frame(height: 6)
                        .frame(maxWidth: 120)
                    Text("\(progress)/\(total)")
                        .font(.system(size: 14))
                        .foregroundColor(.gray)
                }
            }
            Spacer()
        }
        .padding()
        .background(Color.white)
        .cornerRadius(18)
        .shadow(color: .gray.opacity(0.08), radius: 4, x: 0, y: 2)
    }
}

#Preview {
    HomePage()
}
