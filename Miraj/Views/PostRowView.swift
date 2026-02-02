//
//  PostRowView.swift
//  Miraj
//
//  Created by Sijan Shrestha on 2/1/26.
//

import SwiftUI
import ParseSwift

struct PostRowView: View {
    @State var post: Post
    var onPostUpdated: ((Post) -> Void)?
    
    @State private var imageData: Data?
    @State private var isLoadingImage = true
    @State private var showEditSheet = false
    @State private var showAllComments = false
    @State private var isLiked = false
    @State private var likeCount: Int = 0
    @State private var comments: [Comment] = []
    @State private var newCommentText = ""
    @State private var isSendingComment = false
    @State private var showCommentInput = false
    
    private var displayUsername: String {
        post.username ?? "Unknown"
    }
    
    private var isOwnPost: Bool {
        guard let currentUser = User.current,
              let postUserId = post.user?.objectId else { return false }
        return currentUser.objectId == postUserId
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 0) {
            // Header
            HStack(spacing: 10) {
                Circle()
                    .fill(Color.white.opacity(0.2))
                    .frame(width: 32, height: 32)
                    .overlay(
                        Text(displayUsername.prefix(1).uppercased())
                            .font(.system(size: 14, weight: .bold))
                            .foregroundColor(.white)
                    )
                
                VStack(alignment: .leading, spacing: 1) {
                    Text(displayUsername)
                        .font(.subheadline)
                        .fontWeight(.semibold)
                        .foregroundColor(.white)
                    
                    HStack(spacing: 4) {
                        if let createdAt = post.createdAt {
                            Text(timeAgoString(from: createdAt))
                                .font(.caption2)
                                .foregroundColor(.gray)
                        }
                        
                        if let location = post.locationName, !location.isEmpty {
                            Text("•")
                                .font(.caption2)
                                .foregroundColor(.gray)
                            Image(systemName: "location.fill")
                                .font(.system(size: 8))
                                .foregroundColor(.gray)
                            Text(location)
                                .font(.caption2)
                                .foregroundColor(.gray)
                                .lineLimit(1)
                        }
                    }
                }
                
                Spacer()
                
                if isOwnPost {
                    Button(action: { showEditSheet = true }) {
                        Image(systemName: "ellipsis")
                            .foregroundColor(.gray)
                            .padding(8)
                    }
                }
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 10)
            
            // Post image
            GeometryReader { geometry in
                if isLoadingImage {
                    Rectangle()
                        .fill(Color.white.opacity(0.05))
                        .overlay(
                            ProgressView()
                                .progressViewStyle(CircularProgressViewStyle(tint: .white))
                        )
                } else if let imageData = imageData, let uiImage = UIImage(data: imageData) {
                    Image(uiImage: uiImage)
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: geometry.size.width)
                        .frame(maxHeight: 400)
                        .clipped()
                } else {
                    Rectangle()
                        .fill(Color.white.opacity(0.05))
                        .overlay(
                            Image(systemName: "photo")
                                .font(.system(size: 40))
                                .foregroundColor(.gray)
                        )
                }
            }
            .frame(height: calculateImageHeight())
            .frame(maxHeight: 400)
            .clipped()
            
            // Like and Comment buttons
            HStack(spacing: 20) {
                Button(action: toggleLike) {
                    HStack(spacing: 4) {
                        Image(systemName: isLiked ? "heart.fill" : "heart")
                            .foregroundColor(isLiked ? .red : .white)
                        if likeCount > 0 {
                            Text("\(likeCount)")
                                .font(.subheadline)
                                .foregroundColor(.white)
                        }
                    }
                }
                
                Button(action: { showCommentInput.toggle() }) {
                    HStack(spacing: 4) {
                        Image(systemName: "bubble.right")
                            .foregroundColor(.white)
                        if comments.count > 0 {
                            Text("\(comments.count)")
                                .font(.subheadline)
                                .foregroundColor(.white)
                        }
                    }
                }
                
                Spacer()
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 10)
            
            // Caption
            if let caption = post.caption, !caption.isEmpty {
                Text(caption)
                    .font(.subheadline)
                    .foregroundColor(.white)
                    .padding(.horizontal, 12)
                    .padding(.bottom, 8)
            }
            
