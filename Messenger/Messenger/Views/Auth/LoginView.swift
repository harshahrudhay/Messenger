//
//  LoginView.swift
//  SampleAssessment4
//
//  Created by HarshaHrudhay on 08/10/25.
//

import SwiftUI
import FirebaseFirestore

struct LoginView: View {
    
    @StateObject var userVM = UserVM()
    @State private var inputUsername = ""
    @State private var inputPassword = ""
    @State private var showSignUpPage = false
    
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
                            TextField("Username or Email", text: $inputUsername)
                                .autocapitalization(.none)
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
                    }
                    .padding(.horizontal)
                    
                    Button(action: login) {
                        Text("Login")
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
                        Text("Don't have an account?")
                            .foregroundStyle(.white.opacity(0.8))
                        NavigationLink(destination: SignInView(userVM: userVM), isActive: $showSignUpPage) {
                            Button(action: {
                                showSignUpPage = true
                            }) {
                                Text("Sign up")
                                    .foregroundColor(.blue)
                                    .fontWeight(.bold)
                            }
                        }
                        .isDetailLink(false)
                    }
                    
                    Spacer()
                }
            }
            .fullScreenCover(isPresented: $userVM.showHomePage) {                   // to nav
                HomePage(userVM: userVM)
            }
            .alert(userVM.alertTitle, isPresented: $userVM.isAlertShowing) {
                Button("OK", role: .cancel) { }
            } message: {
                Text(userVM.alertMessage)
            }
        }
    }
    
    func login() {
        let db = Firestore.firestore()
        
        if inputUsername.contains("@") {                                    // y

            userVM.loginUser(email: inputUsername, password: inputPassword)
            
        } else {

            db.collection("users").whereField("username", isEqualTo: inputUsername)
                .getDocuments { snapshot, error in
                    if let error = error {
                        userVM.showAlert(title: "Login Failed", message: error.localizedDescription)
                        return
                    }
                    
                    if let doc = snapshot?.documents.first,
                       let email = doc.data()["email"] as? String {
                        userVM.loginUser(email: email, password: inputPassword)
                    } else {
                        userVM.showAlert(title: "Login Failed", message: "User not found")
                    }
                }
        }
    }
}

#Preview {
    LoginView()
}
