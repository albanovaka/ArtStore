//
//  PaymentConfig.swift
//  ArtStore
//
//  Created by Kanykey Albanova on 2024-04-13.
//

import Foundation
class PaymentConfig {
    var paymentIntentClientSecret: String?
    static var shared: PaymentConfig = PaymentConfig ()
    private init() { }
}