            // Inline comments (show up to 3)
            if !comments.isEmpty {
                VStack(alignment: .leading, spacing: 6) {
                    ForEach(comments.prefix(3), id: \.objectId) { comment in
                        HStack(alignment: .top, spacing: 6) {
                            Text(comment.username ?? "Unknown")
                                .font(.subheadline)
                                .fontWeight(.semibold)
                                .foregroundColor(.white)
                            Text(comment.text ?? "")
                                .font(.subheadline)
                                .foregroundColor(.white.opacity(0.85))
                                .lineLimit(2)
                        }
                    }
                    
                    // View all comments button
                    if comments.count > 3 {
                        Button(action: { showAllComments = true }) {
                            Text("View all \(comments.count) comments")
                                .font(.caption)
                                .foregroundColor(.gray)
                        }
                    }
                }
                .padding(.horizontal, 12)
                .padding(.bottom, 8)
            }
            
            // Inline comment input
            if showCommentInput {
                HStack(spacing: 8) {
                    TextField("Add a comment...", text: $newCommentText)
                        .font(.subheadline)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 8)
                        .background(Color.white.opacity(0.1))
                        .cornerRadius(16)
                        .foregroundColor(.white)
                    
                    Button(action: sendComment) {
                        if isSendingComment {
                            ProgressView()
                                .progressViewStyle(CircularProgressViewStyle(tint: .white))
                                .frame(width: 24, height: 24)
                        } else {
                            Text("Post")
                                .font(.subheadline)
                                .fontWeight(.semibold)
                                .foregroundColor(newCommentText.isEmpty ? .gray : .white)
                        }
                    }
                    .disabled(newCommentText.isEmpty || isSendingComment)
                }
                .padding(.horizontal, 12)
                .padding(.bottom, 10)
            }
        }
        .background(Color.white.opacity(0.05))
        .clipShape(RoundedRectangle(cornerRadius: 12))
        .onAppear {
            loadImage()
            loadLikeState()
            fetchComments()
        }
        .sheet(isPresented: $showEditSheet) {
            EditPostView(post: post) { updatedPost in
                post = updatedPost
                onPostUpdated?(updatedPost)
            }
        }
        .sheet(isPresented: $showAllComments) {
            AllCommentsView(post: post, comments: $comments)
        }
    }
    
    private func sendComment() {
        guard let currentUser = User.current,
              !newCommentText.trimmingCharacters(in: .whitespaces).isEmpty else { return }
        
        isSendingComment = true
        
        var comment = Comment()
        comment.text = newCommentText.trimmingCharacters(in: .whitespaces)
        comment.post = try? post.toPointer()
        comment.user = try? currentUser.toPointer()
        comment.username = currentUser.username
        
        let commentText = newCommentText
        newCommentText = ""
        
        comment.save { result in
            DispatchQueue.main.async {
                isSendingComment = false
                switch result {
                case .success(let savedComment):
                    comments.append(savedComment)
                    showCommentInput = false
                case .failure:
                    newCommentText = commentText
                }
            }
        }
    }
    
    private func fetchComments() {
        guard let _ = post.objectId else { return }
        
        do {
            let postPointer = try post.toPointer()
            let query = Comment.query("post" == postPointer)
                .order([.ascending("createdAt")])
            
            query.find { result in
                DispatchQueue.main.async {
                    switch result {
                    case .success(let fetchedComments):
                        comments = fetchedComments
                    case .failure:
                        break
                    }
                }
            }
        } catch {
            // Skip on error
        }
    }
    
    private func toggleLike() {
        guard let currentUserId = User.current?.objectId else { return }
        
        var updatedPost = post
        var likedByArray = updatedPost.likedBy ?? []
        
        if isLiked {
            likedByArray.removeAll { $0 == currentUserId }
            likeCount = max(0, likeCount - 1)
        } else {
            likedByArray.append(currentUserId)
            likeCount += 1
        }
        
        isLiked.toggle()
        updatedPost.likedBy = likedByArray
        updatedPost.likeCount = likeCount
        
        updatedPost.save { result in
            DispatchQueue.main.async {
                switch result {
                case .success(let savedPost):
                    post = savedPost
                    onPostUpdated?(savedPost)
                case .failure:
                    isLiked.toggle()
                    if isLiked {
                        likeCount += 1
                    } else {
                        likeCount = max(0, likeCount - 1)
                    }
                }
            }
        }
    }
    
    private func loadLikeState() {
        likeCount = post.likeCount ?? 0
        if let currentUserId = User.current?.objectId,
           let likedBy = post.likedBy {
            isLiked = likedBy.contains(currentUserId)
        }
    }
    
    private func calculateImageHeight() -> CGFloat {
        guard let imageData = imageData,
              let uiImage = UIImage(data: imageData) else {
            return 300
        }
        
        let screenWidth = UIScreen.main.bounds.width - 32
        let aspectRatio = uiImage.size.height / uiImage.size.width
        let calculatedHeight = screenWidth * aspectRatio
        
        return min(max(calculatedHeight, 200), 400)
    }
    
    private func loadImage() {
        guard let imageFile = post.imageFile else {
            isLoadingImage = false
            return
        }
        
        imageFile.fetch { result in
            DispatchQueue.main.async {
                isLoadingImage = false
                switch result {
                case .success(let file):
                    if let url = file.url {
                        URLSession.shared.dataTask(with: url) { data, _, _ in
                            DispatchQueue.main.async {
                                self.imageData = data
                            }
                        }.resume()
                    }
                case .failure:
                    break
                }
            }
        }
    }
    
    private func timeAgoString(from date: Date) -> String {
        let formatter = RelativeDateTimeFormatter()
        formatter.unitsStyle = .abbreviated
        return formatter.localizedString(for: date, relativeTo: Date())
    }
}

