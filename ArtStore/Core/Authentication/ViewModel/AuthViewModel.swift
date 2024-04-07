//
//  AuthViewModel.swift
//  ArtStore
//
//  Created by Kanykey Albanova on 2024-04-04.
//

import Foundation
import Firebase
import FirebaseFirestoreSwift
import GoogleSignIn
import UIKit

protocol AuthenticationFormProtocol {
    var formIsValid:Bool {get}
}

@MainActor
class AuthViewModel: ObservableObject{
    @Published var userSession: FirebaseAuth.User?
    @Published var currentUser: User?
    
    init(){
        self.userSession = Auth.auth().currentUser
        Task{
            await fetchUser()
        }
    }
    
    func signIn(withEmail email: String, password: String) async throws{
        do{
            let result = try await Auth.auth().signIn(withEmail: email, password: password)
            self.userSession = result.user
            await fetchUser()
        }catch{
            print("DEBUG: Failed to log in \(error.localizedDescription)")
        }
    }
    
    func createUser(withEmail email: String, password: String, fullname: String) async throws{
        do{
            let result = try await Auth.auth().createUser (withEmail: email, password: password)
            self.userSession = result.user
            let user = User(id: result.user.uid, fullname: fullname, email: email)
            let encodedUser = try Firestore.Encoder().encode (user)
            try await Firestore.firestore().collection("user").document(user.id).setData(encodedUser)
            await fetchUser()
        }catch{
            print("ghfgj")
        }
    }
    
    func signOut(){
        do{
            try Auth.auth().signOut()
            self.userSession = nil
            self.currentUser = nil
        }catch{
            print("DEBUG: Failed to sign out \(error.localizedDescription)")
        }
    }
    
    func deleteAccount(){
        
    }
    
    func fetchUser() async {
        guard let uid = Auth.auth().currentUser?.uid else {
            print("DEBUG: No user is currently signed in.")
            return
        }
        
        do {
            let snapshot = try await Firestore.firestore().collection("user").document(uid).getDocument()
            self.currentUser = try snapshot.data(as: User.self)
            print("DEBUG: Current user is \(String(describing: self.currentUser))")
        } catch {
            print("DEBUG: An error occurred while fetching user data: \(error)")
        }
    }
    
    
    func signInGoogle() async throws {
        
        guard let topVC = Utilities.shared.topViewController() else {
            
            throw URLError(.cannotFindHost)
        }
        
        let gidSignInResult = try await GIDSignIn.sharedInstance.signIn(withPresenting: topVC)
        
        guard let idToken = gidSignInResult.user.idToken?.tokenString else {
            
            throw URLError (.badServerResponse)
        }
        let accessToken = gidSignInResult.user.accessToken.tokenString
        
        let tokens = GoogleSignInResultModel(idToken: idToken, accessToken: accessToken)
        
        let returnedUserData = try await signInWithGoogle(tokens: tokens)
        try await createUserWithGoogle(auth: returnedUserData)
        
    }
    func createUserWithGoogle (auth: User) async throws {
        var userData: [String:Any] = [
            "id" : auth.id,
        ]
        userData["email"] = auth.email
        userData["fullname"] = auth.fullname

        try await Firestore.firestore().collection ("user").document(auth.id).setData(userData, merge: false)
    }
    

}
struct GoogleSignInResultModel{
    let idToken: String
    let accessToken: String
}
extension AuthViewModel {

    func signInWithGoogle(tokens: GoogleSignInResultModel) async throws -> User {
        let credential = GoogleAuthProvider.credential(withIDToken: tokens.idToken, accessToken: tokens.accessToken)
        
//        let authResult = try await signIn(credential: credential)
//        await MainActor.run {
//            self.userSession = Auth.auth().currentUser
//        }
//        return await fetchUser()
        return try await signIn(credential: credential)
    }
    func signIn(credential: AuthCredential) async throws -> User {
        let authDataResult = try await Auth.auth().signIn(with: credential)
        
        self.userSession = authDataResult.user
        
        let email = authDataResult.user.email!
        let uid = authDataResult.user.uid
        let fullname = authDataResult.user.displayName ?? "Update Info" // Replace this with the actual full name, fetched from Firestore or elsewhere
        
        // Now initialize your app's User struct with the properties you have
        let user = User(id: uid, fullname: fullname, email: email)
        
        self.currentUser = user 
        
        // Here you would usually save or use the user object as needed for your app
        // For now, we just return it
        return user
    }

}










