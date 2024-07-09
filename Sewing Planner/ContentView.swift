//
//  ContentView.swift
//  Sewing Planner
//
//  Created by Art on 5/9/24.
//

import SwiftUI

struct ContentView: View {
    @State var data = [ProjectStepPreviewData( id: UUID(), text: "step 1")]

  var body: some View {
      ProjectsView(data: data)
//      ProjectView()
  }
}

#Preview {
  ContentView()
}
