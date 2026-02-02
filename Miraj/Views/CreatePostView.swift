//
//  CreatePostView.swift
//  Miraj
//
//  Created by Sijan Shrestha on 2/1/26.
//

import SwiftUI
import Photos
import ParseSwift
import CoreLocation

struct CreatePostView: View {
    @State private var selectedImageData: Data?
    @State private var caption = ""
    @State private var isUploading = false
    @State private var showSuccess = false
    @State private var showError = false
    @State private var errorMessage = ""
    @State private var showCaptionStep = false
    @State private var photos: [PHAsset] = []
    @State private var authorizationStatus: PHAuthorizationStatus = .notDetermined
    @State private var selectedAsset: PHAsset?
    @State private var locationName: String?
    @State private var latitude: Double?
    @State private var longitude: Double?
    
    private let imageManager = PHCachingImageManager()
    private let geocoder = CLGeocoder()
    
    var body: some View {
        NavigationView {
            ZStack {
                Color.black
                    .ignoresSafeArea()
                
                if showCaptionStep, let imageData = selectedImageData, let uiImage = UIImage(data: imageData) {
                    captionView(uiImage: uiImage)
                } else {
                    photoSelectionView
                }
            }
            .navigationTitle(showCaptionStep ? "New Post" : "Select Photo")
            .navigationBarTitleDisplayMode(.inline)
            .toolbarColorScheme(.dark, for: .navigationBar)
            .toolbarBackground(Color.black, for: .navigationBar)
            .toolbarBackground(.visible, for: .navigationBar)
            .toolbar {
                if showCaptionStep {
                    ToolbarItem(placement: .navigationBarLeading) {
                        Button("Back") {
                            showCaptionStep = false
                        }
                        .foregroundColor(.white)
                    }
                }
                
                if !showCaptionStep && selectedImageData != nil {
                    ToolbarItem(placement: .navigationBarTrailing) {
                        Button("Next") {
                            showCaptionStep = true
                        }
                        .foregroundColor(.white)
                        .fontWeight(.semibold)
                    }
                }
            }
        }
        .onAppear {
            requestPhotoAccess()
        }
        .alert("Success!", isPresented: $showSuccess) {
            Button("OK", role: .cancel) {
                resetForm()
            }
        } message: {
            Text("Your post has been shared!")
        }
        .alert("Upload Error", isPresented: $showError) {
            Button("OK", role: .cancel) { }
        } message: {
            Text(errorMessage)
        }
    }
    
