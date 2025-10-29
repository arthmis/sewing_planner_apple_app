//
//  ProjectDataViewModel.swift
//  Sewing Planner
//
//  Created by Art on 10/11/24.
//

import Foundation
import GRDB
import PhotosUI
import SwiftUI

@Observable
class ProjectData {
    var data: ProjectMetadata
    var sections: [Section] = .init()
    var bindedName = ""
    var selectedSectionForDeletion: SectionRecord?
    var showDeleteSectionDialog = false
    let db: AppDatabase = .db()

    init(data: ProjectMetadata) {
        self.data = data
    }

    init(data: ProjectMetadata, projectSections: [Section]) {
        self.data = data
        sections = projectSections
    }

    func addSection() throws {
        try db.getWriter().write { db in
            let now = Date()
            var sectionInput = SectionInputRecord(
                projectId: data.id, name: "Section \(sections.count + 1)", createDate: now,
                updateDate: now
            )
            try sectionInput.save(db)
            let sectionRecord = SectionRecord(from: sectionInput)
            let section = Section(id: UUID(), name: sectionRecord)
            sections.append(section)
        }
    }

    func updateName(name: String) throws {
        try db.getWriter().write { db in
            data.name = name
            try data.save(db)

            try updateProjectNameInSharedExtensionProjectList(project: data)
        }
    }

    private func updateProjectNameInSharedExtensionProjectList(project: ProjectMetadata) throws {
        let fileData = try SharedPersistence().getFile(fileName: "projects")
        guard let data = fileData else {
            // TODO: figure out what I want to do here if no file is found
            // let projectsList = [Project(id: project.id, name: project.name)]
            // let encoder = JSONEncoder()
            // let updatedProjectsList = try encoder.encode(projectsList)
            // try SharedPersistence().writeFile(data: updatedProjectsList, fileName: "projects")

            return
        }

        let decoder = JSONDecoder()
        guard var projectsList = try? decoder.decode([SharedProject].self, from: data) else {
            throw ShareError.emptyFile("Couldn't get shared projects list file")
        }

        guard let index = projectsList.firstIndex(where: { $0.id == project.id })
        else {
            return
        }

        let updatedProject = SharedProject(id: project.id, name: project.name)
        projectsList[index] = updatedProject

        // projectsList.append(Project(id: project.id, name: project.name))
        let encoder = JSONEncoder()
        let updatedProjectsList = try encoder.encode(projectsList)
        try SharedPersistence().writeFile(data: updatedProjectsList, fileName: "projects")
    }

    static func getProject(with id: Int64, from db: AppDatabase) throws -> ProjectData? {
        do {
            if let project = try db.getProject(id: id) {
                let sections = try db.getSections(projectId: id)
                return ProjectData(data: project, projectSections: sections)
            }

        } catch {
            print("error retrieving data: \(error)")
        }
        return nil
    }
}
