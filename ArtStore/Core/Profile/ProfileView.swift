//
//  ProfileView.swift
//  ArtStore
//
//  Created by Kanykey Albanova on 2024-04-04.
//

import SwiftUI

struct ProfileView: View {
    @EnvironmentObject var viewModel: AuthViewModel
    var body: some View {
        if let user = viewModel.currentUser {
            List {
                Section {
                    HStack {
                        Text (user.initials)
                            .font (.title)
                            . fontWeight (.semibold)
                            .foregroundColor (.white)
                            .frame (width: 72, height: 72) .background (Color (.systemGray3)) .clipShape (Circle ())
                        VStack(alignment: .leading, spacing: 4) {
                            Text (user.fullname)
                                . font (.title2)
                                .fontWeight (.semibold)
                                .padding (.top, 4)
                            Text(user
                                .email)
                                . font (.subheadline)
                                .foregroundColor(Color(.darkGray))
                        }
                    }
                }
                Section ("General") {
                    SettingsRowView (imageName: "gear", title: "Version", tintColor: Color(.systemGray))
                }
                Section {
                    NavigationLink(destination: PastPurchasesView(authViewModel: viewModel)) {
                        Text("View Past Purchases")
                    }
                }
                
                
                Section ("Account" ) {
                    Button {
                        viewModel.signOut()
                    } label: {
                        SettingsRowView (imageName: "arrow.left.circle.fill",
                                         title: "Sign Out", tintColor: .red)
                    }
                    
                    Button {
                        print ("Delete account")
                    } label: {
                        SettingsRowView (imageName: "xmark.circle.fill",
                                         title: "Delete Account", tintColor: .red)
                    }
                }
            }
        }
        else{
            Text("something went wrong")
            Button {
                viewModel.signOut()
                print(viewModel.$currentUser)
            } label: {
                SettingsRowView (imageName: "arrow.left.circle.fill",
                                 title: "Sign Out", tintColor: .red)
            }
        }
    }
}
struct ProfileView_Previews: PreviewProvider {
    static var previews: some View {
        ProfileView()
    }
}
