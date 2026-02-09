//
//  FeedView.swift
//  Miraj
//
//  Created by Sijan Shrestha on 2/1/26.
//

import SwiftUI
import ParseSwift

struct FeedView: View {
    @State private var posts: [Post] = []
    @State private var isLoading = true
    @State private var showError = false
    @State private var errorMessage = ""
    @State private var userLastPostedAt: Date?
    @State private var hasPosted = false

    var body: some View {
        NavigationView {
            ZStack {
                Color.black
                    .ignoresSafeArea()

                if isLoading {
                    ProgressView("Loading posts...")
                        .progressViewStyle(CircularProgressViewStyle(tint: .white))
                        .foregroundColor(.white)
                } else if posts.isEmpty {
                    VStack(spacing: 16) {
                        Image(systemName: "photo.on.rectangle.angled")
                            .font(.system(size: 60))
                            .foregroundColor(.gray)
                        Text("No posts yet")
                            .font(.title2)
                            .foregroundColor(.gray)
                        Text("Be the first to share your moment!")
                            .font(.subheadline)
                            .foregroundColor(.gray.opacity(0.7))
                    }
                } else {
                    ScrollView(.vertical, showsIndicators: true) {
                        LazyVStack(spacing: 16) {
                            ForEach(Array(posts.enumerated()), id: \.element.objectId) { index, post in
                                let shouldBlur = shouldBlurPost(post)
                                ZStack {
                                    PostRowView(post: post) { updatedPost in
                                        if let idx = posts.firstIndex(where: { $0.objectId == updatedPost.objectId }) {
                                            posts[idx] = updatedPost
                                        }
                                    }
                                    .blur(radius: shouldBlur ? 15 : 0)
                                    .allowsHitTesting(!shouldBlur)

                                    if shouldBlur {
                                        VStack(spacing: 8) {
                                            Image(systemName: "eye.slash.fill")
                                                .font(.system(size: 30))
                                                .foregroundColor(.white)
                                            Text("Post to reveal")
                                                .font(.subheadline)
                                                .fontWeight(.semibold)
                                                .foregroundColor(.white)
                                            Text("Share your own photo to see this post")
                                                .font(.caption)
                                                .foregroundColor(.gray)
                                        }
                                        .frame(maxWidth: .infinity)
                                        .padding(.vertical, 60)
                                    }
                                }
                            }
                        }
                        .padding(.horizontal)
                        .padding(.top, 8)
                        .padding(.bottom, 20)
                    }
                    .scrollIndicators(.visible)
                    .refreshable {
                        await refreshPosts()
                    }
                }
            }
            .navigationTitle("miraj")
            .navigationBarTitleDisplayMode(.inline)
            .toolbarColorScheme(.dark, for: .navigationBar)
            .toolbarBackground(Color.black, for: .navigationBar)
            .toolbarBackground(.visible, for: .navigationBar)
        }
        .onAppear {
            loadUserPostStatus()
        }
        .alert("Error", isPresented: $showError) {
            Button("OK", role: .cancel) { }
        } message: {
            Text(errorMessage)
        }
    }

    /// Determines if a post should be blurred.
    /// - If the user has never posted, blur all other users' posts.
    /// - If the user has posted, only show posts whose createdAt is within 24 hours of the user's lastPostedAt.
    private func shouldBlurPost(_ post: Post) -> Bool {
        // Never blur your own posts
        if let currentUserId = User.current?.objectId,
           let postUserId = post.user?.objectId,
           currentUserId == postUserId {
            return false
        }

        // If user hasn't posted yet, blur everything from others
        guard hasPosted, let lastPosted = userLastPostedAt else {
            return true
        }

        // Only show if the post's createdAt is within 24 hours of the user's last post
        guard let postCreatedAt = post.createdAt else {
            return true
        }

        let timeDifference = abs(postCreatedAt.timeIntervalSince(lastPosted))
        let twentyFourHours: TimeInterval = 24 * 60 * 60
        return timeDifference > twentyFourHours
    }

    private func loadUserPostStatus() {
        // Fetch the current user's lastPostedAt
        if let currentUser = User.current {
            userLastPostedAt = currentUser.lastPostedAt
            hasPosted = currentUser.lastPostedAt != nil

            // Also re-fetch user from server to get latest lastPostedAt
            let userQuery = User.query("objectId" == (currentUser.objectId ?? ""))
            userQuery.first { result in
                DispatchQueue.main.async {
                    switch result {
                    case .success(let freshUser):
                        self.userLastPostedAt = freshUser.lastPostedAt
                        self.hasPosted = freshUser.lastPostedAt != nil
                    case .failure:
                        break
                    }
                    self.fetchPosts()
                }
            }
        } else {
            fetchPosts()
        }
    }

    private func fetchPosts() {
        isLoading = true

        // Fetch the 10 most recent posts within the last 24 hours
        let twentyFourHoursAgo = Calendar.current.date(byAdding: .hour, value: -24, to: Date()) ?? Date()

        let query = Post.query()
            .where("createdAt" >= twentyFourHoursAgo)
            .order([.descending("createdAt")])
            .limit(10)

        query.find { result in
            DispatchQueue.main.async {
                isLoading = false

                switch result {
                case .success(let fetchedPosts):
                    posts = fetchedPosts
                case .failure(let error):
                    errorMessage = error.localizedDescription
                    showError = true
                }
            }
        }
    }

    private func refreshPosts() async {
        // Re-fetch user status
        if let currentUser = User.current {
            let userQuery = User.query("objectId" == (currentUser.objectId ?? ""))
            if let freshUser = try? await userQuery.first() {
                await MainActor.run {
                    self.userLastPostedAt = freshUser.lastPostedAt
                    self.hasPosted = freshUser.lastPostedAt != nil
                }
            }
        }

        let twentyFourHoursAgo = Calendar.current.date(byAdding: .hour, value: -24, to: Date()) ?? Date()

        let query = Post.query()
            .where("createdAt" >= twentyFourHoursAgo)
            .order([.descending("createdAt")])
            .limit(10)

        do {
            let fetchedPosts = try await query.find()
            await MainActor.run {
                posts = fetchedPosts
            }
        } catch {
            await MainActor.run {
                errorMessage = error.localizedDescription
                showError = true
            }
        }
    }
}

#Preview {
    FeedView()
}
