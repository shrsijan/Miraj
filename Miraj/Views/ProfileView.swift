//
//  ProfileView.swift
//  Miraj
//
//  Created by Sijan Shrestha on 2/1/26.
//

import SwiftUI
import ParseSwift

struct ProfileView: View {
    @Binding var isLoggedIn: Bool
    @State private var showLogoutConfirmation = false
    @State private var showEditProfile = false
    @State private var currentUser: User? = User.current
    
    var body: some View {
        NavigationView {
            ZStack {
                Color.black
                    .ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: 24) {
                        // Avatar
                        Circle()
                            .fill(Color.white)
                            .frame(width: 100, height: 100)
                            .overlay(
                                Text((currentUser?.username?.prefix(1).uppercased() ?? "?"))
                                    .font(.system(size: 40, weight: .bold))
                                    .foregroundColor(.black)
                            )
                        
                        // Username
                        Text("@\(currentUser?.username ?? "user")")
                            .font(.title2)
                            .fontWeight(.bold)
                            .foregroundColor(.white)
                        
                        // Email
                        if let email = currentUser?.email {
                            Text(email)
                                .font(.subheadline)
                                .foregroundColor(.gray)
                        }
                        
                        // Edit Profile Button
                        Button(action: { showEditProfile = true }) {
                            HStack {
                                Image(systemName: "pencil")
                                Text("Edit Profile")
                            }
                            .font(.subheadline)
                            .foregroundColor(.black)
                            .padding(.horizontal, 24)
                            .padding(.vertical, 10)
                            .background(Color.white)
                            .cornerRadius(20)
                        }
                        .padding(.top, 8)
                        
                        Spacer(minLength: 40)
                        
                        // Logout Button
                        Button(action: { showLogoutConfirmation = true }) {
                            HStack {
                                Image(systemName: "rectangle.portrait.and.arrow.right")
                                Text("Log Out")
                            }
                            .font(.headline)
                            .foregroundColor(.red)
                            .padding()
                            .frame(maxWidth: .infinity)
                            .background(Color.red.opacity(0.1))
                            .cornerRadius(12)
                        }
                        .padding(.horizontal, 32)
                    }
                    .padding(.top, 40)
                }
            }
            .navigationTitle("Profile")
            .navigationBarTitleDisplayMode(.inline)
            .toolbarColorScheme(.dark, for: .navigationBar)
            .toolbarBackground(Color.black, for: .navigationBar)
            .toolbarBackground(.visible, for: .navigationBar)
        }
        .sheet(isPresented: $showEditProfile) {
            EditProfileView(currentUser: $currentUser)
        }
        .confirmationDialog("Are you sure you want to log out?", isPresented: $showLogoutConfirmation, titleVisibility: .visible) {
            Button("Log Out", role: .destructive) {
                logout()
            }
            Button("Cancel", role: .cancel) { }
        }
    }
    
    private func logout() {
        NotificationManager.unregisterNotifications()
        User.logout { result in
            DispatchQueue.main.async {
                switch result {
                case .success:
                    isLoggedIn = false
                case .failure(let error):
                    print("Logout error: \(error)")
                    isLoggedIn = false
                }
            }
        }
    }
}

// MARK: - Edit Profile View
struct EditProfileView: View {
    @Environment(\.dismiss) var dismiss
    @Binding var currentUser: User?
    
    @State private var username: String = ""
    @State private var email: String = ""
    @State private var isSaving = false
    @State private var showError = false
    @State private var errorMessage = ""
    
    var body: some View {
        NavigationView {
            ZStack {
                Color.black.ignoresSafeArea()
                
                VStack(spacing: 20) {
                    // Avatar
                    Circle()
                        .fill(Color.white)
                        .frame(width: 80, height: 80)
                        .overlay(
                            Text(username.prefix(1).uppercased())
                                .font(.system(size: 32, weight: .bold))
                                .foregroundColor(.black)
                        )
                        .padding(.top, 20)
                    
                    // Username field
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Username")
                            .font(.caption)
                            .foregroundColor(.gray)
                        
                        TextField("Username", text: $username)
                            .textInputAutocapitalization(.never)
                            .autocorrectionDisabled()
                            .padding()
                            .background(Color.white.opacity(0.1))
                            .cornerRadius(12)
                            .foregroundColor(.white)
                            .overlay(
                                RoundedRectangle(cornerRadius: 12)
                                    .stroke(Color.white.opacity(0.2), lineWidth: 1)
                            )
                    }
                    .padding(.horizontal)
                    
                    // Email field
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Email")
                            .font(.caption)
                            .foregroundColor(.gray)
                        
                        TextField("Email", text: $email)
                            .textInputAutocapitalization(.never)
                            .autocorrectionDisabled()
                            .keyboardType(.emailAddress)
                            .padding()
                            .background(Color.white.opacity(0.1))
                            .cornerRadius(12)
                            .foregroundColor(.white)
                            .overlay(
                                RoundedRectangle(cornerRadius: 12)
                                    .stroke(Color.white.opacity(0.2), lineWidth: 1)
                            )
                    }
                    .padding(.horizontal)
                    
                    Spacer()
                    
                    // Save button
                    Button(action: saveProfile) {
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
                    .disabled(isSaving || username.isEmpty)
                    .padding(.horizontal, 32)
                    .padding(.bottom, 40)
                }
            }
            .navigationTitle("Edit Profile")
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
            username = currentUser?.username ?? ""
            email = currentUser?.email ?? ""
        }
        .alert("Error", isPresented: $showError) {
            Button("OK", role: .cancel) { }
        } message: {
            Text(errorMessage)
        }
    }
    
    private func saveProfile() {
        guard var user = currentUser else { return }
        
        isSaving = true
        user.username = username
        user.email = email.isEmpty ? nil : email
        
        user.save { result in
            DispatchQueue.main.async {
                isSaving = false
                
                switch result {
                case .success(let updatedUser):
                    currentUser = updatedUser
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
    ProfileView(isLoggedIn: .constant(true))
}
