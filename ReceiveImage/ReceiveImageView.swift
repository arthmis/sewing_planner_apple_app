//
//  ReceiveImageView.swift
//  ReceiveImage
//
//  Created by Art on 10/24/25.
//

import SwiftUI

struct ReceiveImageView: View {
    let image: UIImage
    @State var projects: [SharedProject] = []
    @State var selection: Int64 = 0

    private var hasNoProject: Bool {
        projects.isEmpty
    }

    var body: some View {
        VStack {
            if hasNoProject {
                Text(
                    "Please create one project in the main app before trying to share."
                )
                Image(uiImage: image)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
            } else {
                Picker("Project", selection: $selection) {
                    ForEach(projects, id: \.self.id) { project in
                        Text(project.name)
                    }
                }
                .pickerStyle(.menu)
                Image(uiImage: image)
                    .resizable()
                    .aspectRatio(contentMode: .fit)

                Button("Save to selected project") {
                    do {
                        // safe to unwrap because button can't be tapped if there is no selection
                        //                    try saveImageToProject(projectId: selection!, image: image)
                    } catch {
                        // TODO: handle error
                    }
                }
            }
        }
        .task {
            do {
                projects = try getProjects()
                if let first = projects.first {
                    selection = first.id
                }
            } catch {
                // TODO: show some kind of error and offer retry or something
                print(error.localizedDescription)
            }
        }
    }
}

func getProjects() throws -> [SharedProject] {
    guard let data = try? SharedPersistence().getFile(fileName: "projects")
    else {
        // throw an error
        throw ShareError.getFile(
            "Couldn't load projects. Head to the main app and create a project"
        )
    }
    let decoder = JSONDecoder()
    guard let projects = try? decoder.decode([SharedProject].self, from: data) else {
        // throw an error
        //        throw Error
        throw ShareError.emptyFile(
            "Couldn't load projects. Head to the main app and create a project"
        )
    }

    return projects
}

func saveImageToProject(projectId _: Int64, image _: UIImage) throws {}

#Preview {
    ReceiveImageView(image: UIImage(named: "black_dress_sketch")!)
}
