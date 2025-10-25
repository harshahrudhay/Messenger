//
//  HomeView.swift
//  SampleAssessment4
//
//  Created by HarshaHrudhay on 08/10/25.
//

import SwiftUI
import FirebaseFirestore

struct HomePage: View {
    
    @ObservedObject var userVM: UserVM
    @State private var searchText = ""
    @State private var selectedFilter = "All Chats"
    @State private var showContactsSheet = false
    
    let filters = ["All Chats", "Groups", "Contacts", "Favourites"]
    
    @State private var allUsers: [String] = []
    @State private var recentChats: [ChatSummary] = []
    @State private var favouriteChats: [ChatSummary] = []
    
    private let db = Firestore.firestore()
    private let chatService = ChatService()
    

    var filteredUsers: [String] {
        if searchText.isEmpty { return allUsers }
        return allUsers.filter { $0.lowercased().contains(searchText.lowercased()) }
    }
    
    var filteredRecentChats: [ChatSummary] {
        if searchText.isEmpty { return recentChats }
        return recentChats.filter { $0.otherUser.lowercased().contains(searchText.lowercased()) }
    }
    
    var filteredFavourites: [ChatSummary] {
        if searchText.isEmpty { return favouriteChats }
        return favouriteChats.filter { $0.otherUser.lowercased().contains(searchText.lowercased()) }
    }
    
