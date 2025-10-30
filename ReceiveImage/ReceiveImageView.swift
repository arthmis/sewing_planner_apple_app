//
//  ReceiveImageView.swift
//  ReceiveImage
//
//  Created by Art on 10/24/25.
//

import SwiftUI

struct ReceiveImageView: View {
    // let image: UIImage
    let image: Data
    let dismiss: () -> Void
    @State var projects: [SharedProject] = []
    @State var selection: Int64 = 0
    @State var error: String
    @State var showError = false

    private var hasNoProject: Bool {
        projects.isEmpty
    }

    var body: some View {
        VStack {
            HStack {
                Spacer()
                Button {
                    dismiss()
                } label: {
                    Image(systemName: "xmark.circle")
                        .font(.system(size: 28))
                        .fontWeight(.light)
                        .foregroundStyle(Color.black.opacity(0.8))
                }
                .padding(.trailing, 8)
            }
            if hasNoProject {
                Text(
                    "Please create one project in the main app before trying to share."
                )
                if let sharedImage = UIImage(data: image) {
                    Image(uiImage: sharedImage)
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                } else {
                    Text("Couldn't load image")
                }

            } else {
                Picker("Project", selection: $selection) {
                    ForEach(projects, id: \.self.id) { project in
                        Text(project.name)
                    }
                }
                .pickerStyle(.menu)
                if let sharedImage = UIImage(data: image) {
                    Image(uiImage: sharedImage)
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                } else {
                    Text("Couldn't load image")
                }

                Button("Save to selected project") {
                    do {
                        try saveImageForProject(
                            projectId: selection,
                            image: image
                        )
                        dismiss()
                    } catch {
                        // TODO: handle error
                        self.error = "Couldn't save image. Please try again."
                        self.showError = true
                    }
                }
            }
        }
        .alert(
            error,
            isPresented: $showError
        ) {
            Button("Try again") {
                showError = false
                do {
                    try saveImageForProject(
                        projectId: selection,
                        image: image
                    )
                } catch {
                    self.error = "Couldn't save image. Please try again."
                    self.showError = true
                }
            }
            Button("Cancel") {
                self.error = ""
                self.showError = false
            }
        }
        .padding(.horizontal, 10)
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
    guard let projects = try? decoder.decode([SharedProject].self, from: data)
    else {
        throw ShareError.emptyFile(
            "Couldn't load projects. Head to the main app and create a project"
        )
    }

    return projects
}

let sharedImagesFileName = "sharedImages"

func saveImageForProject(projectId: Int64, image: Data) throws {
    let fileIdentifier = UUID().uuidString
    let sharedImageIdentification = SharedImage(
        projectId: projectId,
        fileIdentifier: fileIdentifier
    )

    try SharedPersistence().saveImage(
        fileIdentifier: sharedImageIdentification.fileIdentifier,
        image: image
    )

    let fileData = try SharedPersistence().getFile(
        fileName: sharedImagesFileName
    )

    guard let data = fileData else {
        let sharedImages = [sharedImageIdentification]
        let encoder = JSONEncoder()
        let updatedSharedImagesList = try encoder.encode(sharedImages)
        try SharedPersistence().writeFile(
            data: updatedSharedImagesList,
            fileName: sharedImagesFileName
        )
        return
    }

    let decoder = JSONDecoder()
    guard var sharedImages = try? decoder.decode([SharedImage].self, from: data)
    else {
        throw ShareError.emptyFile("Couldn't get shared images list file")
    }

    sharedImages.append(sharedImageIdentification)

    let encoder = JSONEncoder()
    let updatedSharedImagesList = try encoder.encode(sharedImages)
    try SharedPersistence().writeFile(
        data: updatedSharedImagesList,
        fileName: sharedImagesFileName
    )
}