// MARK: - All Comments View
struct AllCommentsView: View {
    @Environment(\.dismiss) var dismiss
    let post: Post
    @Binding var comments: [Comment]
    
    @State private var newCommentText = ""
    @State private var isSending = false
    
    var body: some View {
        NavigationView {
            ZStack {
                Color.black.ignoresSafeArea()
                
                VStack(spacing: 0) {
                    if comments.isEmpty {
                        Spacer()
                        VStack(spacing: 12) {
                            Image(systemName: "bubble.left.and.bubble.right")
                                .font(.system(size: 40))
                                .foregroundColor(.gray)
                            Text("No comments yet")
                                .foregroundColor(.gray)
                        }
                        Spacer()
                    } else {
                        ScrollView {
                            LazyVStack(alignment: .leading, spacing: 12) {
                                ForEach(comments, id: \.objectId) { comment in
                                    HStack(alignment: .top, spacing: 10) {
                                        Circle()
                                            .fill(Color.white.opacity(0.2))
                                            .frame(width: 28, height: 28)
                                            .overlay(
                                                Text((comment.username ?? "?").prefix(1).uppercased())
                                                    .font(.system(size: 12, weight: .bold))
                                                    .foregroundColor(.white)
                                            )
                                        
                                        VStack(alignment: .leading, spacing: 4) {
                                            HStack(spacing: 6) {
                                                Text(comment.username ?? "Unknown")
                                                    .font(.subheadline)
                                                    .fontWeight(.semibold)
                                                    .foregroundColor(.white)
                                                
                                                if let createdAt = comment.createdAt {
                                                    Text(timeAgoString(from: createdAt))
                                                        .font(.caption2)
                                                        .foregroundColor(.gray)
                                                }
                                            }
                                            
                                            Text(comment.text ?? "")
                                                .font(.subheadline)
                                                .foregroundColor(.white.opacity(0.9))
                                        }
                                        
                                        Spacer()
                                    }
                                }
                            }
                            .padding()
                        }
                    }
                    
                    // Comment input
                    HStack(spacing: 12) {
                        TextField("Add a comment...", text: $newCommentText)
                            .padding(.horizontal, 16)
                            .padding(.vertical, 12)
                            .background(Color.white.opacity(0.1))
                            .cornerRadius(20)
                            .foregroundColor(.white)
                        
                        Button(action: sendComment) {
                            if isSending {
                                ProgressView()
                                    .progressViewStyle(CircularProgressViewStyle(tint: .white))
                                    .frame(width: 32, height: 32)
                            } else {
                                Image(systemName: "arrow.up.circle.fill")
                                    .font(.system(size: 32))
                                    .foregroundColor(newCommentText.isEmpty ? .gray : .white)
                            }
                        }
                        .disabled(newCommentText.isEmpty || isSending)
                    }
                    .padding()
                    .background(Color.black)
                }
            }
            .navigationTitle("Comments")
            .navigationBarTitleDisplayMode(.inline)
            .toolbarColorScheme(.dark, for: .navigationBar)
            .toolbarBackground(Color.black, for: .navigationBar)
            .toolbarBackground(.visible, for: .navigationBar)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Close") {
                        dismiss()
                    }
                    .foregroundColor(.white)
                }
            }
        }
    }
    
    private func sendComment() {
        guard let currentUser = User.current,
              !newCommentText.trimmingCharacters(in: .whitespaces).isEmpty else { return }
        
        isSending = true
        
        var comment = Comment()
        comment.text = newCommentText.trimmingCharacters(in: .whitespaces)
        comment.post = try? post.toPointer()
        comment.user = try? currentUser.toPointer()
        comment.username = currentUser.username
        
        let commentText = newCommentText
        newCommentText = ""
        
        comment.save { result in
            DispatchQueue.main.async {
                isSending = false
                switch result {
                case .success(let savedComment):
                    comments.append(savedComment)
                case .failure:
                    newCommentText = commentText
                }
            }
        }
    }
    
    private func timeAgoString(from date: Date) -> String {
        let formatter = RelativeDateTimeFormatter()
        formatter.unitsStyle = .abbreviated
        return formatter.localizedString(for: date, relativeTo: Date())
    }
}

