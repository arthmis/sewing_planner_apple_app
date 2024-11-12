//
//  AppFiles.swift
//  Sewing Planner
//
//  Created by Art on 9/20/24.
//

import AppKit
import Foundation

struct AppFiles {
    private func getPhotosDirectoryPath() -> URL {
        let documentsURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        let usersPhotosUrl = documentsURL.appendingPathComponent("ProjectPhotos")

        return usersPhotosUrl
    }

    func getProjectPhotoDirectoryPath(projectId: Int64) -> URL {
        let photosDirectory = getPhotosDirectoryPath()

        return photosDirectory.appendingPathComponent(String(projectId))
    }

    func saveProjectImage(projectId: Int64, image: ProjectImage) throws {
        let fileManager = FileManager.default
        let usersPhotosUrl = getPhotosDirectoryPath()

        do {
            try fileManager.createDirectory(at: usersPhotosUrl, withIntermediateDirectories: true, attributes: nil)
        } catch {
            print("Error \(error)")
        }

        let projectFolder = usersPhotosUrl.appendingPathComponent(String(projectId))
        do {
            try fileManager.createDirectory(at: projectFolder, withIntermediateDirectories: true, attributes: nil)
        } catch {
            fatalError("Error \(error)")
        }

        let createFileSuccess = fileManager.createFile(atPath: image.path.path(), contents: nil)

        if createFileSuccess {
            let tiffRep = image.image?.tiffRepresentation
            let bitmap = NSBitmapImageRep(data: tiffRep!)!
            let data = bitmap.representation(using: .png, properties: [:])
            do {
                try data?.write(to: image.path, options: Data.WritingOptions.atomic)
            } catch {
                fatalError("Error: \(error)")
            }
        } else {
            print("couldn't create file for file URL \(image.path) at file path: \(image.path.path())")
        }
    }

    // TODO: handle situation where file names might be duplicates because they have the same name but comes from different file paths
    func saveProjectImages(projectId: Int64, images: [ProjectImage]) throws {
        let fileManager = FileManager.default
        let usersPhotosUrl = getPhotosDirectoryPath()

        do {
            try fileManager.createDirectory(at: usersPhotosUrl, withIntermediateDirectories: true, attributes: nil)
        } catch {
            print("Error \(error)")
        }

        let projectFolder = usersPhotosUrl.appendingPathComponent(String(projectId))
        do {
            try fileManager.createDirectory(at: projectFolder, withIntermediateDirectories: true, attributes: nil)
        } catch {
            fatalError("Error \(error)")
        }

        for file in images {
            let createFileSuccess = fileManager.createFile(atPath: file.path.path(), contents: nil)

            if createFileSuccess {
                let tiffRep = file.image?.tiffRepresentation
                let bitmap = NSBitmapImageRep(data: tiffRep!)!
                let data = bitmap.representation(using: .png, properties: [:])
                do {
                    try data?.write(to: file.path, options: Data.WritingOptions.atomic)
                } catch {
                    fatalError("Error: \(error)")
                }
            } else {
                print("couldn't create file for file URL \(file.path) at file path: \(file.path.path())")
            }
        }
    }

    func getImage(fromPath path: URL) -> NSImage? {
        let fileManager = FileManager.default
        let usersPhotosUrl = getPhotosDirectoryPath()

        if let data = fileManager.contents(atPath: path.path()) {
            return NSImage(data: data)
        }

        return nil
    }
}
