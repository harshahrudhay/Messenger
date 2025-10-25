//
//  ChatService.swift
//  SampleAssessment4
//
//  Created by HarshaHrudhay on 09/10/25.
//



import Foundation
import FirebaseDatabase

class ChatService {
    
    private let dbRef = Database.database().reference()
    
    private func chatId(for user1: String, and user2: String) -> String {
        return [user1, user2].sorted().joined(separator: "_")
    }
    

    func sendMessage(from sender: String, to receiver: String, text: String) {
        guard !sender.isEmpty, !receiver.isEmpty, !text.isEmpty else { return }
        
        let chatId = chatId(for: sender, and: receiver)
        let messageId = dbRef.child("chats").child(chatId).childByAutoId().key ?? UUID().uuidString
        
        let messageData: [String: Any] = [
            "id": messageId,
            "sender": sender,
            "receiver": receiver,
            "text": text,
            "timestamp": ServerValue.timestamp()
        ]
        

        dbRef.child("chats").child(chatId).child("messages").child(messageId)
            .setValue(messageData)
        

        let recentData: [String: Any] = [
            "chatId": chatId,
            "user1": sender,
            "user2": receiver,
            "lastMessage": text,
            "timestamp": ServerValue.timestamp()
        ]
        
        dbRef.child("recentChats").child(chatId).setValue(recentData)
    }
    

    func listenForMessages(between user1: String, and user2: String, completion: @escaping ([Message]) -> Void) {
        let chatId = chatId(for: user1, and: user2)
        dbRef.child("chats").child(chatId).child("messages")
            .observe(.value) { snapshot in
                var messages: [Message] = []
                
                for child in snapshot.children {
                    if let snap = child as? DataSnapshot,
                       let data = snap.value as? [String: Any],
                       let sender = data["sender"] as? String,
                       let receiver = data["receiver"] as? String,
                       let text = data["text"] as? String,
                       let timestamp = data["timestamp"] as? Double {
                        
                        let message = Message(
                            id: snap.key,
                            sender: sender,
                            receiver: receiver,
                            text: text,
                            timestamp: Date(timeIntervalSince1970: timestamp / 1000)
                        )
                        messages.append(message)
                    }
                }
                
                messages.sort { $0.timestamp < $1.timestamp }
                completion(messages)
            }
    }
    

    func fetchRecentChats(for username: String, completion: @escaping ([ChatSummary]) -> Void) {
        dbRef.child("recentChats").observe(.value) { snapshot in
            var chats: [ChatSummary] = []
            
            for child in snapshot.children {
                if let snap = child as? DataSnapshot,
                   let data = snap.value as? [String: Any],
                   let user1 = data["user1"] as? String,
                   let user2 = data["user2"] as? String,
                   let lastMessage = data["lastMessage"] as? String {
                    
                    if user1 == username || user2 == username {
                        let otherUser = (user1 == username) ? user2 : user1
                        chats.append(ChatSummary(otherUser: otherUser, lastMessage: lastMessage))
                    }
                }
            }
            
            completion(chats)
        }
    }
}

