//
//  PrimaryTextField.swift
//  Sewing Planner
//
//  Created by Art on 9/24/24.
//

import SwiftUI

public struct PlaceholderStyle: ViewModifier {
  var showPlaceHolder: Bool
  var placeholder: String

  public func body(content: Content) -> some View {
    ZStack(alignment: .leading) {
      let padding = 10.0
      content
        .font(.custom("SourceSans3-Regular", size: 16))
        .padding([.all], padding)
        .background(
          RoundedRectangle(cornerRadius: 9)
            .fill(Color(hex: 0xF9F9F9))
        )
        .shadow(color: Color(hex: 0xDFDFDF), radius: 2, x: 0, y: 3)
        .overlay {
          RoundedRectangle(cornerRadius: 9)
            .strokeBorder(Color.gray, lineWidth: 1)
        }
      if showPlaceHolder {
        Text(placeholder)
          .foregroundStyle(Color.gray)
          .padding([.all], padding)
          .allowsHitTesting(false)
      }
    }
  }
}

extension View {
  func primaryTextFieldStyle(
    when shouldShow: Bool,
    placeholder: String
  ) -> some View {
    modifier(
      PlaceholderStyle(showPlaceHolder: shouldShow, placeholder: placeholder)
    )
  }
}

struct PrimaryTextField: View {
  @State var text = ""
  var body: some View {
    VStack {
      TextField("hello", text: $text, axis: .vertical)
        .textFieldStyle(.plain)
        .padding(.bottom, 5)
        .overlay(
          Rectangle()
            .fill(.gray)
            .frame(maxWidth: .infinity, maxHeight: 5),
          alignment: .bottom
        )
        .frame(width: 200, height: 200)
        .background(Color.white)
    }
  }
}

#Preview {
  //    PrimaryTextField()
  @Previewable @State var text = ""
  TextField("", text: $text)
    .textFieldStyle(.plain)
    .primaryTextFieldStyle(when: text.isEmpty, placeholder: "hi there")
}
