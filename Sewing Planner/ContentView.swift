//
//  ContentView.swift
//  Sewing Planner
//
//  Created by Art on 5/9/24.
//

import SwiftUI

struct ContentView: View {
    var body: some View {
        ProjectsView()
            .environment(\.font, Font.custom("SourceSans3-Regular", size: 16))
//            .frame(minWidth: 300, maxWidth: .infinity, minHeight: 500,  maxHeight: .infinity)
            .frame(minWidth: 300, maxWidth: 885, minHeight: 500,  maxHeight: 500)

    }
}

#Preview {
    ContentView()
}
