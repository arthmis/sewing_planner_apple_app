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
            .font(.custom("CooperHewitt-Regular", size: 18))
            .padding([.top, .bottom], 12)
            .padding([.leading, .trailing], 16)
            .background(Color(hex: 0x131944, opacity: 1.0))
            .foregroundColor(.white)
            .clipShape(RoundedRectangle(cornerRadius: 12))
            .scaleEffect(isPressed ? 0.95 : 1)
            .brightness(isPressed ? -0.05 : 0)
            .shadow(color: Color(hex: 0x000000, opacity: 0.25), radius: isPressed ? 1.5 : 3, x: 0, y: 4)
            .animation(.easeIn(duration: 0.1), value: isPressed)
    }
}

struct DeleteButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        let isPressed = configuration.isPressed
        configuration.label
//            .font(.custom("CooperHewitt-Regular", size: 16))
//            .font(.custom("CooperHewitt-Regular", size: 16))
            .padding(8)
            .background(Color(hex: 0xF85A3E, opacity: 1.0))
            .foregroundStyle(.white)
            .clipShape(RoundedRectangle(cornerRadius: 4))
            .scaleEffect(isPressed ? 0.95 : 1)
            .brightness(isPressed ? -0.05 : 0)
//            .shadow(color: Color(hex: 0x000000, opacity: 0.25), radius: isPressed ? 1.5 : 3, x: 0, y: 4)
            .animation(.easeIn(duration: 0.1), value: isPressed)
    }
}

struct SaveProjectButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        let isPressed = configuration.isPressed
        configuration.label
            .padding([.top, .bottom], 7.5)
            .padding([.leading, .trailing], 18)
            .background(Color(hex: 0x131944, opacity: 1.0))
            .foregroundColor(.white)
            .clipShape(RoundedRectangle(cornerRadius: 9))
            .scaleEffect(isPressed ? 0.95 : 1)
            .brightness(isPressed ? -0.05 : 0)
            .shadow(color: Color(hex: 0x000000, opacity: 0.25), radius: isPressed ? 1.5 : 3, x: 0, y: 4)
            .animation(.easeIn(duration: 0.1), value: isPressed)
    }
}

struct AddNewSectionButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        let isPressed = configuration.isPressed
        configuration.label
            .font(.custom("CooperHewitt-Regular", size: 16))
            .padding(8)
            .background(Color(hex: 0x131944, opacity: 1.0))
            .foregroundColor(.white)
            .clipShape(Circle())
            .scaleEffect(isPressed ? 0.95 : 1)
            .brightness(isPressed ? -0.05 : 0)
            .shadow(color: Color(hex: 0x000000, opacity: 0.25), radius: isPressed ? 1.5 : 3, x: 0, y: 4)
            .animation(.easeIn(duration: 0.1), value: isPressed)
    }
}

struct SectionTertiaryButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        let isPressed = configuration.isPressed
        configuration.label
            .font(.system(size: 22))
            .padding([.vertical, .leading], 10)
            .foregroundStyle(isPressed ? Color(.blue) : Color(hex: 0x333333))
            .scaleEffect(isPressed ? 0.95 : 1)
            .brightness(isPressed ? -0.05 : 0)
            .background(.white)
            .animation(.easeIn(duration: 0.1), value: isPressed)
    }
}

struct AddImageButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        let isPressed = configuration.isPressed
        configuration.label
            .foregroundColor(Color(hex: 0x131944, opacity: 1.0))
            .font(.system(size: 24))
            .padding(8)
            .clipShape(RoundedRectangle(cornerRadius: 9))
            .scaleEffect(isPressed ? 0.95 : 1)
            .brightness(isPressed ? -0.05 : 0)
            .shadow(color: Color(hex: 0x000000, opacity: 0.25), radius: isPressed ? 1.5 : 3, x: 0, y: 4)
            .animation(.easeIn(duration: 0.1), value: isPressed)
    }
}
