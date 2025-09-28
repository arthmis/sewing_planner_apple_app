//
//  AppFiles.swift
//  Sewing Planner
//
//  Created by Art on 9/20/24.
//

// import AppKit
import Foundation
import SwiftUI

struct AppFiles {
    private func getPhotosDirectoryPath() -> URL {
        let documentsURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        let usersPhotosUrl = documentsURL.appendingPathComponent("ProjectPhotos")

        return usersPhotosUrl
    }

    // only used when the schema is changed during development
    // ensures the images don't conflict with new images
//    func deleteImagesFolder() {
//        let directory = getPhotosDirectoryPath()
//        let fileManager = FileManager.default
//        if fileManager.fileExists(atPath: directory.path()) {
//            try! fileManager.removeItem(at: directory)
//        }
//    }

//    func getProjectPhotoDirectoryPath(projectId: Int64) -> URL {
//        let photosDirectory = getPhotosDirectoryPath()
//
//        return photosDirectory.appendingPathComponent(String(projectId))
//    }

//    func saveProjectImage(projectId: Int64, image: ProjectImage) throws -> URL {
//        let fileManager = FileManager.default
//        let usersPhotosUrl = getPhotosDirectoryPath()
//
//        do {
//            try fileManager.createDirectory(at: usersPhotosUrl, withIntermediateDirectories: true, attributes: nil)
//        } catch {
//            print("Error \(error)")
//        }
//
//        let imagesFolderForProject = getProjectPhotoDirectoryPath(projectId: projectId)
//        do {
//            try fileManager.createDirectory(at: imagesFolderForProject, withIntermediateDirectories: true, attributes: nil)
//        } catch {
//            fatalError("Error \(error)")
//        }
//
//        // get image's new file path
//        let originalFileName = image.path.deletingPathExtension().lastPathComponent
//        let newFilePath = imagesFolderForProject.appendingPathComponent(originalFileName).appendingPathExtension(for: .png)
//        print("project folder for images: \(imagesFolderForProject)")
//        print("new path for image: \(newFilePath)")
//
//        let createFileSuccess = fileManager.createFile(atPath: newFilePath.path(), contents: nil)
//
//        if createFileSuccess {
//            if let imageData = image.image {
//                let tiffRep = imageData.tiffRepresentation
//                let bitmap = NSBitmapImageRep(data: tiffRep!)!
//                let data = bitmap.representation(using: .png, properties: [:])
//                do {
//                    try data!.write(to: newFilePath, options: Data.WritingOptions.atomic)
//                } catch {
//                    fatalError("Error: \(error)")
//                }
//            }
//        } else {
//            print("couldn't create file for file URL \(image.path) at file path: \(image.path.path())")
//        }
//
//        return newFilePath
//    }

//    // TODO: handle situation where file names might be duplicates because they have the same name but comes from different file paths
//    func saveProjectImages(projectId: Int64, images: [ProjectImage]) throws {
//        let fileManager = FileManager.default
//        let usersPhotosUrl = getPhotosDirectoryPath()
//
//        do {
//            try fileManager.createDirectory(at: usersPhotosUrl, withIntermediateDirectories: true, attributes: nil)
//        } catch {
//            print("Error \(error)")
//        }
//
//        let projectFolder = usersPhotosUrl.appendingPathComponent(String(projectId))
//        do {
//            try fileManager.createDirectory(at: projectFolder, withIntermediateDirectories: true, attributes: nil)
//        } catch {
//            fatalError("Error \(error)")
//        }
//
//        for file in images {
//            let createFileSuccess = fileManager.createFile(atPath: file.path.path(), contents: nil)
//
//            if createFileSuccess {
//                let tiffRep = file.image?.tiffRepresentation
//                let bitmap = NSBitmapImageRep(data: tiffRep!)!
//                let data = bitmap.representation(using: .png, properties: [:])
//                do {
//                    try data?.write(to: file.path, options: Data.WritingOptions.atomic)
//                } catch {
//                    fatalError("Error: \(error)")
//                }
//            } else {
//                print("couldn't create file for file URL \(file.path) at file path: \(file.path.path())")
//            }
//        }
//    }

    func getImage(fromPath path: URL) -> Image? {
//        let fileManager = FileManager.default
//
//        if let data = fileManager.contents(atPath: path.path()) {
//            return NSImage(data: data)
//        }

        return nil
    }
}
