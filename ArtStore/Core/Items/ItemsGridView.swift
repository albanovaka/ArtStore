//
//  ItemsGridView.swift
//  ArtStore
//
//  Created by Kanykey Albanova on 2024-04-05.
//

import SwiftUI
import FirebaseFirestore
import Kingfisher

struct ItemsGridView: View {
    @EnvironmentObject var viewModel: AuthViewModel
    @StateObject var itemsViewModel = ItemsViewModel()
    let columns: [GridItem] = Array(repeating: .init(.flexible()), count: 2)
    var body: some View {
        
        ScrollView {
            LazyVGrid(columns: columns) {
                ForEach(itemsViewModel.items) { item in
                    VStack {
                        KFImage(URL(string: item.image_url))
                            .resizable()
                                .scaledToFit()
                                .frame(width: 100, height: 100)
                                .cornerRadius(10)
                            
                        
                        Text(item.description)
                            .font(.caption)
                            .lineLimit(1)
                    }
                }
            }
        }
        .onAppear {
            itemsViewModel.fetchItems()
        }
    }
}

struct ItemsGridView_Previews: PreviewProvider {
    static var previews: some View {
        ItemsGridView()
            .environmentObject(AuthViewModel())
            .environmentObject(ItemsViewModel())
    }
}
