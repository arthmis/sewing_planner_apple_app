//
//  Persistence.swift
//  Sewing Planner
//
//  Created by Art on 10/26/25.
//

import Foundation
import UIKit
import UniformTypeIdentifiers

struct SharedProject: Identifiable, Codable {
    let id: Int64
    let name: String
}

struct SharedImage: Codable {
    let projectId: Int64
    let fileIdentifier: String
}

enum ShareError: Error {
    case getFile(String)
    case emptyFile(String)
}

struct SharedPersistence {
    func getFile(fileName: String) throws -> Data? {
        let fileManager = FileManager.default
        let sharedLocation = try getPersistenceLocation()!
        let fileUrl = constructFileLocation(
            location: sharedLocation,
            fileName: fileName
        )
        let data = fileManager.contents(atPath: fileUrl.path())
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

    // func saveImage(fileIdentifier: String, image: UIImage) throws {
    func saveImage(fileIdentifier: String, image: Data) throws {
        let fileManager = FileManager.default

        let imagesDirectory = try createImagesDirectory(at: "SharedImages")
        let imagePath = imagesDirectory.appending(path: fileIdentifier).appendingPathExtension(for: .png)
        // let data = image.pngData()
        let success = fileManager.createFile(atPath: imagePath.path(), contents: image)

        if !success {
            // TODO: throw an error or do something
        }
    }

    func getImage(withIdentifier fileIdentifier: String) throws -> Data {
        let fileManager = FileManager.default

        let imagesDirectory = try createImagesDirectory(at: "SharedImages")
        let imagePath = imagesDirectory.appending(path: fileIdentifier).appendingPathExtension(for: .png)
        guard let data = fileManager.contents(atPath: imagePath.path()) else {
            throw ShareError.getFile("Couldn't get shared image")
        }

        return data
    }

    func deleteImage(withIdentifier fileIdentifier: String) throws {
        let fileManager = FileManager.default

        let imagesDirectory = try createImagesDirectory(at: "SharedImages")
        let imagePath = imagesDirectory.appending(path: fileIdentifier).appendingPathExtension(for: .png)
        try fileManager.removeItem(atPath: imagePath.path())
    }

    func fileExists(withIdentifier fileIdentifier: String) -> Bool {
        let fileManager = FileManager.default

        let imagesDirectory = try! createImagesDirectory(at: "SharedImages")
        let imagePath = imagesDirectory.appending(path: fileIdentifier).appendingPathExtension(for: .png)
        return fileManager.fileExists(atPath: imagePath.path())
    }

    private func createImagesDirectory(at directory: String) throws -> URL {
        let fileManager = FileManager.default
        let sharedLocation = try getPersistenceLocation()!
        let imagesDirectory = sharedLocation.appending(path: directory)
        try fileManager.createDirectory(at: imagesDirectory, withIntermediateDirectories: true, attributes: nil)

        return imagesDirectory
    }

    //    func getImagesDirectory() -> URL {
    //        let container = getPersistenceLocation()
    //        return container!
    //    }

    private func constructFileLocation(location: URL, fileName: String) -> URL {
        let fileLocation = location.appending(path: fileName)
            .appendingPathExtension(for: .json)

        return fileLocation
    }

    private func getPersistenceLocation() throws -> URL? {
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
