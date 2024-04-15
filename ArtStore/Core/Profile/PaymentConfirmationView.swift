//
//  PaymentConfirmationView.swift
//  ArtStore
//
//  Created by Kanykey Albanova on 2024-04-14.
//

import SwiftUI

struct PaymentConfirmationView: View {
    var body: some View {
        Text("Your transaction confirmation id is \(PaymentConfig.shared.paymentIntendId ?? "")")
        
    }
}

#Preview {
    PaymentConfirmationView()
}
