//
//  SignInView.swift
//  SampleAssessment4
//
//  Created by HarshaHrudhay on 08/10/25.
//



import SwiftUI

struct SignInView: View {
    
    @ObservedObject var userVM: UserVM
    @State private var inputUsername = ""
    @State private var inputEmail = ""
    @State private var inputPassword = ""
    @State private var inputConfirmPassword = ""
    
    var body: some View {
        NavigationStack {
            ZStack {
                LinearGradient(colors: [.blue.opacity(0.25), .purple.opacity(0.35)],
                               startPoint: .topLeading,
                               endPoint: .bottomTrailing)
                    .ignoresSafeArea()
                
                VStack(spacing: 30) {
                    
                    Image("icon")
                        .resizable()
                        .scaledToFit()
                        .frame(width: 200, height: 200)
                        .foregroundStyle(.white.opacity(0.8))
                        .padding(.top, 50)
                        .shadow(radius: 5)
                    
                    VStack(spacing: 20) {
                        HStack {
                            Image(systemName: "person.fill")
                                .foregroundStyle(.secondary)
                            TextField("Username", text: $inputUsername)
                                .autocapitalization(.none)
                        }
                        .padding()
                        .glassEffect(.clear)
//                        .background(.ultraThinMaterial)
                        .cornerRadius(12)
                        .shadow(radius: 3)
                        
                        HStack {
                            Image(systemName: "envelope.fill")
                                .foregroundStyle(.secondary)
                            TextField("Email", text: $inputEmail)
                                .autocapitalization(.none)
                                .keyboardType(.emailAddress)
                        }
                        .padding()
                        .glassEffect(.clear)
//                        .background(.ultraThinMaterial)
                        .cornerRadius(12)
                        .shadow(radius: 3)
                        
                        HStack {
                            Image(systemName: "lock.fill")
                                .foregroundStyle(.secondary)
                            SecureField("Password", text: $inputPassword)
                                .autocorrectionDisabled(true)
                        }
                        .padding()
                        .glassEffect(.clear)
//                        .background(.ultraThinMaterial)
                        .cornerRadius(12)
                        .shadow(radius: 3)
                        
                        HStack {
                            Image(systemName: "lock.fill")
                                .foregroundStyle(.secondary)
                            SecureField("Confirm Password", text: $inputConfirmPassword)
                                .autocorrectionDisabled(true)
                        }
                        .padding()
                        .glassEffect(.clear)
//                        .background(.ultraThinMaterial)
                        .cornerRadius(12)
                        .shadow(radius: 3)
                    }
                    .padding(.horizontal)
                    
                    Button(action: register) {
                        Text("Register")
                            .foregroundColor(.black)
                            .fontWeight(.bold)
                            .frame(maxWidth: .infinity)
                            .padding()
                            
//                            .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 12))
//                            .overlay(
//                                RoundedRectangle(cornerRadius: 12)
//                                    .stroke(.white.opacity(0.3), lineWidth: 1)
//                            )
                    }
                    .buttonStyle(.glass)
                    .padding(.horizontal)
                    
                    HStack {
                        Text("Already have an account?")
                            .foregroundStyle(.black.opacity(0.8))
                        Button(action: {
                            userVM.showRegisterPage = false
                        }) {
                            Text("Sign in")
                                .foregroundColor(.blue)
                                .fontWeight(.bold)
                        }
                        .buttonStyle(.glass)
                    }
                    
                    Spacer()
                }
            }
            .alert(userVM.alertTitle, isPresented: $userVM.isAlertShowing) {
                Button("OK", role: .cancel) { }
            } message: {
                Text(userVM.alertMessage)
            }
        }
    }
    
    func register() {
        guard !inputUsername.isEmpty, !inputEmail.isEmpty, !inputPassword.isEmpty, !inputConfirmPassword.isEmpty else {
            userVM.showAlert(title: "Error", message: "All fields are required")
            return
        }
        
        guard inputPassword == inputConfirmPassword else {
            userVM.showAlert(title: "Error", message: "Passwords do not match")
            return
        }
        
        userVM.registerUser(username: inputUsername, email: inputEmail, password: inputPassword) { success in
            
        }
    }
}
#Preview {
    SignInView(userVM: UserVM())
}
