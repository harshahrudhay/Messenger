//
//  SettingsView.swift
//  SampleAssessment4
//
//  Created by HarshaHrudhay on 08/10/25.
//


import SwiftUI
import PhotosUI
import FirebaseAuth
import FirebaseFirestore

struct SettingsView: View {
    
    @ObservedObject var userVM: UserVM
    
    @State private var newUsername: String = ""
    @State private var newPassword: String = ""
    @State private var selectedImage: PhotosPickerItem? = nil
    @State private var profileImage: Image? = nil
    
    private let db = Firestore.firestore()
    
    var hasChanges: Bool {
        !newUsername.isEmpty || !newPassword.isEmpty
    }
    
    var body: some View {
        
        NavigationStack {
            
            ZStack {
                
                LinearGradient(colors: [.blue.opacity(0.25), .purple.opacity(0.35)],
                               startPoint: .topLeading,
                               endPoint: .bottomTrailing)
                    .ignoresSafeArea()
                
                ScrollView {
                    
                    VStack(spacing: 30) {
                        
                        Text("Update Details")
                            .font(.largeTitle.bold())
                            .foregroundColor(.primary)
                            .padding(.top, 20)
                        
                        PhotosPicker(selection: $selectedImage, matching: .images) {
                            
                            if let profileImage = profileImage {
                                profileImage
                                    .resizable()
                                    .scaledToFill()
                                    .frame(width: 130, height: 130)
                                    .clipShape(Circle())
                                    .shadow(radius: 5)
                            } else {
                                
                                Image(systemName: "person.crop.circle.badge.plus")
                                    .resizable()
                                    .scaledToFit()
                                    .frame(width: 130, height: 130)
                                    .foregroundStyle(.blue)
                            }
                            
                        }
                        .onChange(of: selectedImage) { newItem in
                            if let newItem = newItem {
                                Task {
                                    if let data = try? await newItem.loadTransferable(type: Data.self),
                                       let uiImage = UIImage(data: data) {
                                        profileImage = Image(uiImage: uiImage)
                                    }
                                }
                            }
                        }
                        
                        VStack(alignment: .leading, spacing: 6) {
                            Text("Update Username")
                                .font(.headline)
                                .foregroundColor(.primary)
                            TextField("Enter username", text: $newUsername)
                                .padding()
                                .glassEffect(.clear.interactive())
//                                .background(.ultraThinMaterial)
                                .cornerRadius(12)
                        }
                        .padding(.horizontal)
                        
                        VStack(alignment: .leading, spacing: 6) {
                            Text("Update Password")
                                .font(.headline)
                                .foregroundColor(.primary)
                            SecureField("Enter new password", text: $newPassword)
                                .padding()
                                .glassEffect(.clear.interactive())
                                .cornerRadius(12)
                        }
                        .padding(.horizontal)
                        
                        Button(action: saveChanges) {
                            Text("Save Changes")
                                .foregroundColor(.white)
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(Color.blue, in: RoundedRectangle(cornerRadius: 16))
                        }
                        
                        .padding(.horizontal)
                        .disabled(!hasChanges)
                        .opacity(hasChanges ? 1.0 : 0.5)
                        
                        Spacer()
                        
                    }
                    .padding(.top, 30)
                }
            }
            .navigationTitle("Settings")
            .navigationBarTitleDisplayMode(.inline)
        }
    }
    
    func saveChanges() {
        let user = Auth.auth().currentUser
        let uid = user?.uid ?? ""
        
        if !newUsername.isEmpty {
            db.collection("users").document(uid).updateData([
                "username": newUsername
            ]) { error in
                if let error = error {
                    userVM.showAlert(title: "Error", message: error.localizedDescription)
                    return
                }
                userVM.username = newUsername
                newUsername = ""
            }
        }
        
        if !newPassword.isEmpty {
            user?.updatePassword(to: newPassword) { error in
                if let error = error {
                    userVM.showAlert(title: "Error", message: error.localizedDescription)
                    return
                }
                userVM.password = newPassword
                newPassword = ""
            }
        }
    }
}

#Preview {
    SettingsView(userVM: UserVM())
}
