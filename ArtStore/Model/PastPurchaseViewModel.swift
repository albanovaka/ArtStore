//
//  PastPurchaseViewModel.swift
//  ArtStore
//
//  Created by Kanykey Albanova on 2024-04-11.
//

import Foundation
import FirebaseFirestore

import Foundation

struct PastPurchase: Codable, Identifiable {
    let id: String
    let items: [PurchasedItem]
    let purchaseDate: Date

    struct PurchasedItem: Codable, Identifiable {
        let id: String
        let name: String
        let price: Double
        let quantity: Int
    }
}

class PastPurchasesViewModel: ObservableObject {
    @Published var pastPurchases: [PastPurchase] = []
    @Published var isLoading = false
    @Published var error: Error?
    
    private var userId: String
    
    init(userId: String) {
        self.userId = userId
        self.fetchPastPurchases()
    }

    func fetchPastPurchases() {
        isLoading = true
        let pastPurchasesRef = Firestore.firestore().collection("user").document(userId).collection("pastPurchases")
        pastPurchasesRef.order(by: "purchaseDate", descending: true).getDocuments { [weak self] (querySnapshot, error) in
            self?.isLoading = false
            if let error = error {
                self?.error = error
                print("Error getting documents: \(error)")
            } else {
                self?.pastPurchases = querySnapshot?.documents.compactMap { document -> PastPurchase? in
                    let result = Result { try document.data(as: PastPurchase.self) }
                    switch result {
                    case .success(let purchase):
                        return purchase
                    case .failure(let error):
                        print("Error decoding past purchase: \(error)")
                        return nil
                    }
                } ?? []
            }
        }
    }
}

