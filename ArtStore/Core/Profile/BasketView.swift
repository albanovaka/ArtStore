//
//  BasketView.swift
//  ArtStore
//
//  Created by Kanykey Albanova on 2024-04-07.
//

import SwiftUI

struct BasketView: View {
        
    @EnvironmentObject var authViewModel: AuthViewModel
       @StateObject var basketItemsViewModel = BasketItemsViewModel()
       
       var body: some View {
           NavigationView {
               List {
                   ForEach(basketItemsViewModel.basketItems, id: \.id) { item in
                       Text(item.name) // Replace this with your custom item row view
                       // Add more item details here
                   }
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
        BasketView()
    }
}
