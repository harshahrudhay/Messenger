//
//  Message.swift
//  SampleAssessment4
//
//  Created by HarshaHrudhay on 09/10/25.
//

import Foundation


struct Message: Identifiable, Codable {
    var id: String = UUID().uuidString
    var sender: String
    var receiver: String
    var text: String
    var timestamp: Date
}


struct ChatSummary: Identifiable {
    var id = UUID()
    var otherUser: String
    var lastMessage: String
}
