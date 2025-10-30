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
    case cannotFindAppGroupContainer(String)
}

struct SharedPersistence {
    func getFile(fileName: String) throws -> Data? {
        let fileManager = FileManager.default
        guard let sharedLocation = try getPersistenceLocation() else {
            throw ShareError.cannotFindAppGroupContainer(
                "Couldn't get the location of the shared container for the app group"
            )
        }
        let fileUrl = constructFileLocation(
            location: sharedLocation,
            fileName: fileName
        )
        let data = fileManager.contents(atPath: fileUrl.path())
        return data
    }

    func writeFile(data: Data, fileName: String) throws {
        let fileManager = FileManager.default
        guard let sharedLocation = try getPersistenceLocation() else {
            throw ShareError.cannotFindAppGroupContainer(
                "Couldn't get the location of the shared container for the app group"
            )
        }

        let fileUrl = constructFileLocation(
            location: sharedLocation,
            fileName: fileName
        )
        let _ = fileManager.createFile(
            atPath: fileUrl.path(),
            contents: data
        )
    }

    func saveImage(fileIdentifier: String, image: Data) throws {
        let fileManager = FileManager.default

        let imagesDirectory = try createImagesDirectory(at: "SharedImages")
        let imagePath = imagesDirectory.appending(path: fileIdentifier)
            .appendingPathExtension(for: .png)
        let success = fileManager.createFile(
            atPath: imagePath.path(),
            contents: image
        )

        if !success {
            // TODO: throw an error or do something
        }
    }

    func getImage(withIdentifier fileIdentifier: String) throws -> Data {
        let fileManager = FileManager.default

        let imagesDirectory = try createImagesDirectory(at: "SharedImages")
        let imagePath = imagesDirectory.appending(path: fileIdentifier)
            .appendingPathExtension(for: .png)
        guard let data = fileManager.contents(atPath: imagePath.path()) else {
            throw ShareError.getFile("Couldn't get shared image")
        }

        return data
    }

    func deleteImage(withIdentifier fileIdentifier: String) throws {
        let fileManager = FileManager.default

        let imagesDirectory = try createImagesDirectory(at: "SharedImages")
        let imagePath = imagesDirectory.appending(path: fileIdentifier)
            .appendingPathExtension(for: .png)
        try fileManager.removeItem(atPath: imagePath.path())
    }

    private func createImagesDirectory(at directory: String) throws -> URL {
        let fileManager = FileManager.default
        guard let sharedLocation = try getPersistenceLocation() else {
            throw ShareError.cannotFindAppGroupContainer(
                "Couldn't get the location of the shared container for the app group"
            )
        }
        let imagesDirectory = sharedLocation.appending(path: directory)
        try fileManager.createDirectory(
            at: imagesDirectory,
            withIntermediateDirectories: true,
            attributes: nil
        )

        return imagesDirectory
    }

    private func constructFileLocation(location: URL, fileName: String) -> URL {
        let fileLocation = location.appending(path: fileName)
            .appendingPathExtension(for: .json)

        return fileLocation
    }

    private func getPersistenceLocation() throws -> URL? {
        // get the shared container for the app group
        return FileManager.default.containerURL(
            forSecurityApplicationGroupIdentifier: "group.SewingPlanner"
        )
    }

    #if DEBUG
        func removeSharedData() throws {
            let fileManager = FileManager.default
            guard let sharedLocation = try getPersistenceLocation() else {
                throw ShareError.cannotFindAppGroupContainer(
                    "Couldn't get the location of the shared container for the app group"
                )
            }

            let projectsUrl = constructFileLocation(
                location: sharedLocation,
                fileName: "projects"
            )
            do {

                try fileManager.removeItem(
                    at: projectsUrl
                )
            } catch {
                print(error.localizedDescription)
            }

            let sharedImagesFileUrl = constructFileLocation(
                location: sharedLocation,
                fileName: "sharedImages"
            )
            do {

                try fileManager.removeItem(
                    atPath: sharedImagesFileUrl.path(),
                )
            } catch {
                print(error.localizedDescription)
            }

            let imagesFolderPath = sharedLocation.appending(
                path: "SharedImages"
            )
            do {

                try fileManager.removeItem(at: imagesFolderPath)
            } catch {
                print(error.localizedDescription)
            }
        }
    #endif
}
