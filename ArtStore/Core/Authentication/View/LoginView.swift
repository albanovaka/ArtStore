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
    @EnvironmentObject var viewModel: AuthViewModel
    
    var body: some View {
        NavigationView{
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
                    Task{
                        try await viewModel.signIn(withEmail:email,password: password)
                    }
                        }) {
                            Text("Sign In")
                                .fontWeight(.semibold)
                                .font(.title)
                                .padding(20)
                                .background(Color.blue)
                                .foregroundColor(.white)
                                .cornerRadius(60)
                        }
                        .disabled(!formIsValid)
                        .opacity(formIsValid ? 1.0 : 0.5)
                Button(action: {
                    // Your code to call signInGoogle() method goes here.
                    // If signInGoogle() is an asynchronous method, you will call it like this:
                    Task {
                        try await viewModel.signInGoogle()
                    }
                    // If signInGoogle() is not an asynchronous method, you will call it directly like this:
                    // viewModel.signInGoogle()
                }) {
                    Text("Sign In with Google")
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
}

extension LoginView: AuthenticationFormProtocol {
    var formIsValid: Bool {
        !email.isEmpty
        && email.contains ("@")
        && !password.isEmpty
    }
}



struct LoginView_Previews: PreviewProvider {
    static var previews: some View {
        LoginView()
    }
}