    // MARK: - Photo Selection View
    private var photoSelectionView: some View {
        VStack(spacing: 0) {
            // Top: Selected photo preview
            if let imageData = selectedImageData, let uiImage = UIImage(data: imageData) {
                ZStack(alignment: .bottomLeading) {
                    Image(uiImage: uiImage)
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(maxWidth: .infinity)
                        .frame(height: UIScreen.main.bounds.height * 0.4)
                        .clipped()
                        .background(Color.black)
                    
                    // Location badge
                    if let location = locationName {
                        HStack(spacing: 4) {
                            Image(systemName: "location.fill")
                                .font(.system(size: 10))
                            Text(location)
                                .font(.caption)
                                .lineLimit(1)
                        }
                        .foregroundColor(.white)
                        .padding(.horizontal, 10)
                        .padding(.vertical, 6)
                        .background(Color.black.opacity(0.6))
                        .cornerRadius(12)
                        .padding(12)
                    }
                }
            } else {
                Rectangle()
                    .fill(Color.white.opacity(0.05))
                    .frame(height: UIScreen.main.bounds.height * 0.4)
                    .overlay(
                        VStack(spacing: 12) {
                            Image(systemName: "photo.on.rectangle")
                                .font(.system(size: 50))
                                .foregroundColor(.gray)
                            Text("Select a photo")
                                .foregroundColor(.gray)
                        }
                    )
            }
            
            Divider()
                .background(Color.white.opacity(0.2))
            
            // Bottom: Photo gallery
            if authorizationStatus == .authorized || authorizationStatus == .limited {
                ScrollView {
                    LazyVGrid(columns: [
                        GridItem(.flexible(), spacing: 2),
                        GridItem(.flexible(), spacing: 2),
                        GridItem(.flexible(), spacing: 2),
                        GridItem(.flexible(), spacing: 2)
                    ], spacing: 2) {
                        ForEach(photos, id: \.localIdentifier) { asset in
                            PhotoThumbnailView(
                                asset: asset,
                                imageManager: imageManager,
                                isSelected: selectedAsset?.localIdentifier == asset.localIdentifier
                            ) {
                                selectPhoto(asset: asset)
                            }
                        }
                    }
                }
                .background(Color.black)
            } else if authorizationStatus == .denied || authorizationStatus == .restricted {
                VStack(spacing: 16) {
                    Image(systemName: "photo.badge.exclamationmark")
                        .font(.system(size: 40))
                        .foregroundColor(.gray)
                    Text("Photo access denied")
                        .foregroundColor(.gray)
                    Text("Enable access in Settings")
                        .font(.caption)
                        .foregroundColor(.gray.opacity(0.7))
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .background(Color.black)
            } else {
                ProgressView()
                    .progressViewStyle(CircularProgressViewStyle(tint: .white))
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .background(Color.black)
            }
        }
    }
    
    // MARK: - Caption View
    private func captionView(uiImage: UIImage) -> some View {
        ScrollView {
            VStack(spacing: 20) {
                // Photo preview with location
                ZStack(alignment: .bottomLeading) {
                    Image(uiImage: uiImage)
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(maxWidth: .infinity)
                        .frame(maxHeight: 300)
                        .clipShape(RoundedRectangle(cornerRadius: 16))
                    
                    if let location = locationName {
                        HStack(spacing: 4) {
                            Image(systemName: "location.fill")
                                .font(.system(size: 10))
                            Text(location)
                                .font(.caption)
                                .lineLimit(1)
                        }
                        .foregroundColor(.white)
                        .padding(.horizontal, 10)
                        .padding(.vertical, 6)
                        .background(Color.black.opacity(0.6))
                        .cornerRadius(12)
                        .padding(12)
                    }
                }
                .padding(.horizontal)
                
                // Caption input
                VStack(alignment: .leading, spacing: 8) {
                    Text("Caption (optional)")
                        .font(.subheadline)
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
                
                Spacer(minLength: 40)
                
                // Post button
                Button(action: uploadPost) {
                    ZStack {
                        RoundedRectangle(cornerRadius: 12)
                            .fill(Color.white)
                            .frame(height: 50)
                        
                        if isUploading {
                            HStack(spacing: 10) {
                                ProgressView()
                                    .progressViewStyle(CircularProgressViewStyle(tint: .black))
                                Text("Posting...")
                                    .foregroundColor(.black)
                            }
                        } else {
                            HStack {
                                Image(systemName: "arrow.up.circle.fill")
                                Text("Post")
                            }
                            .font(.headline)
                            .foregroundColor(.black)
                        }
                    }
                }
                .disabled(isUploading)
                .padding(.horizontal, 32)
                .padding(.bottom, 40)
            }
            .padding(.top)
        }
    }
    
    // MARK: - Photo Access
    private func requestPhotoAccess() {
        PHPhotoLibrary.requestAuthorization(for: .readWrite) { status in
            DispatchQueue.main.async {
                authorizationStatus = status
                if status == .authorized || status == .limited {
                    fetchPhotos()
                }
            }
        }
    }
    
    private func fetchPhotos() {
        let fetchOptions = PHFetchOptions()
        fetchOptions.sortDescriptors = [NSSortDescriptor(key: "creationDate", ascending: false)]
        fetchOptions.fetchLimit = 100
        
        let results = PHAsset.fetchAssets(with: .image, options: fetchOptions)
        var assets: [PHAsset] = []
        results.enumerateObjects { asset, _, _ in
            assets.append(asset)
        }
        
        DispatchQueue.main.async {
            self.photos = assets
            if let firstAsset = assets.first, self.selectedImageData == nil {
                selectPhoto(asset: firstAsset)
            }
        }
    }
    
    private func selectPhoto(asset: PHAsset) {
        selectedAsset = asset
        
        // Extract location from asset
        extractLocation(from: asset)
        
        // Load image
        let options = PHImageRequestOptions()
        options.deliveryMode = .highQualityFormat
        options.isNetworkAccessAllowed = true
        options.isSynchronous = false
        
        let targetSize = CGSize(width: asset.pixelWidth, height: asset.pixelHeight)
        
        imageManager.requestImage(for: asset, targetSize: targetSize, contentMode: .aspectFit, options: options) { image, _ in
            DispatchQueue.main.async {
                if let image = image, let data = image.jpegData(compressionQuality: 0.9) {
                    self.selectedImageData = data
                }
            }
        }
    }
    
    private func extractLocation(from asset: PHAsset) {
        // Reset location
        locationName = nil
        latitude = nil
        longitude = nil
        
        guard let location = asset.location else { return }
        
        latitude = location.coordinate.latitude
        longitude = location.coordinate.longitude
        
        // Reverse geocode to get location name
        geocoder.reverseGeocodeLocation(location) { placemarks, error in
            DispatchQueue.main.async {
                if let placemark = placemarks?.first {
                    var parts: [String] = []
                    if let locality = placemark.locality {
                        parts.append(locality)
                    }
                    if let country = placemark.country, parts.isEmpty {
                        parts.append(country)
                    } else if let state = placemark.administrativeArea, parts.count == 1 {
                        parts.append(state)
                    }
                    self.locationName = parts.joined(separator: ", ")
                }
            }
        }
    }
    
    private func uploadPost() {
        guard let imageData = selectedImageData else { return }
        guard let currentUser = User.current else {
            errorMessage = "You must be logged in to post"
            showError = true
            return
        }
        
        isUploading = true
        
        let imageFile = ParseFile(name: "post_\(UUID().uuidString).jpg", data: imageData)
        
        var post = Post()
        post.imageFile = imageFile
        post.caption = caption.isEmpty ? nil : caption
        post.user = try? currentUser.toPointer()
        post.username = currentUser.username
        post.locationName = locationName
        post.latitude = latitude
        post.longitude = longitude
        
        post.save { result in
            DispatchQueue.main.async {
                isUploading = false
                
                switch result {
                case .success:
                    showSuccess = true
                case .failure(let error):
                    errorMessage = error.localizedDescription
                    showError = true
                }
            }
        }
    }
    
    private func resetForm() {
        selectedImageData = nil
        caption = ""
        showCaptionStep = false
        locationName = nil
        latitude = nil
        longitude = nil
        selectedAsset = nil
        
        if let firstAsset = photos.first {
            selectPhoto(asset: firstAsset)
        }
    }
}

// MARK: - Photo Thumbnail View
struct PhotoThumbnailView: View {
    let asset: PHAsset
    let imageManager: PHCachingImageManager
    let isSelected: Bool
    let onTap: () -> Void
    
    @State private var thumbnail: UIImage?
    
    var body: some View {
        Button(action: onTap) {
            ZStack {
                if let thumbnail = thumbnail {
                    Image(uiImage: thumbnail)
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .frame(width: (UIScreen.main.bounds.width - 6) / 4, height: (UIScreen.main.bounds.width - 6) / 4)
                        .clipped()
                } else {
                    Rectangle()
                        .fill(Color.white.opacity(0.1))
                        .frame(width: (UIScreen.main.bounds.width - 6) / 4, height: (UIScreen.main.bounds.width - 6) / 4)
                }
                
                // Selection indicator
                if isSelected {
                    RoundedRectangle(cornerRadius: 0)
                        .stroke(Color.white, lineWidth: 3)
                }
            }
        }
        .buttonStyle(PlainButtonStyle())
        .onAppear {
            loadThumbnail()
        }
    }
    
    private func loadThumbnail() {
        let size = CGSize(width: 200, height: 200)
        let options = PHImageRequestOptions()
        options.deliveryMode = .opportunistic
        options.isNetworkAccessAllowed = true
        
        imageManager.requestImage(for: asset, targetSize: size, contentMode: .aspectFill, options: options) { image, _ in
            DispatchQueue.main.async {
                self.thumbnail = image
            }
        }
    }
}

#Preview {
    CreatePostView()
}
