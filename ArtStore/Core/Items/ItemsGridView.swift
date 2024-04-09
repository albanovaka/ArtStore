//
//  ItemsGridView.swift
//  ArtStore
//
//  Created by Kanykey Albanova on 2024-04-05.
//

import SwiftUI
import FirebaseFirestore


struct ItemsGridView: View {
    @EnvironmentObject var viewModel: AuthViewModel
    @StateObject var itemsViewModel = ItemsViewModel()
    
    @State private var showingToast = false
    @State private var toastMessage = ""
    
    let columns: [GridItem] = Array(repeating: .init(.flexible()), count: 2)

    var body: some View {
        NavigationView {
            ScrollView {
                LazyVGrid(columns: columns, spacing: 20) {
                    ForEach(itemsViewModel.items) { item in
                        NavigationLink(destination: itemDetailView(item: item)){
                            VStack {
                                VStack{
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
                                            .overlay(
                                                Text("Loading...")
                                                    .foregroundColor(.white)
                                            )
                                    }
                                    
                                    VStack{
                                        Text(item.name)
                                            .font(.caption)
                                            .lineLimit(1)
                                            .frame(maxWidth: .infinity, alignment: .center)
                                            .padding(.vertical, 8)
                                        if let price = item.price {
                                            Text("$\(price, specifier: "%.2f")") 
                                        } else {
                                            Text("Price not available")
                                        }

                                    }
                                    HStack {
                                        Button(action: {
                                            print("button tapped")
                                            if let itemID = item.id {
                                                    handleToggleFavorite(for: item)
                                                }
                                        }) {
                                            Image(systemName: "heart")
                                                .foregroundColor(.white)
                                                        .padding(10)
                                                        .background(Circle().fill(Color.gray
                                                                                 ))
                                                        .overlay(
                                                            Circle()
                                                                .stroke(Color.gray, lineWidth: 2))
                                        }
                                        .buttonStyle(BorderlessButtonStyle())
                                        
                                        
                                        Spacer()
                                        
                                        Button(action: {
                                            if let itemID = item.id {
                                                    viewModel.addToBasket(itemId: itemID) { success, error in
                                                        if success {
                                                            // Successfully added to basket, show a toast message
                                                            self.showToast(message: "Added to your basket")
                                                        } else if let error = error {
                                                            // Failed to add to basket, handle the error
                                                            print("Failed to add to basket: \(error.localizedDescription)")
                                                            // Optionally show a toast message for the error
                                                            self.showToast(message: "Error: \(error.localizedDescription)")
                                                        }
                                                    }
                                                }
                                        }) {
                                            Image(systemName: "plus")
                                                .foregroundColor(.white)
                                                .padding(10) // Adjust padding to your preference
                                                .background(Circle().fill(Color(hex: "F7418F")))
                                        }
                                        .buttonStyle(BorderlessButtonStyle())
                                    }
                                    
                                }
                                
                                
                                .padding(.all)
                                
                            }
                            .background(Color(hex: "FFF3C7"))
                            .cornerRadius(10)
                            .shadow(radius: 5)
                            .padding(.all, 10.0)
                            .frame(minHeight: 300)
                        }
                    }
                }
                .padding()
            }
            .onAppear {
                itemsViewModel.fetchItems()
            }
            .background(Color(hex: "FEC7B4"))
            .toast(isShowing: $showingToast, text: toastMessage)
            .foregroundColor(Color(hex: "F7418F"))
        }
        
        
    }
    private func handleToggleFavorite(for item: Item) {
        // Check that we have a valid item ID
        guard let itemId = item.id else { return }

        viewModel.toggleFavorite(itemId: itemId) { wasAdded in
            // Now we are sure that `itemId` is not nil
            let message = wasAdded ? "Added to Favorites" : "Removed from Favorites"
            showToast(message: message)
        }
    }

      
      private func showToast(message: String) {
          // Update the toast message and show the toast
          toastMessage = message
          showingToast = true
          // Hide the toast after 2 seconds
          DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
              showingToast = false
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
