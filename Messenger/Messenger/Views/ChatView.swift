//
//  ChatView.swift
//  SampleAssessment4
//
//  Created by HarshaHrudhay on 08/10/25.
//



import SwiftUI

struct ChatView: View {
    
    @Environment(\.dismiss) var dismiss
    var userName: String
    var profileImageName: String = "person.circle.fill"
    
    @State private var messageText: String = ""
    @State private var messages: [Message] = []
    
    @State private var selectedWallpaper: String = "wallpaper2"
    @State private var showWallpaperMenu = false
    
    private let chatService = ChatService()
    private let wallpapers = ["wallpaper1", "wallpaper2", "wallpaper3", "wallpaper4", "wallpaper5", "wallpaper6"]
    
    var body: some View {
        
        ZStack {
            
            if let image = UIImage(named: selectedWallpaper) {
                Image(uiImage: image)
                    .resizable()
                    .scaledToFill()
                    .ignoresSafeArea()
                
            } else {
                LinearGradient(colors: [.blue.opacity(0.25), .purple.opacity(0.35)],
                               startPoint: .topLeading,
                               endPoint: .bottomTrailing)
                    .ignoresSafeArea()
            }
            
            VStack(spacing: 0) {

                HStack(spacing: 12) {
                    Button(action: { dismiss() }) {
                        Image(systemName: "chevron.left")
                            .font(.title2)
                            .foregroundStyle(.black)
                            .frame(width: 35, height: 35)
                            .clipShape(Circle())
                            .glassEffect(.clear)
                    }
                    
                    Image(systemName: profileImageName)
                        .resizable()
                        .frame(width: 40, height: 40)
                        .clipShape(Circle())
                        .shadow(radius: 2)
                    
                    Text(userName)
                        .font(.headline)
                    
                    Spacer()
                    
                    Menu {
                        Button("Change Wallpaper") {
                            showWallpaperMenu = true
                        }
                        Divider()
                        Button(action: { print("Voice Call") }) {
                            Label("Voice Call", systemImage: "phone.fill")
                        }
                        Button(action: { print("Video Call") }) {
                            Label("Video Call", systemImage: "video.fill")
                        }
                    } label: {
                        Image(systemName: "ellipsis.circle")
                            .foregroundStyle(.black)
                            .frame(width: 40, height: 40)
                            .font(.title2)
                    }
                    .glassEffect(.clear)
                    
                }
                .padding(.horizontal)
                .padding(.top, safeAreaTopInset())
                .padding(.bottom, 6)
                .background(.ultraThinMaterial)
                
                Divider()
                

                ScrollViewReader { scrollProxy in
                    ScrollView {
                        VStack(spacing: 10) {
                            if messages.isEmpty {
                                Text("Start a conversation with \(userName)")
                                    .font(.system(size: 20))
                                    .foregroundColor(.white)
                                    .padding(.top, 250)
                            } else {
                                ForEach(messages) { message in
                                    VStack(alignment: message.sender == currentUser ? .trailing : .leading, spacing: 3) {
                                        HStack {
                                            if message.sender == currentUser {
                                                Spacer()
                                                Text(message.text)
                                                    .padding()
                                                    .glassEffect(.clear)
                                                    .foregroundColor(.white)
                                                    .cornerRadius(12)
                                                
                                            } else {
                                                Text(message.text)
                                                    .padding()
                                                    .glassEffect(.clear)
                                                    .foregroundColor(.white)
                                                    .cornerRadius(12)
                                                Spacer()
                                            }
                                        }
                                        Text(formatDate(message.timestamp))
                                            .font(.caption2)
                                            .foregroundColor(.white)
                                            .padding(.horizontal, message.sender == currentUser ? 4 : 8)
                                    }
                                }
                            }
                        }
                        .padding(.horizontal)
                        .padding(.top, 10)
                        .padding(.bottom, safeAreaBottomInset() + 10)
                        .onChange(of: messages.count) { _ in
                            withAnimation {
                                if let last = messages.last {
                                    scrollProxy.scrollTo(last.id, anchor: .bottom)
                                }
                            }
                        }
                    }
                }
                
                Divider()
                
                HStack(spacing: 10) {
                    Button(action: { print("Record Audio") }) {
                        Image(systemName: "mic.fill")
                            .font(.title2)
                            .padding(10)
                            .glassEffect(.clear)
                    }
                    
                    Divider()
                        .frame(height: 35)
                    
                    TextField("Type a message", text: $messageText)
                        .padding(10)
                        .glassEffect(.clear)
                        .cornerRadius(20)
                    
                    Button(action: sendMessage) {
                        Image(systemName: "paperplane.fill")
                            .font(.title2)
                            .padding(10)
                            .glassEffect(.clear)
                    }
                }
                .padding(.horizontal)
                .padding(.vertical, 5)
                .padding(.bottom, safeAreaBottomInset() + 5)
            }
        }
        .ignoresSafeArea(.keyboard, edges: .bottom)
        .navigationBarHidden(true)
        .onAppear {
            chatService.listenForMessages(between: currentUser, and: userName) { msgs in
                self.messages = msgs
            }
        }

        .sheet(isPresented: $showWallpaperMenu) {
            NavigationStack {
                ScrollView {
                    LazyVGrid(columns: [GridItem(.adaptive(minimum: 120))], spacing: 20) {
                        ForEach(wallpapers, id: \.self) { wallpaper in
                            if let img = UIImage(named: wallpaper) {
                                Image(uiImage: img)
                                    .resizable()
                                    .scaledToFill()
                                    .frame(width: 120, height: 200)
                                    .clipped()
                                    .cornerRadius(16)
                                    .shadow(radius: 4)
                                    .onTapGesture {
                                        selectedWallpaper = wallpaper
                                        showWallpaperMenu = false
                                    }
                            }
                        }
                    }
                    .padding()
                }
                .navigationTitle("Select Wallpaper")
                .toolbar {
                    ToolbarItem(placement: .cancellationAction) {
                        Button("Close") {
                            showWallpaperMenu = false
                        }
                    }
                }
            }
        }
    }
    
    private var currentUser: String {
        UserDefaults.standard.string(forKey: "loggedInUser") ?? ""
    }
    
    private func sendMessage() {
        guard !messageText.isEmpty else { return }
        chatService.sendMessage(from: currentUser, to: userName, text: messageText)
        messageText = ""
    }
    
    private func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "hh:mm a"
        return formatter.string(from: date)
    }
    
    private func safeAreaTopInset() -> CGFloat {
        UIApplication.shared.windows.first?.safeAreaInsets.top ?? 20
    }
    
    private func safeAreaBottomInset() -> CGFloat {
        UIApplication.shared.windows.first?.safeAreaInsets.bottom ?? 0
    }
}

#Preview {
    ChatView(userName: "User 2")
}

