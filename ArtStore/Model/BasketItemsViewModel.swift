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
    private var db = Firestore.firestore()

    func calculateTotalPrice() {
            totalPrice = basketItems.reduce(0) { total, item in
                total + (item.price ?? 0) * Double(item.quantity ?? 1)
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
