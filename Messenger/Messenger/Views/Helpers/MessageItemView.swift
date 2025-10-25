//
//  MessageItemView.swift
//  SampleAssessment4
//
//  Created by HarshaHrudhay on 08/10/25.
//

import SwiftUI

struct MessageItemView: View {
    
    var profileImage: String = "person.circle.fill"
    var name: String = "John Cena"
    var lastMessage: String = "Hey, how are you?"
    
    var body: some View {
        
        HStack(spacing: 15) {
            
            Image(systemName: profileImage)
                .resizable()
                .scaledToFill()
                .frame(width: 55, height: 55)
                .clipShape(Circle())
                .foregroundStyle(.blue)
            
            VStack(alignment: .leading, spacing: 4) {
                Text(name)
                    .font(.headline)
                    .foregroundColor(.primary)
                
                Text(lastMessage)
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                    .lineLimit(1)
            }
            
            Spacer()
        }
        .glassEffect(.clear.interactive())
        .padding(.vertical, 8)
        .padding(.horizontal)
    }
}

#Preview {
    VStack {
        MessageItemView()
    }
//    .background(Color(.gray))
}

