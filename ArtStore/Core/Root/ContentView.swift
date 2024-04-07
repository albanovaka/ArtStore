//
//  ContentView.swift
//  ArtStore
//
//  Created by Kanykey Albanova on 2024-04-03.
//

import SwiftUI

struct ContentView: View {
    @EnvironmentObject var viewModel: AuthViewModel
    var body: some View {
        Group{
            if viewModel.userSession != nil{
                ItemsGridView()
            }else{
                LoginView()
            }
        }
    }
}
extension ContentView {
    func getRootViewController() -> UIViewController {
        guard let screen = UIApplication.shared.connectedScenes.first as? UIWindowScene else {
            return .init()
        }

        guard let root = screen.windows.first?.rootViewController else {
            return .init()
        }
        

        return root
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
            .environmentObject(AuthViewModel())
    }
}
