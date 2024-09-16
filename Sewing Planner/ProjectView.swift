//
//  ProjectView.swift
//  Sewing Planner
//
//  Created by Art on 7/9/24.
//

import GRDB
import SwiftUI

struct ProjectView: View {
    // used for dismissing a view(basically the back button)
    @Environment(\.dismiss) private var dismiss
    @Environment(\.appDatabase) private var appDatabase
    @State var clicked = true
    var projectId: Int64 = 0
    @State var project = Project()
    @State var name = ""
    @State var newStep = ""
    @State var projectSteps: [ProjectStep] = [ProjectStep]()
    @State var showAddTextboxPopup = false
    @State var isAddingInstruction = false
    @State var doesProjectHaveName = false
    @State var showAlertIfProjectNotSaved = false
    @Binding var projectsNavigation: [Project]
    @State var materials: [MaterialRecord] = []
    
    private var isNewStepValid: Bool {
        newStep.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }
    
    private var isProjectValid: Bool {
        !project.name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }
    
    private var isNewProjectEmpty: Bool {
        project.name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty && projectSteps.isEmpty
    }
    
    var body: some View {
        VStack {
            HSplitView {
                ProjectDetails(projectsNavigation: $projectsNavigation)
                ImageSketchesView()
            }.frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top).border(Color.green)
        }.frame(maxWidth: .infinity, maxHeight: .infinity).background(Color.white).border(Color.blue)
    }
}

struct BackButton: View {
    let buttonAction: () -> Void
    var body: some View {
        Button(action: buttonAction) {
            HStack(alignment: VerticalAlignment.center) {
                Image(systemName: "arrowshape.backward.fill")
                Text("Back")
            }
        }
    }
}
