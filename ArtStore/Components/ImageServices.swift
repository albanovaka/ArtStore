//
//  ImageServices.swift
//  ArtStore
//
//  Created by Kanykey Albanova on 2024-04-08.
//

import Foundation
import FirebaseStorage
import UIKit

class ImageService {
    static let shared = ImageService()
    private init() {}

    func fetchImageForItem(imagePath: String, completion: @escaping (UIImage?) -> Void) {
        // Check if the imagePath is a valid 'gs://' URL
        if let imageUrl = URL(string: imagePath), imageUrl.scheme == "gs" {
            let imageRef = Storage.storage().reference(forURL: imagePath)

            // Fetch the image
            imageRef.getData(maxSize: 1 * 1024 * 1024) { data, error in
                if let imageData = data, let image = UIImage(data: imageData) {
                    DispatchQueue.main.async {
                        completion(image) // Image is fetched successfully
                    }
                } else {
                    print("Error fetching image for path: \(imagePath), error: \(String(describing: error?.localizedDescription))")
                    DispatchQueue.main.async {
                        completion(nil) // Handle the error
                    }
                }
            }
        } else {
            print("Invalid image path: \(imagePath)")
            DispatchQueue.main.async {
                completion(nil) // The image path is not valid
            }
        }
    }
}
