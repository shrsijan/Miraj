//
//  SignUpView.swift
//  Miraj
//
//  Created by Sijan Shrestha on 2/1/26.
//

import SwiftUI
import ParseSwift

struct SignUpView: View {
    @Binding var isLoggedIn: Bool
    @Binding var showLogin: Bool
    
    @State private var username = ""
    @State private var email = ""
    @State private var password = ""
    @State private var confirmPassword = ""
    @State private var isLoading = false
    @State private var showError = false
    @State private var errorMessage = ""
    
    private var isFormValid: Bool {
        !username.isEmpty && !email.isEmpty && !password.isEmpty && password == confirmPassword && password.count >= 6
    }
    
    var body: some View {
        VStack(spacing: 20) {
            // Input fields
            VStack(spacing: 16) {
                TextField("Username", text: $username)
                    .textFieldStyle(MirajTextFieldStyle())
                    .textInputAutocapitalization(.never)
                    .autocorrectionDisabled()
                
                TextField("Email", text: $email)
                    .textFieldStyle(MirajTextFieldStyle())
                    .textInputAutocapitalization(.never)
                    .autocorrectionDisabled()
                    .keyboardType(.emailAddress)
                
                SecureField("Password (min 6 chars)", text: $password)
                    .textFieldStyle(MirajTextFieldStyle())
                
                SecureField("Confirm Password", text: $confirmPassword)
                    .textFieldStyle(MirajTextFieldStyle())
                
                // Password mismatch warning
                if !confirmPassword.isEmpty && password != confirmPassword {
                    Text("Passwords don't match")
                        .font(.caption)
                        .foregroundColor(.red)
                }
            }
            .padding(.horizontal, 32)
            
            // Sign up button
            Button(action: signUp) {
                ZStack {
                    RoundedRectangle(cornerRadius: 12)
                        .fill(Color.white)
                        .frame(height: 50)
                    
                    if isLoading {
                        ProgressView()
                            .progressViewStyle(CircularProgressViewStyle(tint: .white))
                    } else {
                        Text("Sign Up")
                            .font(.headline)
                            .foregroundColor(.black)
                    }
                }
            }
            .disabled(isLoading || !isFormValid)
            .opacity(isFormValid ? 1.0 : 0.6)
            .padding(.horizontal, 32)
            
            // Switch to login
            Button(action: { showLogin = true }) {
                HStack {
                    Text("Already have an account?")
                        .foregroundColor(.gray)
                    Text("Log In")
                        .foregroundColor(.white)
                        .fontWeight(.semibold)
                }
                .font(.subheadline)
            }
            .padding(.top, 8)
        }
        .alert("Sign Up Error", isPresented: $showError) {
            Button("OK", role: .cancel) { }
        } message: {
            Text(errorMessage)
        }
    }
    
    private func signUp() {
        isLoading = true
        
        var user = User()
        user.username = username
        user.email = email
        user.password = password
        
        user.signup { result in
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

#Preview {
    ZStack {
        Color.black.ignoresSafeArea()
        SignUpView(isLoggedIn: .constant(false), showLogin: .constant(false))
    }
}
