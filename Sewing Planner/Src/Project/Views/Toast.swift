//
//  Toast.swift
//  Sewing Planner
//
//  Created by Art on 11/11/24.
//

import SwiftUI

struct Toast: View {
    @Binding var showToast: Bool
    private var text: String
    
    init(showToast: Binding<Bool>, text: String) {
        _showToast = showToast
        self.text = text
    }

    var body: some View {
        HStack {
            Text(text)
                .font(.custom("SourceSans3-Regular", size: 16))
                .foregroundStyle(.white)
                .padding([.horizontal, .vertical], 20)
                .frame(maxWidth: .infinity, alignment: .leading)
            Button {
                showToast = false
            } label: {
                Image(systemName: "xmark")
                    .foregroundStyle(.white)
                    .padding(10)
                    .contentShape(Rectangle())
            }
            .buttonStyle(.plain)
            .padding(.leading, 20)
        }
        .padding(10)
        .background(RoundedRectangle(cornerRadius: 9)
            .fill(
                // TODO: look into more gradients to create pastel/glassy look
                LinearGradient(colors: [Color(hex: 0xE62020, opacity: 1), Color(hex: 0xF40009, opacity: 1)], startPoint: .leading, endPoint: .trailing)
            )
            .shadow(radius: 3, x: 0, y: 4))
        .frame(minWidth: 200, maxWidth: 400, minHeight: 100, maxHeight: 200)
        .onAppear {
            Task { @MainActor in
                try await Task.sleep(for: .seconds(5))
                showToast = false
            }
        }
    }
}

#Preview {
    @Previewable @State var showToast = true
    var text = "This is some text to demonstrate how the toast will look with long text"

    VStack {
        Button("Toggle Toast") {
            showToast.toggle()
        }
        if showToast {
            Toast(showToast: $showToast, text: text)
        }
    }
    .frame(width: 500, height: 500)
    .background(.white)
}
