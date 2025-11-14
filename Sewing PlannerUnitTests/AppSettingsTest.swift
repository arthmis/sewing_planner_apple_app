import Foundation
import Testing

@testable import Sewing_Planner

struct AppSettingTests {
    @Test("test get setting after inserting")
    @MainActor func getSettingAfterInsert() {
        let mockSettingsFileManager = MockSettingsFileManager(writeSettings: { _ in })
        let appSettings = AppSettings(directoryName: "App Settings", settingsFileManager: mockSettingsFileManager)

        let userCreatedProjectSetting = true
        let encoder = JSONEncoder()
        try! appSettings.set(encoder.encode(userCreatedProjectSetting), forKey: "created project")

        let retrievedSetting: Bool? = try! appSettings.get(forKey: "created project")

        #expect(retrievedSetting! == userCreatedProjectSetting)
    }

    @Test("test get setting, isn't in memory but is stored")
    @MainActor func getSettingNotInCacheInPersistentStorage() {
        let mockSettingsFileManager = MockSettingsFileManager(writeSettings: { _ in }, getSettingsFileData: {
            let encoder = JSONEncoder()
            let val = try! encoder.encode(false)
            let dict: [String: Data] = ["created project": val]
            let data = try! encoder.encode(dict)
            return data
        })
        let appSettings = AppSettings(directoryName: "App Settings", settingsFileManager: mockSettingsFileManager)

        let retrievedSetting: Bool? = try! appSettings.get(forKey: "created project")

        #expect(retrievedSetting! == false)
    }

    @Test("test get setting that doesn't exist")
    @MainActor func getSettingDoesNotExist() {
        let mockSettingsFileManager = MockSettingsFileManager(writeSettings: { _ in }, getSettingsFileData: {
            let encoder = JSONEncoder()
            let val = try! encoder.encode(21)
            let dict: [String: Data] = ["times counted": val]
            let data = try! encoder.encode(dict)
            return data
        })
        let appSettings = AppSettings(directoryName: "App Settings", settingsFileManager: mockSettingsFileManager)

        let retrievedSetting: Bool? = try! appSettings.get(forKey: "created project")

        #expect(retrievedSetting == nil)
    }
}

private struct MockSettingsFileManager: AppSettingsFileManagerProtocol {
    private let writeSettingsInner: Optional<(Data) throws -> Void>
    private let getSettingsFileDataInner: Optional<() throws -> Data>

    init(
        writeSettings: ((Data) throws -> Void)? = nil, getSettingsFileData: (() throws -> Data)? = nil
    ) {
        writeSettingsInner = writeSettings
        getSettingsFileDataInner = getSettingsFileData
    }

    func writeSettings(_ data: Data) throws {
        if let inner = writeSettingsInner {
            try inner(data)
        }
    }

    func getSettingsFileData() throws -> Data {
        if let inner = getSettingsFileDataInner {
            return try inner()
        }

        return Data()
    }
}
