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
        NavigationView {
            ScrollView {
                LazyVGrid(columns: columns, spacing: 20) {
                    ForEach(itemsViewModel.items) { item in
                        VStack {
                            VStack{
                                if let image = item.image {
                                    Image(uiImage: image)
                                        .resizable()
                                        .scaledToFill()
                                        .frame(minWidth: 0, maxWidth: .infinity)       .aspectRatio(1, contentMode: .fit)             .cornerRadius(10)
                                        .clipped()
                                } else {
                                    
                                    Rectangle()
                                        .fill(Color.secondary)
                                        .frame(width: 100, height: 100)
                                        .cornerRadius(10)
                                        .overlay(
                                            Text("Loading...")
                                                .foregroundColor(.white)
                                        )
                                }
                                Text(item.description)
                                    .font(.caption)
                                    .lineLimit(1)
                                    .frame(maxWidth: .infinity, alignment: .center)
                                    .padding(.vertical, 8)
                            }
                            .padding(.all)
                            
                        }
                        .background(Color(hex: "FFF3C7"))
                        .cornerRadius(10)
                        .shadow(radius: 5)
                        .padding(.all, 10.0)
                    }
                }
                .padding()
            }
            .navigationTitle("Items")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    NavigationLink(destination: ProfileView()) {
                        Text("Go to Profile")
                    }
                }
            }
            .onAppear {
                itemsViewModel.fetchItems()
            }
            .background(Color(hex: "FEC7B4"))
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
