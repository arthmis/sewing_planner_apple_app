//
//  Persistence.swift
//  Sewing Planner
//
//  Created by Art on 10/26/25.
//

import Foundation

struct Project: Identifiable, Codable {
    let id: Int64
    let name: String
}

enum ShareError: Error {
    case getFile(String)
    case emptyFile(String)
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
    func getFile(fileName: String) throws -> Data? {
        let fileManager = FileManager.default
        let sharedLocation = try getPersistenceLocation()!
        let fileUrl = constructFileLocation(
            location: sharedLocation,
            fileName: fileName
        )
        let data = try? Data(contentsOf: fileUrl)
        return data
    }
    
    func writeFile(data: Data, fileName: String) throws {
        let fileManager = FileManager.default
        let sharedLocation = try getPersistenceLocation()!
        let fileUrl = constructFileLocation(
            location: sharedLocation,
            fileName: fileName
        )
        //        try data.write(to: fileUrl, options: [.atomic, .completeFileProtection])
        let success = fileManager.createFile(
            atPath: fileUrl.path(),
            contents: data
        )
        //        let data = try? Data(contentsOf: fileUrl)
        //        return data
    }

    //    func getImagesDirectory() -> URL {
    //        let container = getPersistenceLocation()
    //        return container!
    //    }

    func constructFileLocation(location: URL, fileName: String) -> URL {
        let fileLocation = location.appending(path: fileName)
            .appendingPathExtension(for: .json)

        return fileLocation
    }

    func getPersistenceLocation() throws -> URL? {
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
