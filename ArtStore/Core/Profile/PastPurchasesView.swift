//
//  PastPurchasesView.swift
//  ArtStore
//
//  Created by Kanykey Albanova on 2024-04-11.

import SwiftUI
import FirebaseFirestoreSwift

struct PastPurchasesView: View {
    @EnvironmentObject var authViewModel: AuthViewModel
    @StateObject var viewModel: PastPurchasesViewModel
    
    init(authViewModel: AuthViewModel) {
        // Initialize the viewModel with the user ID from authViewModel
        let userId = authViewModel.userSession?.uid ?? ""
        _viewModel = StateObject(wrappedValue: PastPurchasesViewModel(userId: userId))
    }
    
    var body: some View {
        List {
            if viewModel.isLoading {
                ProgressView("Loading...")
            } else if let error = viewModel.error {
                Text("Error: \(error.localizedDescription)")
            } else {
                ForEach(viewModel.pastPurchases) { purchase in
                    Section(header: Text("Purchase Date: \(purchase.purchaseDate, formatter: itemFormatter)")) {
                        ForEach(purchase.items) { item in
                            VStack(alignment: .leading) {
                                Text(item.name)
                                    .fontWeight(.bold)
                                HStack {
                                    Text("\(item.quantity)x")
                                        .foregroundColor(.secondary)
                                    Spacer()
                                    Text("$\(item.price, specifier: "%.2f")")
                                }
                            }
                        }
                    }
                }
            }
        }
        .navigationTitle("Past Purchases")
    }
}

private let itemFormatter: DateFormatter = {
    let formatter = DateFormatter()
    formatter.dateStyle = .long
    formatter.timeStyle = .none
    return formatter
}()

// Provide a preview for the SwiftUI preview canvas
struct PastPurchasesView_Previews: PreviewProvider {
    static var previews: some View {
        PastPurchasesView(authViewModel: AuthViewModel())
    }
}

