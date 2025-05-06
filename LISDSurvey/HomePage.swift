import SwiftUI

struct HomePage: View {
    @State private var showProfile = false
    @State private var searchText = ""
    
    var body: some View {
        NavigationStack {
            content
                .sheet(isPresented: $showProfile) {
                    ProfilePage()
                }
        }
    }
    
    private var content: some View {
        VStack(alignment: .leading, spacing: 0) {
            TopBar
            SearchBar
            SurveyContent
        }
        .background(AppColors.background.ignoresSafeArea())
    }
    
    private var TopBar: some View {
        HStack {
            ProfileButton
            Spacer()
            Title
            Spacer()
            NotificationIcons
        }
        .padding()
    }
    
    private var ProfileButton: some View {
        Button(action: { showProfile = true }) {
            ZStack {
                Circle()
                    .fill(AppColors.textSecondary.opacity(0.2))
                    .frame(width: 38, height: 38)
                Text("JS")
                    .font(.system(size: 16, weight: .medium))
                    .foregroundColor(AppColors.textSecondary)
            }
        }
    }
    
    private var Title: some View {
        Text("Home")
            .font(.system(size: 20, weight: .semibold))
            .foregroundColor(AppColors.textPrimary)
    }
    
    private var NotificationIcons: some View {
        HStack(spacing: 18) {
            Image(systemName: "chart.bar")
            Image(systemName: "bell")
        }
        .font(.system(size: 18))
        .foregroundColor(AppColors.textSecondary)
    }
    
    private var SearchBar: some View {
        HStack {
            Image(systemName: "magnifyingglass")
                .foregroundColor(AppColors.textSecondary)
            TextField("Search", text: $searchText)
                .font(.system(size: 16))
        }
        .padding()
        .background(AppColors.cardBackground)
        .cornerRadius(12)
        .padding(.horizontal)
    }
    
    private var SurveyContent: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 0) {
                Header(title: "Today's Surveys", subtitle: "5 upcoming surveys")
                SurveyCategoriesView()
                Header(title: "All Surveys", subtitle: nil)
                SurveyList
            }
        }
    }
    
    private func Header(title: String, subtitle: String?) -> some View {
        VStack(alignment: .leading, spacing: 1) {
            Text(title)
                .font(.system(size: 26, weight: .bold))
                .padding(.horizontal)
            
            if let subtitle = subtitle {
                Text(subtitle)
                    .font(.system(size: 15))
                    .foregroundColor(AppColors.textSecondary)
                    .padding(.horizontal)
            }
        }
        .padding(.top, 16)
    }
    
    private var SurveyList: some View {
        VStack(spacing: 18) {
            ForEach(Survey.mockSurveys) { survey in
                SurveyCardView(survey: survey)
            }
        }
        .padding()
    }
}

#Preview {
    HomePage()
}
