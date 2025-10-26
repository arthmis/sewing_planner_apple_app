//
//  ReceiveImageView.swift
//  ReceiveImage
//
//  Created by Art on 10/24/25.
//

import SwiftUI

struct ReceiveImageView: View {
    let image: UIImage
    @State var projects: [Project] = []
    @State var selection: Int64 = 0

    var body: some View {
        VStack {
            Picker("Project", selection: $selection) {
                ForEach(projects, id: \.self.id) { project in
                    Text(project.name)
                }
            }
            .pickerStyle(.menu)
            Image(uiImage: image)
                .resizable()
                .aspectRatio(contentMode: .fit)

            Button("Save To Project") {}
        }
        .task {
            projects = try! SharedPersistence().getProjects()
            selection = projects[0].id
        }
    }
}

struct Project: Identifiable {
    let id: Int64
    let name: String
}

// TODO: write the image file out to the app group with some json to describe where
// it can be found
// 1. also update add projects logic in main project to output a list of all the projects
// and when removing all the projects
// the extension will use this list to populate the view for project selection
// 2. update logic on project selection to read the shared container and get any image
// shared to the project if any
// then delete the image if importing it from the shared container is successful
struct SharedPersistence {
    func getProjects() throws -> [Project] {
        return []
    }

    func getImagesDirectory() -> URL {
        let container = getPersistenceLocation()
        return container!
    }

    func getPersistenceLocation() -> URL? {
        // get the shared container for the app group
        guard
            let fileContainer = FileManager.default.containerURL(
                forSecurityApplicationGroupIdentifier: "group.SewingPlanner"
            )
        else {
            fatalError("Shared file container could not be created.")
        }
        print(fileContainer)
        //                return fileContainer.appendingPathComponent("\(databaseName).sqlite")

        return fileContainer
    }
}

#Preview {
    ReceiveImageView(image: UIImage(named: "black_dress_sketch")!)
}
