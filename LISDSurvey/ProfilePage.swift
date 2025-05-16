import SwiftUI

struct ProfilePage: View {
    @Environment(\.presentationMode) var presentationMode
    @StateObject private var tagViewModel = TagViewModel()

    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                HStack {
                    Button(action: {
                        presentationMode.wrappedValue.dismiss()
                    }) {
                        Image(systemName: "chevron.left")
                            .font(.title2)
                            .foregroundColor(.gray)
                    }
                    Spacer()
                    Button(action: {
                        // Logout logic here
                    }) {
                        Text("Logout")
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundColor(.gray)
                    }
                }
                .padding(.horizontal)
                .padding(.top, 24)

                VStack(spacing: 8) {
                    Image(systemName: "person.crop.circle.fill")
                        .resizable()
                        .frame(width: 88, height: 88)
                        .clipShape(Circle())
                        .background(Circle().fill(Color(.systemGray5)))
                    Text("MME APP")
                        .font(.system(size: 22, weight: .bold))
                    Text("mmeapp@gmail.com")
                        .font(.system(size: 16))
                        .foregroundColor(.gray)
                    Button(action: {}) {
                        Text("Edit profile")
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundColor(.white)
                            .padding(.horizontal, 24)
                            .padding(.vertical, 8)
                            .background(Color.blue)
                            .cornerRadius(20)
                    }
                    .padding(.top, 6)
                }
                .padding(.top, 16)

                Form {
                    Section(header: Text("Content")) {
                        HStack {
                            Image(systemName: "plus.circle")
                                .foregroundColor(.gray)
                            Text("Favorites")
                            Spacer()
                            Image(systemName: "chevron.right")
                                .foregroundColor(.gray.opacity(0.5))
                        }
                        HStack {
                            Image(systemName: "arrow.down.circle")
                                .foregroundColor(.gray)
                            Text("Downloads")
                            Spacer()
                            Image(systemName: "chevron.right")
                                .foregroundColor(.gray.opacity(0.5))
                        }
                    }

                    Section(header: Text("Preferences")) {
                        NavigationLink(destination: TagSelectionView(viewModel: tagViewModel)) {
                            HStack {
                                Image(systemName: "tag")
                                    .foregroundColor(.gray)
                                Text("Tags")
                                Spacer()
                                if !tagViewModel.selectedTags.isEmpty {
                                    Text(tagViewModel.selectedTags.map { $0.name }.joined(separator: ", "))
                                        .foregroundColor(.gray)
                                        .lineLimit(1)
                                }
//                                Image(systemName: "chevron.right")
//                                    .foregroundColor(.gray.opacity(0.5))
                            }
                        }

                        HStack {
                            Image(systemName: "globe")
                                .foregroundColor(.gray)
                            Text("Language")
                            Spacer()
                            Text("English")
                                .foregroundColor(.gray)
                            Image(systemName: "chevron.right")
                                .foregroundColor(.gray.opacity(0.5))
                        }

                        HStack {
                            Image(systemName: "bell")
                                .foregroundColor(.gray)
                            Text("Notifications")
                            Spacer()
                            Text("Enabled")
                                .foregroundColor(.gray)
                            Image(systemName: "chevron.right")
                                .foregroundColor(.gray.opacity(0.5))
                        }

                        HStack {
                            Image(systemName: "paintpalette")
                                .foregroundColor(.gray)
                            Text("Theme")
                            Spacer()
                            Text("Light")
                                .foregroundColor(.gray)
                            Image(systemName: "chevron.right")
                                .foregroundColor(.gray.opacity(0.5))
                        }
                    }
                }
                .padding(.top, 16)
            }
            .background(Color(.systemGray6).ignoresSafeArea())
            .onAppear {
                tagViewModel.loadTags()
            }
        }
    }
}

#Preview {
    ProfilePage()
}
