//
//  BasketView.swift
//  ArtStore
//
//  Created by Kanykey Albanova on 2024-04-07.
//

import SwiftUI

struct BasketItemRow: View {
    
    var basketItem: Item
    var index: Int
    var basketViewModel: BasketItemsViewModel

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

            // Minus button
            Button(action: {
                basketViewModel.decreaseQuantity(index: index)
            }) {
                Image(systemName: "minus.circle")
            }
            .buttonStyle(BorderlessButtonStyle())
          //  .disabled(basketItem.quantity! <= 1)  // Disable if quantity is 1 or less

            // Quantity display
            Text("\(basketItem.quantity ?? 1)")
            
            // Plus button
            Button(action: {
                basketViewModel.increaseQuantity(index: index)
            }) {
                Image(systemName: "plus.circle")
            }
            .buttonStyle(BorderlessButtonStyle())
        }
        
    }
}
struct BasketView: View {
    
    @EnvironmentObject var authViewModel: AuthViewModel
    @StateObject var basketItemsViewModel: BasketItemsViewModel
    @EnvironmentObject var viewRouter: ViewRouter
    
    init(authViewModel: AuthViewModel) {
        _basketItemsViewModel = StateObject(wrappedValue: BasketItemsViewModel(authViewModel: authViewModel))
    }
    var body: some View {
        NavigationView {
            VStack {
                if viewRouter.showPaymentConfirmation {
                    PaymentConfirmationView()
                }
                List {
                    ForEach(Array(basketItemsViewModel.basketItems.enumerated()), id: \.element.id) { index, item in
                                            BasketItemRow(basketItem: item, index: index, basketViewModel: basketItemsViewModel)
                                        }
                }

                HStack {
                    Spacer()
                    Text("Total: $\(basketItemsViewModel.totalPrice, specifier: "%.2f")")
                        .font(.title)
                        .padding()
                    Spacer()
//                    NavigationLink(destination: CheckoutView(basketItemsViewModel: basketItemsViewModel), label: {
//                        Text("Checkout")
//                            .font(.headline)
//                            .foregroundColor(.white)
//                            .padding()
//                            .frame(height: 50)
//                            .background(Color.blue)
//                            .cornerRadius(8)
//                    })
                    Button("Checkout") {
                        // Set a condition or update a state before navigating
                        self.viewRouter.showCheckout = true
                    }
                    .background(
                        NavigationLink(destination: CheckoutView(basketItemsViewModel: basketItemsViewModel), isActive: $viewRouter.showCheckout) {
                            EmptyView()
                        }
                    )

                    Spacer()
                }
                .background(Color.clear)
                .frame(maxWidth: .infinity, maxHeight: 50)

            }
            .navigationTitle("Basket")
            .onAppear {
                if let userId = authViewModel.currentUser?.id {
                    basketItemsViewModel.fetchBasketItems(userId: userId)
                }
            }
        }
    }
}







struct BasketView_Previews: PreviewProvider {
    static var previews: some View {
        BasketView(authViewModel: AuthViewModel())
    }
}
