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


    
    func addToBasket(itemId: String, completion: @escaping (Bool, Error?) -> Void) {
        guard let userId = userSession?.uid else {
            completion(false, nil)
            return
        }
        
        let userBasketRef = Firestore.firestore().collection("user").document(userId).collection("basket")
        
        // Start a transaction to ensure the operation is atomic
        Firestore.firestore().runTransaction({ (transaction, errorPointer) -> Any? in
            let documentRef = userBasketRef.document(itemId)
            
            // Try to fetch the document within the transaction
            let documentSnapshot: DocumentSnapshot
            do {
                documentSnapshot = try transaction.getDocument(documentRef)
            } catch let fetchError as NSError {
                errorPointer?.pointee = fetchError
                return nil
            }
            
            // If the document already exists, increment the 'quantity' field
            if documentSnapshot.exists {
                guard let currentQuantity = documentSnapshot.data()?["quantity"] as? Int else {
                    errorPointer?.pointee = NSError(domain: "AppError", code: -1, userInfo: [NSLocalizedDescriptionKey : "Failed to retrieve current quantity."])
                    return nil
                }
                transaction.updateData(["quantity": currentQuantity + 1], forDocument: documentRef)
            } else {
                // The document does not exist, create it with a 'quantity' of 1
                transaction.setData(["itemId": itemId, "quantity": 1], forDocument: documentRef)
            }
            
            return nil // Return nil to indicate success
        }) { (object, error) in
            if let error = error {
                print("Transaction failed: \(error)")
                completion(false, error)
            } else {
                print("Transaction completed successfully.")
                completion(true, nil)
            }
        }
    }

    func removeFromBasket(itemId: String, completion: @escaping (Bool, Error?) -> Void) {
        guard let userId = userSession?.uid else {
            completion(false, nil)
            return
        }

        let userBasketRef = Firestore.firestore().collection("user").document(userId).collection("basket")
        let documentRef = userBasketRef.document(itemId)

        Firestore.firestore().runTransaction({ (transaction, errorPointer) -> Any? in
            let documentSnapshot: DocumentSnapshot
            do {
                documentSnapshot = try transaction.getDocument(documentRef)
            } catch let fetchError as NSError {
                errorPointer?.pointee = fetchError
                return nil
            }

            // If the document exists, check the quantity and decrement or remove
            if documentSnapshot.exists, let currentQuantity = documentSnapshot.data()?["quantity"] as? Int {
                if currentQuantity > 1 {
                    // If there's more than one, decrement the quantity
                    transaction.updateData(["quantity": currentQuantity - 1], forDocument: documentRef)
                } else {
                    // If there's only one, remove the item from the basket
                    transaction.deleteDocument(documentRef)
                }
            } else {
                // The document does not exist or quantity is not a valid number, which is an error
                errorPointer?.pointee = NSError(domain: "AppError", code: -1, userInfo: [NSLocalizedDescriptionKey : "Item not found in basket or invalid quantity."])
                return nil
            }

            return nil // Return nil to indicate success
        }) { (object, error) in
            if let error = error {
                print("Transaction failed: \(error)")
                completion(false, error)
            } else {
                print("Transaction completed successfully.")
                completion(true, nil)
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
}










