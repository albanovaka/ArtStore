//
//  FavUserItemView.swift
//  ArtStore
//
//  Created by Kanykey Albanova on 2024-04-07.
//

import SwiftUI

struct FavUserItemView: View {
    @EnvironmentObject var authViewModel: AuthViewModel
    @StateObject var favItemsViewModel = FavItemsViewModel()
    var body: some View {
        List(favItemsViewModel.favoriteItems) { item in
                    Text(item.description)
                    // Display each favorite item here
                }
        .onAppear {
            if let userId = authViewModel.currentUser?.id {
                favItemsViewModel.favoriteItems.removeAll() // Clear existing items
                favItemsViewModel.fetchFavoriteItems(userId: userId)
            }
        }
    }
}

struct FavUserItemView_Previews: PreviewProvider {
    static var previews: some View {
        FavUserItemView()
    }
}
