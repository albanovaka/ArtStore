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
    
    // Same grid layout as ItemsGridView
    let columns: [GridItem] = Array(repeating: .init(.flexible()), count: 2)
    
    var body: some View {
        NavigationView {
            ScrollView {
                LazyVGrid(columns: columns, spacing: 20) {
                    ForEach(favItemsViewModel.favoriteItems) { item in
                        NavigationLink(destination: itemDetailView(item: item)) {
                            ItemCell(item: item)
                        }
                    }
                }
                .padding()
            }
            .onAppear {
                if let userId = authViewModel.currentUser?.id {
                    favItemsViewModel.favoriteItems.removeAll() // Clear existing items
                    favItemsViewModel.fetchFavoriteItems(userId: userId)
                }
            }
            .background(Color(hex: "FEC7B4"))
            .foregroundColor(Color(hex: "F7418F"))
        }
    }
}

// Extract the item cell into its own view for reusability
struct ItemCell: View {
    let item: Item
    
    var body: some View {
        VStack {
            if let image = item.image {
                Image(uiImage: image)
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(minWidth: 0, maxWidth: .infinity)       .aspectRatio(1, contentMode: .fit)
                    .frame(minWidth: 0, maxWidth: .infinity, minHeight: 150, maxHeight: 150)
                    .clipped()
            } else {
                Rectangle()
                    .fill(Color.secondary)
                    .frame(width: 100, height: 100)
                    .cornerRadius(10)
                    .overlay(Text("Loading...").foregroundColor(.white))
            }
            Text(item.description)
                .font(.caption)
                .lineLimit(1)
                .frame(maxWidth: .infinity, alignment: .center)
                .padding(.vertical, 8)
        }
        .background(Color(hex: "FFF3C7"))
        .cornerRadius(10)
        .shadow(radius: 5)
        .padding(.all, 10.0)
        .frame(minHeight: 300)
    }
}


struct FavUserItemView_Previews: PreviewProvider {
    static var previews: some View {
        FavUserItemView()
    }
}
