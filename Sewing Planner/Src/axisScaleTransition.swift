//
//  axisScaleTransition.swift
//  Sewing Planner
//
//  Created by Art on 10/4/25.
//

import SwiftUI

extension AnyTransition {
  static func revealFrom(edge: Edge) -> AnyTransition {
    AnyTransition(RevealFrom(edge: edge))
  }
}

struct RevealFrom: Transition {
  var edge: Edge

  func body(content: Content, phase: TransitionPhase) -> some View {
    let (anchor, x, y): (UnitPoint, CGFloat, CGFloat) =
      switch edge {
      case .top:
        (UnitPoint.top, 1, phase.isIdentity ? 1 : 0.0001)
      case .bottom:
        (UnitPoint.bottom, 1, phase.isIdentity ? 1 : 0.0001)
      case .leading:
        (UnitPoint.leading, phase.isIdentity ? 1 : 0.0001, 1)
      case .trailing:
        (UnitPoint.trailing, phase.isIdentity ? 1 : 0.0001, 1)
      }

    return content.scaleEffect(
      x: x,
      y: y,
      anchor: anchor
    )
  }
}

struct Example: View {
  @State var text: String
  @State var note: String
  @State var isVisible = false

  var body: some View {
    VStack(alignment: .leading) {
      HStack(alignment: .firstTextBaseline) {
        Button("Toggle") {
          withAnimation(.easeOut(duration: 0.1)) {
            isVisible.toggle()
          }
        }
      }
      .frame(maxWidth: .infinity, alignment: .topLeading)
      if isVisible {
        VStack {
          TextField("example", text: $text).textFieldStyle(.plain)
            .padding(4)
          TextField("note", text: $note).textFieldStyle(.plain)
            .padding(4)
        }
        .padding(12)
        .background(Color.gray.opacity(0.2))
        .clipShape(RoundedRectangle(cornerRadius: 8))
        .transition(.revealFrom(edge: .leading))
      }
      Spacer()
    }
    .frame(width: .infinity, height: .infinity)
  }
}

#Preview {
  Example(text: "hello", note: "note")
    .padding(8)
}