// MARK: - Edit Post View
struct EditPostView: View {
    @Environment(\.dismiss) var dismiss
    let post: Post
    var onSave: ((Post) -> Void)?
    
    @State private var caption: String = ""
    @State private var isSaving = false
    @State private var showError = false
    @State private var errorMessage = ""
    @State private var showDeleteConfirmation = false
    
    var body: some View {
        NavigationView {
            ZStack {
                Color.black.ignoresSafeArea()
                
                VStack(spacing: 20) {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Caption")
                            .font(.caption)
                            .foregroundColor(.gray)
                        
                        TextField("What's happening?", text: $caption, axis: .vertical)
                            .padding()
                            .background(Color.white.opacity(0.1))
                            .cornerRadius(12)
                            .foregroundColor(.white)
                            .overlay(
                                RoundedRectangle(cornerRadius: 12)
                                    .stroke(Color.white.opacity(0.2), lineWidth: 1)
                            )
                            .lineLimit(3...6)
                    }
                    .padding(.horizontal)
                    .padding(.top, 20)
                    
                    Spacer()
                    
                    Button(action: savePost) {
                        ZStack {
                            RoundedRectangle(cornerRadius: 12)
                                .fill(Color.white)
                                .frame(height: 50)
                            
                            if isSaving {
                                ProgressView()
                                    .progressViewStyle(CircularProgressViewStyle(tint: .black))
                            } else {
                                Text("Save Changes")
                                    .font(.headline)
                                    .foregroundColor(.black)
                            }
                        }
                    }
                    .disabled(isSaving)
                    .padding(.horizontal, 32)
                    
                    Button(action: { showDeleteConfirmation = true }) {
                        Text("Delete Post")
                            .font(.subheadline)
                            .foregroundColor(.red)
                    }
                    .padding(.bottom, 40)
                }
            }
            .navigationTitle("Edit Post")
            .navigationBarTitleDisplayMode(.inline)
            .toolbarColorScheme(.dark, for: .navigationBar)
            .toolbarBackground(Color.black, for: .navigationBar)
            .toolbarBackground(.visible, for: .navigationBar)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                    .foregroundColor(.white)
                }
            }
        }
        .onAppear {
            caption = post.caption ?? ""
        }
        .alert("Error", isPresented: $showError) {
            Button("OK", role: .cancel) { }
        } message: {
            Text(errorMessage)
        }
        .confirmationDialog("Delete this post?", isPresented: $showDeleteConfirmation, titleVisibility: .visible) {
            Button("Delete", role: .destructive) {
                deletePost()
            }
            Button("Cancel", role: .cancel) { }
        }
    }
    
    private func savePost() {
        var updatedPost = post
        updatedPost.caption = caption.isEmpty ? nil : caption
        
        isSaving = true
        
        updatedPost.save { result in
            DispatchQueue.main.async {
                isSaving = false
                
                switch result {
                case .success(let savedPost):
                    onSave?(savedPost)
                    dismiss()
                case .failure(let error):
                    errorMessage = error.localizedDescription
                    showError = true
                }
            }
        }
    }
    
    private func deletePost() {
        isSaving = true
        
        post.delete { result in
            DispatchQueue.main.async {
                isSaving = false
                
                switch result {
                case .success:
                    dismiss()
                case .failure(let error):
                    errorMessage = error.localizedDescription
                    showError = true
                }
            }
        }
    }
}

#Preview {
    ZStack {
        Color.black.ignoresSafeArea()
        PostRowView(post: Post())
            .padding()
    }
}
