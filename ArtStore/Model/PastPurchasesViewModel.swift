//
//  PastPurchasesViewModel.swift
//  ArtStore
//
//  Created by Kanykey Albanova on 2024-04-11.
//

import Foundation
struct PastPurchase: Codable {
    var items: [PurchasedItem]
    var purchaseDate: Date?

    struct PurchasedItem: Codable {
        let id: String
        let name: String
        let price: Double
        let quantity: Int
    }
}
