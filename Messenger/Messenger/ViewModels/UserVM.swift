//
//  UserVM.swift
//  SampleAssessment4
//
//  Created by HarshaHrudhay on 08/10/25.
//



import Foundation
import SwiftUI
import FirebaseAuth
import FirebaseFirestore
import Combine

class UserVM: ObservableObject {
    
    @Published var username: String = ""
    @Published var email: String = ""
    @Published var password: String = ""
    @Published var confirmPassword: String = ""
    
    @Published var isLoggedIn: Bool = false
    @Published var showRegisterPage: Bool = false
    @Published var showHomePage: Bool = false
    @Published var isAlertShowing: Bool = false
    
    @Published var alertTitle: String = ""
    @Published var alertMessage: String = ""
    
    private let db = Firestore.firestore()
    
    init() { }
    
    func logout() {
        try? Auth.auth().signOut()
        isLoggedIn = false
        showHomePage = false
        username = ""
        email = ""
        password = ""
        UserDefaults.standard.removeObject(forKey: "loggedInUser")
    }
    
    func showAlert(title: String, message: String) {
        alertTitle = title
        alertMessage = message
        isAlertShowing = true
    }
    
    func registerUser(username: String, email: String, password: String, completion: @escaping (Bool) -> Void) {
        Auth.auth().createUser(withEmail: email, password: password) { result, error in
            if let error = error {
                self.showAlert(title: "Registration Failed", message: error.localizedDescription)
                completion(false)
                return
            }

            if let uid = result?.user.uid {
                self.db.collection("users").document(uid).setData([
                    "username": username,
                    "email": email,
                    "uid": uid,
                    "password": password
                ]) { error in
                    if let error = error {
                        self.showAlert(title: "Error", message: error.localizedDescription)
                        completion(false)
                        return
                    }
                    
                    self.username = username
                    self.email = email
                    self.password = password
                    self.isLoggedIn = true
                    self.showHomePage = true
                    UserDefaults.standard.set(username, forKey: "loggedInUser")
                    completion(true)
                }
            }
        }
    }
    
    func loginUser(email: String, password: String) {
        Auth.auth().signIn(withEmail: email, password: password) { result, error in
            if let error = error {
                self.showAlert(title: "Login Failed", message: error.localizedDescription)
                return
            }

            if let uid = result?.user.uid {
                self.db.collection("users").document(uid).getDocument { snapshot, error in
                    if let error = error {
                        self.showAlert(title: "Error", message: error.localizedDescription)
                        return
                    }
                    
                    if let data = snapshot?.data(), let username = data["username"] as? String {
                        self.username = username
                        self.email = email
                        self.isLoggedIn = true
                        self.showHomePage = true
                        UserDefaults.standard.set(username, forKey: "loggedInUser")
                    }
                }
            }
        }
    }
}
