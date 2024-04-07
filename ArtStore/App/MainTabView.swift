//
//  MainTabView.swift
//  ArtStore
//
//  Created by Kanykey Albanova on 2024-04-07.
//

import SwiftUI

struct MainTabView: View {
    var body: some View {
        TabView {
                    ItemsGridView()
                        .tabItem {
                            Label("Home", systemImage: "house")
                        }

                    FavUserItemView()
                        .tabItem {
                            Label("Favorites", systemImage: "heart")
                        }

                    BasketView()
                        .tabItem {
                            Label("Basket", systemImage: "cart")
                        }

                    ProfileView()
                        .tabItem {
                            Label("Account", systemImage: "person")
                        }
                }
    }
}

struct MainTabView_Previews: PreviewProvider {
    static var previews: some View {
        MainTabView()
    }
}
