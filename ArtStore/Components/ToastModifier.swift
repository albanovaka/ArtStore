//
//  ToastModifier.swift
//  ArtStore
//
//  Created by Kanykey Albanova on 2024-04-08.
//

// ToastModifier.swift
import SwiftUI

struct ToastModifier: ViewModifier {
    @Binding var isShowing: Bool
    let text: String

    func body(content: Content) -> some View {
        ZStack {
            content
            if isShowing {
                Text(text)
                    .padding()
                    .background(Color.black.opacity(0.7))
                    .foregroundColor(Color.white)
                    .cornerRadius(8)
                    // Position the toast on the screen; adjust as needed
                    .frame(width: UIScreen.main.bounds.width - 40)
                    .padding(.top, 50)
                    .transition(.slide)
                    .onAppear {
                        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
                            withAnimation {
                                isShowing = false
                            }
                        }
                    }
            }
        }
    }
}

extension View {
    func toast(isShowing: Binding<Bool>, text: String) -> some View {
        self.modifier(ToastModifier(isShowing: isShowing, text: text))
    }
}
