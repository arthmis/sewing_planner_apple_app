//
//  AppFiles.swift
//  Sewing Planner
//
//  Created by Art on 9/20/24.
//

import Foundation
import AppKit

struct AppFiles {
    
    func saveProjectImages(projectId: Int64, images: [ProjectImageData]) throws {
        let documentsURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        let usersPhotosUrl = documentsURL.appendingPathComponent("ProjectPhotos")
        
        // TODO: check if folder exists before creating it
        do {
            try FileManager.default.createDirectory(at: usersPhotosUrl, withIntermediateDirectories: true, attributes: nil)
        } catch {
            print("Error \(error)")
        }
        
        let projectFolder = usersPhotosUrl.appendingPathComponent(String(projectId))
        do {
            try FileManager.default.createDirectory(at: projectFolder, withIntermediateDirectories: true, attributes: nil)
        } catch {
            print("Error \(error)")
        }
        
        for file in images {
            let originalFileName = file.path.deletingPathExtension().lastPathComponent
            var fileName = projectFolder.appendingPathComponent(originalFileName)
            fileName.appendPathExtension(for: .png)
            let createFileSuccess = FileManager.default.createFile(atPath: fileName.path(), contents: nil)
            
            if createFileSuccess {
                let tiffRep = file.image?.tiffRepresentation
                let bitmap = NSBitmapImageRep(data: tiffRep!)!
                let data = bitmap.representation(using: .png, properties: [:])
                do {
                    try data?.write(to: fileName, options: Data.WritingOptions.atomic)
                } catch {
                    print("Error: \(error)")
                }
            } else {
                
            }
        }
        
    }
}
