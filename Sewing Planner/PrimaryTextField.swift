//
//  SwiftUIView.swift
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
                .font(.custom("CooperHewitt-regular", size: 22))
                .padding([.all], padding)
                .background(RoundedRectangle(cornerRadius: 9)
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
            }
        }
    }
}

extension View {
    func primaryTextFieldStyle(
        when shouldShow: Bool,
        placeholder: String
    ) -> some View {
        modifier(PlaceholderStyle(showPlaceHolder: shouldShow, placeholder: placeholder)
        )
    }
}

public struct TitleTextFieldStyle: ViewModifier {
    var showPlaceHolder: Bool
    var placeholder: String

    func style(content: some View) -> some View {
        content
//            .font(.custom("CooperHewitt-Medium", size: 20))
            .padding([.vertical], 10)
            .padding(.top, 6)
            .frame(maxWidth: .infinity, maxHeight: 40, alignment: .leading)
    }

    public func body(content: Content) -> some View {
        ZStack(alignment: .leading) {
            style(content: content)
            if showPlaceHolder {
                style(content: Text(placeholder))
            }
        }
    }
}

extension View {
    func titleTextFieldStyle(
        when shouldShow: Bool,
        placeholder: String
    ) -> some View {
        modifier(TitleTextFieldStyle(showPlaceHolder: shouldShow, placeholder: placeholder)
        )
    }
}

struct PrimaryTextField: View {
    @State var text = ""
    var body: some View {
        VStack {
            //            TextField("hi", text: $text, placeholder: Text("new item text"), axis: .vertical)
            TextField("", text: $text, axis: .vertical)
                .textFieldStyle(.plain)
//                .primaryTextFieldStyle(when: text.isEmpty, placeholder: "Text")
                .titleTextFieldStyle(when: text.isEmpty, placeholder: "Text")
//                .modifier(PlaceholderStyle(showPlaceHolder: text.isEmpty, placeholder: "Text"))
                .frame(minWidth: 200, maxWidth: 200, minHeight: 200)
                .padding()
                .background(Color.white)
        }
    }
}

#Preview {
    PrimaryTextField()
}
