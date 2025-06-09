import SwiftUI

struct HomePage: View {
    @EnvironmentObject var surveyStore: SurveyStore
    @State private var showProfile = false
    @State private var searchText = ""
    @Binding var isLoggedIn: Bool

    private var filteredSurveys: [SurveyModel] {
        surveyStore.availableSurveys.filter { survey in
            guard let state = surveyStore.surveyProgressStates[survey.id] else {
                return true // never started
            }
            return state.progress == 0 && !state.isCompleted
        }.filter {
            searchText.isEmpty || $0.title.localizedCaseInsensitiveContains(searchText)
        }
    }

    var body: some View {
        NavigationStack {
            content
                .sheet(isPresented: $showProfile) {
                    ProfilePage(isLoggedIn: $isLoggedIn)
                }
        }
    }

    private var content: some View {
        VStack(alignment: .leading, spacing: 0) {
            topBar
            searchBar
            surveySection
        }
        .background(AppColors.background.ignoresSafeArea())
    }

    private var topBar: some View {
        HStack {
            profileButton
            Spacer()
            Text("Home")
                .font(.system(size: 20, weight: .semibold))
                .foregroundColor(AppColors.textPrimary)
            Spacer()
            notificationIcons
        }
        .padding()
    }

    private var profileButton: some View {
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

    private var notificationIcons: some View {
        HStack(spacing: 18) {
            Image(systemName: "chart.bar")
            Image(systemName: "bell")
        }
        .font(.system(size: 18))
        .foregroundColor(AppColors.textSecondary)
    }

    private var searchBar: some View {
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

    private var surveySection: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 0) {
                header(title: "Today's Surveys", subtitle: "\(filteredSurveys.count) upcoming surveys")
                header(title: "All Surveys", subtitle: nil)
                surveyList
            }
        }
    }

    private func header(title: String, subtitle: String?) -> some View {
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

    private var surveyList: some View {
        VStack(spacing: 18) {
            ForEach(filteredSurveys) { survey in
                let progress = surveyStore.surveyProgressStates[survey.id] ?? SurveyProgress()
                NavigationLink(destination: SurveyView(survey: survey)) {
                    SurveyCardView(survey: survey, progress: progress)
                }
            }
        }
        .padding()
    }
}
