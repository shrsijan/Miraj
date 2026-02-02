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
                                PostRowView(post: post) { updatedPost in
                                    // Update post in list
                                    if let idx = posts.firstIndex(where: { $0.objectId == updatedPost.objectId }) {
                                        posts[idx] = updatedPost
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
            fetchPosts()
        }
        .alert("Error", isPresented: $showError) {
            Button("OK", role: .cancel) { }
        } message: {
            Text(errorMessage)
        }
    }
    
    private func fetchPosts() {
        isLoading = true
        
        let query = Post.query()
            .order([.descending("createdAt")])
            .limit(50)
        
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
        let query = Post.query()
            .order([.descending("createdAt")])
            .limit(50)
        
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
