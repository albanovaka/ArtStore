//
//  BasketView.swift
//  ArtStore
//
//  Created by Kanykey Albanova on 2024-04-07.
//

import SwiftUI


struct BasketItemRow: View {
    var basketItem: Item // Assuming Item is your model similar to CartItem

    var body: some View {
        HStack {
            if let image = basketItem.image {
                Image(uiImage: image)
                    .resizable()
                    .frame(width: 100, height: 100)
                    .clipShape(Circle())
            }

            VStack(alignment: .leading) {
                Text(basketItem.name).fontWeight(.semibold)
                if let price = basketItem.price {
                    Text("$\(price, specifier: "%.2f")")
                }
                if let quantity = basketItem.quantity {
                    Text("Quantity: \(quantity)")
                }
            }
            Spacer()
        }
    }
}

struct BasketView: View {
    
    @EnvironmentObject var authViewModel: AuthViewModel
    @StateObject var basketItemsViewModel = BasketItemsViewModel()
    
    var body: some View {
        NavigationView {
            List {
                ForEach(basketItemsViewModel.basketItems) { item in
                    BasketItemRow(basketItem: item)
                }
                .onDelete(perform: deleteItems)
            }
            .navigationTitle("Basket")
            .onAppear {
                if let userId = authViewModel.currentUser?.id {
                    basketItemsViewModel.fetchBasketItems(userId: userId)
                }
            }
        }
    }

    func deleteItems(at offsets: IndexSet) {
        // Implement item deletion
    }
}







struct BasketView_Previews: PreviewProvider {
    static var previews: some View {
        BasketView()
    }
}
