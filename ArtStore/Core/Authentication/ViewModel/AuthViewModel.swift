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



    func toggleFavorite(itemId: String, completion: @escaping (Bool) -> Void) {
        guard let userId = userSession?.uid else { return }
        let userFavoritesRef = Firestore.firestore().collection("user").document(userId).collection("favorites")
        
        userFavoritesRef.document(itemId).getDocument { (document, error) in
            if let document = document, document.exists {
                // Item exists, so remove it from favorites
                userFavoritesRef.document(itemId).delete() { error in
                    if let error = error {
                        print("Error removing favorite item: \(error.localizedDescription)")
                        completion(false)
                    } else {
                        print("Favorite item removed successfully.")
                        completion(false) // Item was removed
                    }
                }
            } else {
                // Item does not exist, so add it to favorites
                userFavoritesRef.document(itemId).setData([:]) { error in
                    if let error = error {
                        print("Error adding favorite item: \(error.localizedDescription)")
                        completion(true)
                    } else {
                        print("Favorite item added successfully.")
                        completion(true) // Item was added
                    }
                }
            }
        }
    }

    
    func addToBasket(itemId: String, quantity: Int) {
        guard let userId = self.userSession?.uid else { return }
        let userBasketRef = Firestore.firestore().collection("user").document(userId).collection("basket")
        
        userBasketRef.document(itemId).setData(["quantity": quantity]) { error in
            if let error = error {
                print("Error adding item to basket: \(error.localizedDescription)")
            } else {
                print("Item added to basket successfully.")
                // Here you may want to fetch the updated basket and update the UI accordingly
            }
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
            let user = User(id: result.user.uid, fullname: fullname, email: email, favorites: [], basket: [])
            let encodedUser = try Firestore.Encoder().encode (user)
            try await Firestore.firestore().collection("user").document(user.id).setData(encodedUser)
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
        return try await signIn(credential: credential)
    }
    func signIn(credential: AuthCredential) async throws -> User {
        let authDataResult = try await Auth.auth().signIn(with: credential)
        
        self.userSession = authDataResult.user
        
        let email = authDataResult.user.email!
        let uid = authDataResult.user.uid
        let fullname = authDataResult.user.displayName ?? "Update Info"
        
        let user = User(id: uid, fullname: fullname, email: email, favorites: [], basket: [])
        
        self.currentUser = user
        
        return user
    }
    
    func addToBasket(itemId: String, completion: @escaping (Bool, Error?) -> Void) {
        guard let userId = userSession?.uid else { return }
        let userBasketRef = Firestore.firestore().collection("user").document(userId).collection("basket")

        // Create an object for the basket item
        let basketItem = ["itemId": itemId]

        // Adding the item to the basket collection
        userBasketRef.addDocument(data: basketItem) { error in
            if let error = error {
                print("Error adding item to basket: \(error.localizedDescription)")
                completion(false, error)
            } else {
                print("Item added to basket successfully.")
                completion(true, nil)
            }
        }
    }

    func removeFromBasket(basketItemId: String, completion: @escaping (Bool, Error?) -> Void) {
        guard let userId = userSession?.uid else { return }
        let userBasketRef = Firestore.firestore().collection("user").document(userId).collection("basket")

        // Deleting the item from the basket collection
        userBasketRef.document(basketItemId).delete() { error in
            if let error = error {
                print("Error removing item from basket: \(error.localizedDescription)")
                completion(false, error)
            } else {
                print("Item removed from basket successfully.")
                completion(true, nil)
            }
        }
    }
}










