//
//  RegistrationView.swift
//  ArtStore
//
//  Created by Kanykey Albanova on 2024-04-03.
//

import SwiftUI

struct RegistrationView: View {
    @State private var email = ""
    @State private var fullname = ""
    @State private var password = ""
    @State private var confirmPassword = ""
    
    @Environment(\.dismiss) var dismiss
    var body: some View {
        VStack{
            Image("tree")
                .resizable()
                .scaledToFit()
                .frame(width: 200, height: 200)
            
            VStack(spacing: 24){
                InputView(text: $fullname,
                          title: "Full Name",
                          placeholder: "Enter your Full Name")
                InputView(text: $email, title: "Email Address", placeholder: "name@example.com")
                    .autocapitalization(.none)
                InputView(text: $password,
                          title: "Password",
                          placeholder: "Enter your password", isSecureField: true)
                InputView(text: $confirmPassword,
                          title: "Confirm Password",
                          placeholder: "Confirm your password", isSecureField: true)
            }
            .padding(.all, 15.0)
            
            Button(action: {
                        print("Button was tapped")
                    }) {
                        Text("Sign Up! ")
                            .fontWeight(.semibold)
                            .font(.title)
                            .padding(12)
                            .background(Color.blue)
                            .foregroundColor(.white)
                            .cornerRadius(60)
                    }
            Spacer()
            Button{
                dismiss()
            } label: {
                HStack {
                    Text ("Already have an account?")
                    Text ("Sign In")
                        .fontWeight(.bold)
                        .font(.system(size: 20))
                }
                .foregroundColor(.indigo)
            }
        }
    }
}

struct RegistrationView_Previews: PreviewProvider {
    static var previews: some View {
        RegistrationView()
    }
}
