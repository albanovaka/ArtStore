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
    private var authViewModel: AuthViewModel

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
//    @MainActor
//    func decreaseQuantity(index: Int) {
//        guard basketItems.indices.contains(index),
//              let itemId = basketItems[index].id,
//              let currentQuantity = basketItems[index].quantity, currentQuantity > 1 else { return }
//
//        authViewModel.removeFromBasket(itemId: itemId) { success, error in
//            if success {
//                // Decrease quantity locally for immediate UI update
//                DispatchQueue.main.async {
//                    self.basketItems[index].quantity = currentQuantity - 1
//                    self.calculateTotalPrice()
//                }
//            } else if let error = error {
//                // Handle any errors here
//                print("Error decreasing quantity: \(error.localizedDescription)")
//            }
//        }
//    }

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

}
