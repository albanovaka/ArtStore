//
//  PaymentConfig.swift
//  ArtStore
//
//  Created by Kanykey Albanova on 2024-04-13.
//

import Foundation
class PaymentConfig {
    var paymentIntentClientSecret: String?
    var paymentIntendId: String?
    var paymentSucceeded: Bool = false
    static var shared: PaymentConfig = PaymentConfig ()
    private init() { }
}
