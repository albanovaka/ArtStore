//
//  User.swift
//  ArtStore
//
//  Created by Kanykey Albanova on 2024-04-04.
//

import Foundation
struct User: Identifiable, Codable {
    let id: String
    let fullname: String
    let email: String
    var favorites: [String] // This would be an array of favorite item IDs.
    var basket: [BasketItem] // This could be an array of basket items with more detail.
    
    var initials: String {
        let formatter = PersonNameComponentsFormatter()
        if let components = formatter.personNameComponents(from: fullname) {
            formatter.style = .abbreviated
            return formatter.string(from: components)
        }
        return ""
    }
}

struct BasketItem: Codable {
    let itemId: String
    let quantity: Int
}

extension User {
    static var MOCK_USER = User(
        id: NSUUID().uuidString,
        fullname: "Bob Sinclair",
        email: "test@gmail.com",
        favorites: ["item1ID", "item2ID", "item3ID"], // Mock list of favorite item IDs
        basket: [
            BasketItem(itemId: "item4ID", quantity: 1),
            BasketItem(itemId: "item5ID", quantity: 2)
        ]
    )
}

