//
//  SettingsRowView.swift
//  ArtStore
//
//  Created by Kanykey Albanova on 2024-04-04.
//

import SwiftUI

struct SettingsRowView: View {
    let imageName: String
    let title: String
    let tintColor: Color
    var body: some View {
        HStack (spacing: 12) {
            
            Image (systemName: imageName)
                .imageScale (.small)
                .font (.title)
                .foregroundColor (tintColor)
            
            Text(title)
                .font (.body)
                .foregroundColor(.black)
        }
    }
}

struct SettingsRowView_Previews: PreviewProvider {
    static var previews: some View {
        SettingsRowView(imageName: "gear", title: "Version", tintColor: Color(.systemGray))
    }
}
