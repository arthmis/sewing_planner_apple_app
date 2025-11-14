import Foundation
import UniformTypeIdentifiers

protocol Settings {
    func set<T: Codable>(_ value: T, forKey: String) throws
    func get<T: Codable>(forKey key: String) throws -> T?
}

class AppSettings {
    private let directoryName: String
    private var data: [String: Data]
    private let settingsFileManager: any AppSettingsFileManagerProtocol

    init(directoryName: String, data: [String: Data]? = nil, settingsFileManager: (any AppSettingsFileManagerProtocol)? = nil) {
        self.directoryName = directoryName
        self.data = data ?? [:]

        let fileManager = FileManager.default
        self.settingsFileManager = settingsFileManager ?? AppSettingsFileManager(fileManager: fileManager, directoryName: directoryName)

        do {
            print("Retrieving app settings")
            let settingsFileData = try self.settingsFileManager.getSettingsFileData()

            let decoder = JSONDecoder()
            do {
                self.data = try decoder.decode([String: Data].self, from: settingsFileData)
            } catch {
                // TODO: log the error
                print(error)
            }
        } catch {
            // TODO: log the error
            print(error)
        }
    }
}

extension AppSettings: Settings {
    func set<T: Codable>(_ value: T, forKey key: String) throws {
        let encoder = JSONEncoder()
        let data = try encoder.encode(value)

        _ = self.data.updateValue(data, forKey: key)
        let dataToPersist = try encoder.encode(self.data)

        try settingsFileManager.writeSettings(dataToPersist)
    }

    func get<T: Codable>(forKey key: String) throws -> T? {
        let data = self.data[key]
        let decoder = JSONDecoder()
        if let setting = data {
            return try decoder.decode(T.self, from: setting)
        }

        let settingsFileData = try settingsFileManager.getSettingsFileData()
        let settings = try decoder.decode([String: Data].self, from: settingsFileData)
        guard let settingData = settings[key] else {
            return nil
        }

        let setting = try decoder.decode(T.self, from: settingData)
        self.data.updateValue(settingData, forKey: key)

        return setting
    }
}

protocol AppSettingsFileManagerProtocol {
    func writeSettings(_ data: Data) throws
    func getSettingsFileData() throws -> Data
}

private struct AppSettingsFileManager: AppSettingsFileManagerProtocol {
    private let fileManager: FileManager
    private let directoryName: String

    init(fileManager: FileManager, directoryName: String) {
        self.fileManager = fileManager
        self.directoryName = directoryName
    }

    func writeSettings(_ data: Data) throws {
        let settingsDirectory = getSettingsDirectory(fileManager)

        let settingsFolderExists = fileManager.fileExists(atPath: settingsDirectory.path())

        if !settingsFolderExists {
            try fileManager.createDirectory(at: settingsDirectory, withIntermediateDirectories: true, attributes: nil)
        }

        let filePath = settingsDirectory.appendingPathComponent("settings").appendingPathExtension(for: .json)

        try data.write(to: filePath, options: [.atomic, .completeFileProtection])
    }

    func getSettingsFileData() throws -> Data {
        let settingsDirectory = getSettingsDirectory(fileManager)

        let settingsFolderExists = fileManager.fileExists(atPath: settingsDirectory.path())

        if !settingsFolderExists {
            try fileManager.createDirectory(at: settingsDirectory, withIntermediateDirectories: true, attributes: nil)
        }

        let filePath = settingsDirectory.appendingPathComponent("settings").appendingPathExtension(for: .json)

        return try Data(contentsOf: filePath)
    }

    private func getSettingsDirectory(_ fileManager: FileManager) -> URL {
        let documentsUrl = fileManager.urls(for: .documentDirectory, in: .userDomainMask).first!

        return documentsUrl.appendingPathComponent(directoryName)
    }
}
