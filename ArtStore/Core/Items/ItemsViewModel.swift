//
//  ItemsViewModel.swift
//  ArtStore
//
//  Created by Kanykey Albanova on 2024-04-05.
//

import Foundation
import FirebaseFirestore
import FirebaseStorage

struct Item: Identifiable, Codable {
    @DocumentID var id: String?
    let description: String
    let item_id: String
    var image: UIImage? = nil // This is for holding the UIImage after fetching from storage
    var image_storage_path: String? // This should be a String path, not UIImage

    // Conform to `Codable` but exclude `image`
    private enum CodingKeys: String, CodingKey {
        case id
        case description
        case item_id
        case image_storage_path // Only include this if you wish to encode/decode this property
    }
}



class ItemsViewModel: ObservableObject {
    @Published var items: [Item] = []
    private var db = Firestore.firestore()
    private let storage = Storage.storage()

    func fetchItems() {
        db.collection("items").getDocuments { [weak self] (querySnapshot, error) in
            guard let self = self else { return }
            
            if let e = error {
                print("Error fetching items: \(e)")
            } else if let snapshotDocuments = querySnapshot?.documents, !snapshotDocuments.isEmpty {
                var itemsWithImages: [Item] = snapshotDocuments.compactMap { document -> Item? in
                    return try? document.data(as: Item.self)
                }
                
                let group = DispatchGroup()
                
                for (index, item) in itemsWithImages.enumerated() {
                    guard let imagePath = item.image_storage_path else { continue }
                    group.enter()
                    self.fetchImageForItem(imagePath: imagePath) { image in
                        DispatchQueue.main.async {
                            itemsWithImages[index].image = image
                            group.leave()
                        }
                    }
                }
                
                group.notify(queue: .main) {
                    self.items = itemsWithImages
                }
            } else {
                print("No items found in Firestore.")
            }
        }
    }

    private func fetchImageForItem(imagePath: String, completion: @escaping (UIImage?) -> Void) {
        // Assuming imagePath is like "gs://bucketname/path/to/image.png"
        // We need to extract the "/path/to/image.png" part
        
        // This will create an URL object if the string is a valid URL, else it will be nil
        if let imageUrl = URL(string: imagePath),
           let imagePathWithoutBucket = imageUrl.path.removingPercentEncoding {
            // Create a reference to the image using the path extracted from the URL
            let imageRef = storage.reference(withPath: imagePathWithoutBucket)
            
            // Now fetch the image
            imageRef.getData(maxSize: 1 * 1024 * 1024) { data, error in
                if let imageData = data, let image = UIImage(data: imageData) {
                    completion(image)
                } else {
                    completion(nil)
                    if let error = error {
                        print("Error downloading image: \(error.localizedDescription)")
                    }
                }
            }
        } else {
            print("Invalid image path: \(imagePath)")
            completion(nil)
        }
    }



}

