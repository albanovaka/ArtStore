//
//  InputView.swift
//  ArtStore
//
//  Created by Kanykey Albanova on 2024-04-03.
//

import SwiftUI

struct InputView: View {
    @Binding var text: String
    let title: String
    let placeholder: String
    var isSecureField = false
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12){
            Text(title)
            
                .foregroundColor(Color(.darkGray))
                .fontWeight(.medium)
                .font(.system(size: 16))
            
            
            if isSecureField {
                SecureField(placeholder, text: $text)
                    .font(.system(size: 20))
                    .padding(.all, 12)
                    .background(Color(.systemGray6))
                    .cornerRadius(8)
            }else{
                TextField(placeholder, text: $text)
                    .font(.system(size: 20))
                    .padding(.all, 12)
                    .background(Color(.systemGray6))
                    .cornerRadius(8)
            }
        }
    }
}

struct InputView_Previews: PreviewProvider {
    static var previews: some View {
        InputView(text: .constant(""), title: "Email Address", placeholder: "name@example.com")
    }
}
