//
//  ReceiveImageView.swift
//  ReceiveImage
//
//  Created by Art on 10/24/25.
//

import SwiftUI
//import GRDB

struct ReceiveImageViewApp: View {
//    @Environment(\.appDatabase) var appDatabase
//    let db = AppDatabase.db()
    let image: UIImage
    let selections = ["hello", "hi", "bye"]
    @State var selection = 0
    var body: some View {
        Picker("Project", selection: $selection) {
            ForEach(selections.indices) { index in
                    Text(selections[index])
            }
        }
        .pickerStyle(.menu)
        Image(uiImage: image)
            .resizable()
            .aspectRatio(contentMode: .fit)
        
        Button("Save To Project") {
            
        }
    }
}

#Preview {
    ReceiveImageViewApp(image: UIImage(named: "black_dress_sketch")!)
}
