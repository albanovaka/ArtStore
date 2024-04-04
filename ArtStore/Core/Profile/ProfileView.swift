//
//  ProfileView.swift
//  ArtStore
//
//  Created by Kanykey Albanova on 2024-04-04.
//

import SwiftUI

struct ProfileView: View {
    var body: some View {
        List {
            Section {
                HStack {
                    Text ("MJ")
                        .font (.title)
                        . fontWeight (.semibold)
                        .foregroundColor (.white)
                        .frame (width: 72, height: 72) .background (Color (.systemGray3)) .clipShape (Circle ())
                    VStack(alignment: .leading, spacing: 4) {
                        Text ("Michael Jordan" )
                            . font (.title2)
                            .fontWeight (.semibold)
                            .padding (.top, 4)
                        Text("test@gmail.com")
                            . font (.subheadline)
                            .accentColor (.gray)
                    }
                }
            }
            Section ("General") {
                SettingsRowView (imageName: "gear", title: "Version", tintColor: Color(.systemGray))
            }
            
            Section ("Account" ) {
                Button {
                    print ("Sign out..")
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
}
struct ProfileView_Previews: PreviewProvider {
    static var previews: some View {
        ProfileView()
    }
}
