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
    @EnvironmentObject var viewModel: AuthViewModel
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
                ZStack(alignment: .trailing){
                    InputView(text: $confirmPassword,
                              title: "Confirm Password",
                              placeholder: "Confirm your password", isSecureField: true)
                    if !password.isEmpty && !confirmPassword.isEmpty {
                        if password == confirmPassword {
                            Image (systemName: "checkmark.circle.fill")
                                .imageScale (.large)
                                .fontWeight (.bold)
                                .foregroundColor(Color(.systemGreen))
                                .padding(.top, 30)
                        } else {
                            Image (systemName: "xmark.circle.fill")
                                .imageScale (.large)
                                .fontWeight (.bold)
                                .foregroundColor(Color(.systemRed))
                                .padding(.top, 30.0)
                        }
                    }
                }
            }
            .padding(.all, 15.0)
            
            Button(action: {
                Task{
                    try await viewModel.createUser(withEmail: email, password: password, fullname: fullname)
                }
                    }) {
                        Text("Sign Up! ")
                            .fontWeight(.semibold)
                            .font(.title)
                            .padding(12)
                            .background(Color.blue)
                            .foregroundColor(.white)
                            .cornerRadius(60)
                    }
                    .disabled(!formIsValid)
                    .opacity(formIsValid ? 1.0 : 0.5)
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
extension RegistrationView: AuthenticationFormProtocol {
    var formIsValid: Bool {
        !email.isEmpty
        && email.contains ("@")
        && !password.isEmpty
        && !confirmPassword.isEmpty
        
    }
}
struct RegistrationView_Previews: PreviewProvider {
    static var previews: some View {
        RegistrationView()
    }
}
