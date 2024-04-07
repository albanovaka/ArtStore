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
                
                Divider()
                Button(action: {
                    // Initiates the sign-in process
                    Task {
                        do {
                            try await viewModel.signInGoogle()
                        } catch {
                            print("Error during Google sign-in: \(error.localizedDescription)")
                        }
                    }
                }) {
                    HStack {
                        Image("google_button") // Your Google 'G' logo asset
                            .resizable()
                            .scaledToFit()
                            .frame(width: 80, height: 80) // Adjust the size to your image
                            .padding(.leading, 10)
        
                    }
                }
                .foregroundColor(.black) // Set the foreground color to black for the text
                .padding() // Add padding around the button if needed


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
