//
//  itemDetailView.swift
//  ArtStore
//
//  Created by Kanykey Albanova on 2024-04-07.
//

import SwiftUI

struct itemDetailView: View {
    @EnvironmentObject var viewModel: AuthViewModel
    let item: Item
    var body: some View {
        VStack {
            if let image = item.image {
                Image(uiImage: image)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
            }
            Text(item.description)
                .padding()
            // Any other details you want to show about the item
            Button(action: {
                print("button tapped")
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
            
        }
        .navigationTitle(Text(item.description))
    }
}

struct itemDetailView_Previews: PreviewProvider {
    static var previews: some View {
        let dummyItem = Item(id: "1", description: "Example item", item_id: "xyz", image: UIImage(named: "placeholder"), image_storage_path: "path/to/example.jpg")
        itemDetailView(item: dummyItem)
    }
}
