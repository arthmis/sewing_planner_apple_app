//
//  AppButtonStyles.swift
//  Sewing Planner
//
//  Created by Art on 9/23/24.
//

import Foundation
import SwiftUI

struct PrimaryButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        let isPressed = configuration.isPressed
        configuration.label
            .padding([.top, .bottom], 7.5)
            .padding([.leading, .trailing], 18)
            .background(Color(hex: 0x1A1A1A, opacity: 0.84))
            .foregroundColor(.white)
            .clipShape(RoundedRectangle(cornerRadius: 9))
            .scaleEffect(isPressed ? 0.95 : 1)
            .brightness(isPressed ? -0.05 : 0)
            .shadow(color: Color(hex: 0x000000, opacity: 0.25), radius: isPressed ? 1.5 : 3, x: 0, y: 4)
            .animation(.easeIn(duration: 0.1), value: isPressed)
    }
}

struct SecondaryButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        let isPressed = configuration.isPressed
        configuration.label
            .padding([.top, .bottom], 7.5)
            .padding([.leading, .trailing], 18)
            .background(Color(hex: 0xEFEFEF))
            .foregroundColor(.black)
            .clipShape(RoundedRectangle(cornerRadius: 9))
            .scaleEffect(isPressed ? 0.95 : 1)
            .brightness(isPressed ? -0.05 : 0)
            .shadow(color: Color(hex: 0x000000, opacity: 0.25), radius: isPressed ? 1.5 : 3, x: 0, y: 4)
            .animation(.easeIn(duration: 0.1), value: isPressed)
    }
}
