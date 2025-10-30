//
//  TestEffects.swift
//  Sewing PlannerUnitTests
//
//  Created by Art on 10/30/25.
//

import Foundation
import GRDB
import Testing

@testable import Sewing_Planner

struct TestEffects {
    struct MockDb: DbStore {
        private let deleteProjectSectionInner:
            Optional<(SectionRecord) async throws -> Void>

        init(
            deleteProjectSection:
            @escaping (SectionRecord) async throws -> Void
        ) {
            deleteProjectSectionInner = deleteProjectSection
        }

        func deleteProjectSection(section: Sewing_Planner.SectionRecord)
            async throws
        {
            if let inner = deleteProjectSectionInner {
                return try await inner(section)
            }
        }
    }

    private func initializeProjectViewModel() -> ProjectViewModel {
        let now = Date()
        let sections = [
            Section(
                id: UUID(),
                name: SectionRecord(
                    id: 1,
                    projectId: 1,
                    name: "Section 1",
                    isDeleted: false,
                    createDate: now,
                    updateDate: now
                )
            ),
        ]
        let projectMetadata = ProjectMetadata(
            id: 1,
            name: "Project 1",
            completed: false,
            createDate: now,
            updateDate: now
        )

        let projectData = ProjectData(
            data: projectMetadata,
            projectSections: sections
        )

        let projectImages = ProjectImages(
            projectId: projectMetadata.id,
            images: []
        )

        let model = ProjectViewModel(
            data: projectData,
            projectsNavigation: [projectMetadata],
            projectImages: projectImages
        )

        return model
    }

    @Test func handleEffectDeleteSection() async {
        let model = initializeProjectViewModel()
        let db = MockDb(deleteProjectSection: { _ in
        })

        let now = Date()
        let sectionRecord = SectionRecord(
            id: 1,
            projectId: 1,
            name: "Section 1",
            isDeleted: false,
            createDate: now,
            updateDate: now
        )

        let effect = Effect.deleteSection(section: sectionRecord)
        await model.handleEffect(effect: effect, db: db)

        #expect(model.projectData.sections.isEmpty)
        #expect(model.projectData.selectedSectionForDeletion == nil)
        #expect(model.projectData.showDeleteSectionDialog == false)
    }

    @Test func handleEffectDeleteSectionWithFailure() async throws {
        let model = initializeProjectViewModel()
        let db = MockDb(deleteProjectSection: { _ in
            throw DatabaseError(resultCode: .SQLITE_ABORT)
        })
        let now = Date()
        let sectionRecord = SectionRecord(
            id: 1,
            projectId: 1,
            name: "Section 1",
            isDeleted: false,
            createDate: now,
            updateDate: now
        )

        let effect = Effect.deleteSection(section: sectionRecord)
        await model.handleEffect(effect: effect, db: db)

        try #require(model.projectData.sections.count == 1)
        #expect(model.projectData.sections[0].section.id == 1)
        #expect(model.projectData.selectedSectionForDeletion == nil)
        #expect(model.projectData.showDeleteSectionDialog == false)
    }
}
