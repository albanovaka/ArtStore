//
//  BasketItemsViewModel.swift
//  ArtStore
//
//  Created by Kanykey Albanova on 2024-04-08.
//

import Foundation
import FirebaseFirestore

class BasketItemsViewModel: ObservableObject {
    @Published var basketItems: [Item] = []
    @Published var totalPrice: Double = 0.0
    @Published var paymentConfirmationMessage: String? = nil
    var authViewModel: AuthViewModel

    init(authViewModel: AuthViewModel) {
        self.authViewModel = authViewModel
    }


    private var db = Firestore.firestore()
    

    func calculateTotalPrice() {
            totalPrice = basketItems.reduce(0) { total, item in
                total + (item.price ?? 0) * Double(item.quantity ?? 1)
            }
        }
    @MainActor
    func increaseQuantity(index: Int) {
        guard basketItems.indices.contains(index),
              let itemId = basketItems[index].id else { return }

        authViewModel.addToBasket(itemId: itemId) { success, error in
            if success {
                // Increase quantity locally for immediate UI update
                DispatchQueue.main.async {
                    if let currentQuantity = self.basketItems[index].quantity {
                        self.basketItems[index].quantity = currentQuantity + 1
                    } else {
                        self.basketItems[index].quantity = 1 // Initialize with 1 if nil
                    }
                    self.calculateTotalPrice()
                }
            } else if let error = error {
                // Handle any errors here
                print("Error increasing quantity: \(error.localizedDescription)")
            }
        }
    }
    func saveAddressForUser(userId: String, address: [String: Any], completion: @escaping (Bool, Error?) -> Void) {
        let userRef = db.collection("user").document(userId)
            userRef.setData(["address": address], merge: true) { error in
                if let error = error {
                    print("Error saving address: \(error.localizedDescription)")
                    completion(false, error)
                } else {
                    print("Address saved successfully.")
                    completion(true, nil)
                }
            }
        }

        func savePastPurchaseForUser(userId: String, items: [Item], completion: @escaping (Bool, Error?) -> Void) {
            let pastPurchasesRef = db.collection("user").document(userId).collection("pastPurchases")
            let purchaseData: [String: Any] = [
                "items": items.map { ["id": $0.id, "name": $0.name, "price": $0.price, "quantity": $0.quantity] },
                "purchaseDate": FieldValue.serverTimestamp()
            ]
            
            pastPurchasesRef.addDocument(data: purchaseData) { error in
                if let error = error {
                    print("Error saving past purchase: \(error.localizedDescription)")
                    completion(false, error)
                } else {
                    print("Past purchase saved successfully.")
                    completion(true, nil)
                }
            }
        }

    @MainActor
    func decreaseQuantity(index: Int) {
        guard basketItems.indices.contains(index),
              let itemId = basketItems[index].id,
              let currentQuantity = basketItems[index].quantity else { return }

        if currentQuantity > 1 {
            // If quantity is more than 1, proceed to decrease it normally
            authViewModel.removeFromBasket(itemId: itemId) { success, error in
                if success {
                    // Decrease quantity locally for immediate UI update
                    DispatchQueue.main.async {
                        self.basketItems[index].quantity = currentQuantity - 1
                        self.calculateTotalPrice()
                    }
                } else if let error = error {
                    // Handle any errors here
                    print("Error decreasing quantity: \(error.localizedDescription)")
                }
            }
        } else {
            // If quantity is exactly 1, call removeFromBasket to remove the item completely
            authViewModel.removeFromBasket(itemId: itemId) { success, error in
                if success {
                    // Remove the item locally for immediate UI update
                    DispatchQueue.main.async {
                        self.basketItems.remove(at: index)
                        self.calculateTotalPrice()
                    }
                } else if let error = error {
                    // Handle any errors here
                    print("Error removing item from basket: \(error.localizedDescription)")
                }
            }
        }
    }
    
    var gst: Double {
        return totalPrice * 0.05
    }
    
    var qst: Double {
        return totalPrice * 0.09975
    }
    
    var totalWithTaxes: Double {
        return totalPrice + gst + qst
    }
    
    func fetchBasketItems(userId: String) {
        self.basketItems.removeAll()
        let userBasketRef = db.collection("user").document(userId).collection("basket")
        userBasketRef.getDocuments { [weak self] (snapshot, error) in
            guard let self = self else { return }

            guard let documents = snapshot?.documents else {
                print("No items in basket found for user")
                return
            }

            let group = DispatchGroup()

            for document in documents {
                guard let itemId = document.data()["itemId"] as? String,
                      let quantity = document.data()["quantity"] as? Int else { continue }
                group.enter()
                self.fetchItemDetails(itemId: itemId, quantity: quantity) { item in
                    if var item = item {
                        // Add the quantity to the item
                        item.quantity = quantity
                        
                        // If there's an image path, fetch the image.
                        if let imagePath = item.image_storage_path {
                            ImageService.shared.fetchImageForItem(imagePath: imagePath) { image in
                                DispatchQueue.main.async {
                                    item.image = image
                                    self.basketItems.append(item)
                                    group.leave()
                                }
                            }
                        } else {
                            // If there's no image, just append the item.
                            DispatchQueue.main.async {
                                self.basketItems.append(item)
                                group.leave()
                            }
                        }
                    } else {
                        group.leave()
                    }
                }
            }

            group.notify(queue: .main) {
                self.calculateTotalPrice()
                print("Finished fetching all basket items")
            }
        }
    }
    

    private func fetchItemDetails(itemId: String, quantity: Int, completion: @escaping (Item?) -> Void) {
        db.collection("items").document(itemId).getDocument { (documentSnapshot, error) in
            if let error = error {
                print("Error fetching item details: \(error.localizedDescription)")
                completion(nil)
                return
            }

            guard let documentSnapshot = documentSnapshot else {
                print("Document does not exist")
                completion(nil)
                return
            }

            do {
                let item = try documentSnapshot.data(as: Item.self)
                completion(item)
            } catch {
                print("Error decoding item: \(error)")
                completion(nil)
            }
        }
    }
    
    func removeAllItemsFromBasket(userId: String, completion: @escaping () -> Void) {
        let userBasketRef = Firestore.firestore().collection("user").document(userId).collection("basket")
        userBasketRef.getDocuments { (snapshot, error) in
            if let error = error {
                print("Error getting basket documents: \(error.localizedDescription)")
                completion()
                return
            }

            guard let documents = snapshot?.documents else {
                print("No items in basket to delete")
                completion()
                return
            }

            let batch = Firestore.firestore().batch()
            
            documents.forEach { batch.deleteDocument($0.reference) }
            
            batch.commit { err in
                if let err = err {
                    print("Error removing basket items: \(err.localizedDescription)")
                } else {
                    print("All basket items removed successfully")
                    self.paymentConfirmationMessage = "Payment successful. ID: \(PaymentConfig.shared.paymentIntendId ?? "Cannot retrieve transaction ID")"
                }
                completion()
            }
        }
    }

}
