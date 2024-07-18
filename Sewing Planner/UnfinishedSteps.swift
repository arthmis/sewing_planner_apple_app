//
//  UnfinishedSteps.swift
//  Sewing Planner
//
//  Created by Art on 7/9/24.
//

import SwiftUI

struct UnfinishedSteps: View {
    var projectSteps: [ProjectStepPreviewData]
    var body: some View {
        ForEach(projectSteps, id: \.id) { step in
          ProjectStepPreview(text: step.text)
        }
    }
}

struct ProjectStepPreviewData: Hashable, Identifiable {
    var id: UUID
    var text: String
}

struct ProjectStepPreview: View {
    var text: String
    
    var body: some View {
        Text(text)
    }
}

//#Preview {
//    UnfinishedSteps()
//}
