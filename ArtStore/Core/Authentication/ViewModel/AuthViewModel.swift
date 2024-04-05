//
//  AuthViewModel.swift
//  ArtStore
//
//  Created by Kanykey Albanova on 2024-04-04.
//

import Foundation
import Firebase
import FirebaseFirestoreSwift

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
    
    func signIn(withEmail: String, password: String) async throws{
        print("jhghgfhg")
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

}
