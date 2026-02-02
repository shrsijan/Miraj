//
//  LoginView.swift
//  Miraj
//
//  Created by Sijan Shrestha on 2/1/26.
//

import SwiftUI
import ParseSwift

struct LoginView: View {
    @Binding var isLoggedIn: Bool
    @Binding var showLogin: Bool
    
    @State private var username = ""
    @State private var password = ""
    @State private var isLoading = false
    @State private var showError = false
    @State private var errorMessage = ""
    
    var body: some View {
        VStack(spacing: 20) {
            // Input fields
            VStack(spacing: 16) {
                TextField("Username", text: $username)
                    .textFieldStyle(MirajTextFieldStyle())
                    .textInputAutocapitalization(.never)
                    .autocorrectionDisabled()
                
                SecureField("Password", text: $password)
                    .textFieldStyle(MirajTextFieldStyle())
            }
            .padding(.horizontal, 32)
            
            // Login button
            Button(action: login) {
                ZStack {
                    RoundedRectangle(cornerRadius: 12)
                        .fill(Color.white)
                        .frame(height: 50)
                    
                    if isLoading {
                        ProgressView()
                            .progressViewStyle(CircularProgressViewStyle(tint: .white))
                    } else {
                        Text("Log In")
                            .font(.headline)
                            .foregroundColor(.black)
                    }
                }
            }
            .disabled(isLoading || username.isEmpty || password.isEmpty)
            .opacity(username.isEmpty || password.isEmpty ? 0.6 : 1.0)
            .padding(.horizontal, 32)
            
            // Switch to sign up
            Button(action: { showLogin = false }) {
                HStack {
                    Text("Don't have an account?")
                        .foregroundColor(.gray)
                    Text("Sign Up")
                        .foregroundColor(.white)
                        .fontWeight(.semibold)
                }
                .font(.subheadline)
            }
            .padding(.top, 8)
        }
        .alert("Login Error", isPresented: $showError) {
            Button("OK", role: .cancel) { }
        } message: {
            Text(errorMessage)
        }
    }
    
    private func login() {
        isLoading = true
        
        User.login(username: username, password: password) { result in
            DispatchQueue.main.async {
                isLoading = false
                
                switch result {
                case .success:
                    isLoggedIn = true
                case .failure(let error):
                    errorMessage = error.localizedDescription
                    showError = true
                }
            }
        }
    }
}

// Custom text field style
struct MirajTextFieldStyle: TextFieldStyle {
    func _body(configuration: TextField<Self._Label>) -> some View {
        configuration
            .padding()
            .background(Color.white.opacity(0.1))
            .cornerRadius(12)
            .foregroundColor(.white)
            .overlay(
                RoundedRectangle(cornerRadius: 12)
                    .stroke(Color.white.opacity(0.2), lineWidth: 1)
            )
    }
}

#Preview {
    ZStack {
        Color.black.ignoresSafeArea()
        LoginView(isLoggedIn: .constant(false), showLogin: .constant(true))
    }
}
