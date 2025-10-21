//
//  ProjectDetailsView.swift
//  Sewing Planner
//
//  Created by Art on 9/12/24.
//

import SwiftUI

struct ProjectDataView: View {
    @Binding var model: ProjectData

    private var isProjectValid: Bool {
        !model.data.name.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }

    var body: some View {
        VStack(alignment: .leading) {
            HStack {
                ProjectTitle(project: $model.data, bindedName: $model.bindedName, updateName: model.updateName)
                Spacer()
            }
            .frame(maxWidth: .infinity)
            .padding(.bottom, 25)
            ScrollView {
                VStack(alignment: .leading) {
                    ForEach($model.sections, id: \.id) { $section in
                        SectionView(data: $section)
                            .padding(.bottom, 16)
                    }
                }
            }
            .frame(maxHeight: .infinity)
        }
        .padding([.leading, .trailing], 8)
        .toolbar {}
    }
}

// #Preview {
//    ProjectDetails(project: ProjectData(
//    data: Project(id: 2, name: "Project Name", completed: false, createDate: Date(), updateDate: Date())), projectSections: ProjectSections(), projectsNavigation: [Project()])
// }
