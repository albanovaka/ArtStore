//
//  FavItemsViewModel.swift
//  ArtStore
//
//  Created by Kanykey Albanova on 2024-04-07.
//

import Foundation
import FirebaseFirestore

class FavItemsViewModel: ObservableObject {
    @Published var favoriteItems: [Item] = []
    private var db = Firestore.firestore()

    func fetchFavoriteItems(userId: String) {
        let userFavoritesRef = db.collection("user").document(userId).collection("favorites")
        userFavoritesRef.getDocuments { [weak self] (snapshot, error) in
            guard let self = self else { return }

            guard let documents = snapshot?.documents else {
                print("No favorite items found for user")
                return
            }
            
            let group = DispatchGroup()

            for document in documents {
                group.enter()
                let itemId = document.documentID
                self.fetchItemDetails(itemId: itemId) { item in
                    if var item = item {
                        // If there's an image path, fetch the image.
                        if let imagePath = item.image_storage_path {
                            ImageService.shared.fetchImageForItem(imagePath: imagePath) { image in
                                DispatchQueue.main.async {
                                    item.image = image
                                    self.favoriteItems.append(item)
                                    group.leave()
                                }
                            }
                        } else {
                            // If there's no image, just append the item.
                            DispatchQueue.main.async {
                                self.favoriteItems.append(item)
                                group.leave()
                            }
                        }
                    } else {
                        group.leave()
                    }
                }
            }

            group.notify(queue: .main) {
                print("Finished fetching all favorite items")
            }
        }
    }
    private func fetchItemDetails(itemId: String, completion: @escaping (Item?) -> Void) {
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

