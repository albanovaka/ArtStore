//
//  ItemsViewModel.swift
//  ArtStore
//
//  Created by Kanykey Albanova on 2024-04-05.
//

import Foundation
import FirebaseFirestore

struct Item: Identifiable, Codable {
    @DocumentID var id: String?
    let description: String
    let image_url: String
    let item_id: String
}



class ItemsViewModel: ObservableObject {
    @Published var items: [Item] = []

    private var db = Firestore.firestore()

 
    func fetchItems() {
        db.collection("items").getDocuments { (querySnapshot, error) in
            if let e = error {
                print("Error fetching items: \(e)")
            } else if let snapshotDocuments = querySnapshot?.documents, !snapshotDocuments.isEmpty {
                DispatchQueue.main.async {
                    self.items = snapshotDocuments.compactMap { document -> Item? in
                        return try? document.data(as: Item.self)
                    }
                }
                print("Items fetched: \(self.items)")
            } else {
                print("No items found in Firestore.")
            }
        }
    }

}