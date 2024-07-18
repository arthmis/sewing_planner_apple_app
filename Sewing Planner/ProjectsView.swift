//
//  SwiftUIView.swift
//  Sewing Planner
//
//  Created by Art on 7/9/24.
//

import SwiftUI

struct ProjectsView: View {
    @State var data: [ProjectStepPreviewData]
    var body: some View {
        NavigationStack {
            HStack {
                NavigationLink {
                    NewProjectView()
                } label: {
                    Text("New Project")
                }.accessibilityIdentifier("AddNewProjectButton")
            }
            .navigationTitle("Projects")
            HStack {
                Image("Landscape_4")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 100, height: 300)
                UnfinishedSteps(projectSteps: data)
                
            }.overlay(
                RoundedRectangle(cornerRadius: /*@START_MENU_TOKEN@*/25.0/*@END_MENU_TOKEN@*/)
                    .stroke(Color.blue, lineWidth: 1)
            )
            .frame(width: 300, height: 300)
            .navigationTitle("Projects")
        }
    }
}

#Preview {
    ProjectsView(data: [])
}
