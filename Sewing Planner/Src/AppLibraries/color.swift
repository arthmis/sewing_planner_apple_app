//
//  color.swift
//  Sewing Planner
//
//  Created by Art on 10/30/24.
//

import SwiftUI

// TODO: think about how to make this better or accept strings for values instead
extension Color {
    init(hex: Int, opacity: Double = 1) {
        self.init(
            .sRGB,
            red: Double((hex >> 16) & 0xFF) / 255,
            green: Double((hex >> 08) & 0xFF) / 255,
            blue: Double((hex >> 00) & 0xFF) / 255,
            opacity: opacity
        )
    }
}
