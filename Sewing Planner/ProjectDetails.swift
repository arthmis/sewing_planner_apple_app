//
//  ProjectDetails.swift
//  Sewing Planner
//
//  Created by Art on 9/12/24.
//

import SwiftUI

//struct ProjectDetails: View {
//    // used for dismissing a view(basically the back button)
//    @Environment(\.dismiss) private var dismiss
//    @Environment(\.appDatabase) private var appDatabase
//    @ObservableObject var model = ProjectDetailData
//    @State var clicked = true
//    var projectId: Int64 = 0
//    @Binding var project: Project
//    @State var name = ""
//    @Binding var projectSteps: [ProjectStep]
//    @Binding var deletedProjectSteps: [ProjectStep]
//    @Binding var materials: [MaterialRecord]
//    @Binding var deletedMaterials: [MaterialRecord]
//    @State var showAddTextboxPopup = false
//    @State var doesProjectHaveName = false
//    @State var showAlertIfProjectNotSaved = false
//    @Binding var projectsNavigation: [Project]
//
//    var body: some View {
//        VStack {
//            ProjectName(project: $project)
//            VStack {
//                ProjectStepsView(projectSteps: self.$projectSteps, deletedProjectSteps: self.$deletedProjectSteps)
//            }
//            Divider()
//            MaterialList(materials: $materials, deletedMaterials: $deletedMaterials)
//        }.background(Color.white).border(.red, width: 4)
//    }
//}

struct ProjectDetails: View {
    // used for dismissing a view(basically the back button)
    @Environment(\.dismiss) private var dismiss
    @Environment(\.appDatabase) private var appDatabase
    @ObservedObject var project: ProjectData
    @ObservedObject var projectSections: ProjectSections
    @State var clicked = true
    var projectId: Int64 = 0
    @State var name = ""
    @State var showAddTextboxPopup = false
    @State var doesProjectHaveName = false
    @State var showAlertIfProjectNotSaved = false
    @Binding var projectsNavigation: [Project]
    
    var body: some View {
        VStack {
            ProjectName(project: project)
            VStack {
                ForEach(projectSections.sections, id: \.id) { section in
                    SectionView(data: section)
                }
            }
            Button {
                projectSections.addSection()
            } label: {
                Image(systemName: "plus")
            }.padding(40)
        }
    }
}

//#Preview {
//    ProjectDetails()
//}
