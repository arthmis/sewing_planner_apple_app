//
//  PrimaryButton.swift
//  Sewing Planner
//
//  Created by Art on 9/23/24.
//

import SwiftUI

struct PrimaryButton: View {
    var body: some View {
        Button("New Step") {}.buttonStyle(PrimaryButtonStyle())
            .frame(minWidth: 300, minHeight: 300)
    }
}

struct SectionViewButton<Content: View>: View {
    @State var isHovering = false
    let action: @MainActor () -> Void
    @ViewBuilder let label: () -> Content

    var body: some View {
        Button(action: action, label: label)
            .buttonStyle(SectionTertiaryButtonStyle())
            .scaleEffect(isHovering ? 1.15 : 1, anchor: .center)
            .onHover { hover in
                isHovering = hover
            }
            .animation(.easeIn(duration: 0.13), value: isHovering)
    }
}

#Preview {
    SectionViewButton {} label: {
        Image(systemName: "ellipsis")
    }
}