    var body: some View {
        NavigationStack {
            ZStack {
                LinearGradient(colors: [.blue.opacity(0.25), .purple.opacity(0.35)],
                               startPoint: .topLeading,
                               endPoint: .bottomTrailing)
                    .ignoresSafeArea()
                
                VStack(spacing: 20) {
                    

                    HStack {
                        Image(systemName: "magnifyingglass")
                            .foregroundStyle(.secondary)
                        TextField("Search chats or friends", text: $searchText)
                            .textFieldStyle(.plain)
                            .foregroundColor(.primary)
                    }
                    .padding()
                    .glassEffect(.clear.interactive())
                    .cornerRadius(20)
                    .shadow(radius: 5)
                    .padding(.horizontal)
                    .padding(.top, 10)
                    

                    Picker("Filter", selection: $selectedFilter) {
                        ForEach(filters, id: \.self) { option in
                            Text(option)
                                .tag(option)
                        }
                    }
                    .pickerStyle(.segmented)
                    .padding(.horizontal)
                    .frame(height: 40)
                    .cornerRadius(16)
                    .shadow(radius: 2)
                    .padding(.horizontal)
                    

                    ScrollView {
                        VStack(spacing: 12) {
                            switch selectedFilter {
                                

                            case "All Chats":
                                if filteredRecentChats.isEmpty {
                                    Text("No chats yet.")
                                        .foregroundColor(.secondary)
                                        .padding(.top, 50)
                                } else {
                                    ForEach(filteredRecentChats) { chat in
                                        NavigationLink(destination: ChatView(userName: chat.otherUser)) {
                                            MessageItemView(
                                                profileImage: "person.circle.fill",
                                                name: chat.otherUser,
                                                lastMessage: chat.lastMessage
                                            )
                                            .glassEffect(.clear)
                                            .cornerRadius(16)
                                            .padding(.horizontal)
                                        }

                                        .contextMenu {
                                            
                                            Button() {
                                                addToFavourites(chat)
                                            } label: {
                                                Label("Add to Favourites", systemImage: "star")
                                            }
                                            Button(role: .destructive) {
                                                deleteChat(chat)
                                            } label: {
                                                Label("Delete", systemImage: "trash")
                                            }
                                        }
                                    }
                                }
                                

                            case "Contacts":
                                if filteredUsers.isEmpty {
                                    Text("No contacts found.")
                                        .foregroundColor(.secondary)
                                        .padding(.top, 50)
                                } else {
                                    ForEach(filteredUsers, id: \.self) { user in
                                        NavigationLink(destination: ChatView(userName: user)) {
                                            MessageItemView(
                                                profileImage: "person.circle.fill",
                                                name: user,
                                                lastMessage: "Tap to chat with \(user)"
                                            )
                                            .glassEffect(.clear)
                                            .cornerRadius(16)
                                            .padding(.horizontal)
                                        }
                                    }
                                }
                            

                            case "Favourites":
                                if filteredFavourites.isEmpty {
                                    Text("No favourites yet.")
                                        .foregroundColor(.secondary)
                                        .padding(.top, 50)
                                } else {
                                    ForEach(filteredFavourites) { chat in
                                        NavigationLink(destination: ChatView(userName: chat.otherUser)) {
                                            MessageItemView(
                                                profileImage: "star.circle.fill",
                                                name: chat.otherUser,
                                                lastMessage: chat.lastMessage
                                            )
                                            .glassEffect(.clear)
                                            .cornerRadius(16)
                                            .padding(.horizontal)
                                        }
                                        .contextMenu {
                                            Button(role: .destructive) {
                                                removeFromFavourites(chat)
                                            } label: {
                                                Label("Remove from Favourites", systemImage: "star.slash")
                                            }
                                        }
                                    }
                                }
                                

                            default:
                                VStack(spacing: 10) {
                                    Text("No \(selectedFilter.lowercased()) available yet.")
                                        .foregroundColor(.secondary)
                                        .padding(.top, 50)
                                }
                            }
                        }
                        .padding(.top, 10)
                    }
                    
                    Spacer()
                }
                

                VStack {
                    Spacer()
                    HStack {
                        Spacer()
                        Button(action: {
                            showContactsSheet = true
                        }) {
                            ZStack {
                                Image(systemName: "plus.message")
                                    .font(.title)
                                    .foregroundColor(.primary)
                                    .frame(width: 60, height: 60)
                            }
                        }
                        .buttonStyle(.glass)
                        .padding()
                    }
                }
            }
            

            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Menu {
                        NavigationLink(destination: SettingsView(userVM: userVM)) {
                            Label("Settings", systemImage: "gearshape")
                        }
                        Button("Logout", systemImage: "rectangle.portrait.and.arrow.right") {
                            userVM.logout()
                        }
                    } label: {
                        Image(systemName: "ellipsis")
                            .font(.title3)
                            .foregroundStyle(.primary)
                    }
                }
            }
            .navigationTitle("Hello, \(userVM.username.isEmpty ? "User" : userVM.username)")
            .toolbarBackground(.ultraThinMaterial, for: .navigationBar)
            .toolbarBackground(.visible, for: .navigationBar)
            .navigationBarTitleDisplayMode(.inline)
        }
        .onAppear {
            fetchUsers()
            chatService.fetchRecentChats(for: userVM.username) { chats in
                self.recentChats = chats
            }
        }
        

        .sheet(isPresented: $showContactsSheet) {
            NavigationStack {
                ScrollView {
                    VStack(spacing: 12) {
                        if allUsers.isEmpty {
                            Text("No contacts found.")
                                .foregroundColor(.secondary)
                                .padding(.top, 50)
                        } else {
                            ForEach(allUsers, id: \.self) { user in
                                NavigationLink(destination: ChatView(userName: user)) {
                                    MessageItemView(
                                        profileImage: "person.circle.fill",
                                        name: user,
                                        lastMessage: "Tap to chat with \(user)"
                                    )
                                    .glassEffect(.clear)
                                    .cornerRadius(16)
                                    .padding(.horizontal)
                                }
                                .buttonStyle(PlainButtonStyle())
                            }
                        }
                    }
                    .padding(.top, 20)
                }
                .navigationTitle("Contacts")
                .toolbar {
                    ToolbarItem(placement: .cancellationAction) {
                        Button("Close") {
                            showContactsSheet = false
                        }
                    }
                }
            }
        }
    }
    


    func fetchUsers() {
        db.collection("users").getDocuments { snapshot, error in
            if let error = error {
                print("Error fetching users: \(error.localizedDescription)")
                return
            }
            if let documents = snapshot?.documents {
                let usernames = documents.compactMap { $0["username"] as? String }
                self.allUsers = usernames.filter { $0 != userVM.username }
            }
        }
    }
    

    func addToFavourites(_ chat: ChatSummary) {
        if !favouriteChats.contains(where: { $0.otherUser == chat.otherUser }) {
            favouriteChats.append(chat)
        }
    }
    

    func removeFromFavourites(_ chat: ChatSummary) {
        favouriteChats.removeAll { $0.otherUser == chat.otherUser }
    }
    

    func deleteChat(_ chat: ChatSummary) {
        recentChats.removeAll { $0.otherUser == chat.otherUser }
        favouriteChats.removeAll { $0.otherUser == chat.otherUser }
    }
}

#Preview {
    HomePage(userVM: UserVM())
}
