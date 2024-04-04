//
//  LoginView.swift
//  ArtStore
//
//  Created by Kanykey Albanova on 2024-04-03.
//

import SwiftUI

struct LoginView: View {
    @State private var email = ""
    @State private var password = ""
    var body: some View {
        VStack{
            Image("tree")
                .resizable()
                .scaledToFit()
                .frame(width: 200, height: 200)
            
            VStack(spacing: 24){
                InputView(text: $email, title: "Email Address", placeholder: "name@example.com")
                    .autocapitalization(.none)
                InputView(text: $password,
                          title: "Password",
                          placeholder: "Enter your password", isSecureField: true)
            }
            .padding(.all, 15.0)
            
            Button(action: {
                        print("Button was tapped")
                    }) {
                        Text("Sign In")
                            .fontWeight(.semibold)
                            .font(.title)
                            .padding(20)
                            .background(Color.blue)
                            .foregroundColor(.white)
                            .cornerRadius(60)
                    }
            Spacer()
            NavigationLink {
                RegistrationView()
                    .navigationBarBackButtonHidden(true)
            } label: {
                HStack {
                    Text ("Don't have an account?")
                    Text ("Sign up")
                        .fontWeight(.bold)
                        .font(.system(size: 23))
                }
                .foregroundColor(.indigo)
            }
        }
    }
}

struct LoginView_Previews: PreviewProvider {
    static var previews: some View {
        LoginView()
    }
}
