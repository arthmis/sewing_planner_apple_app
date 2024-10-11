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
    //    @Binding var project: Project
    @ObservedObject var model: ProjectDetailData
    @State var clicked = true
    var projectId: Int64 = 0
    @State var name = ""
    @State var showAddTextboxPopup = false
    @State var doesProjectHaveName = false
    @State var showAlertIfProjectNotSaved = false
    @Binding var projectsNavigation: [Project]
    
    var body: some View {
        VStack {
            ProjectName(project: $model.project)
            VStack {
                //                ProjectStepsView(projectSteps: self.$projectSteps, deletedProjectSteps: self.$deletedProjectSteps)
                ForEach($model.sectionData, id: \.section) { $section in
                    SectionView(data: $section)
                }
            }
            Divider()
            Button {
                model.addSection()
            } label: {
                Image(systemName: "plus")
            }.padding(40)
            //            MaterialList(materials: $materials, deletedMaterials: $deletedMaterials)
        }
    }
}

//#Preview {
//    ProjectDetails()
//}
