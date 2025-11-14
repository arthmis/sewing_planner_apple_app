import Foundation

private protocol Settings {
    func set<T: Codable>(_ value: T, forKey: String) throws
    func get<T: Codable>(forKey key: String) throws -> T?
}

class AppSettings {
    private let directoryName: String
    private var data: [String: Data]

    init(directoryName: String) {
        self.directoryName = directoryName
        data = [:]

        let fileManager = FileManager.default
        do {
            print("Retrieving app settings")
            let settingsFileData = try getSettingsFileData(fileManager)

            let decoder = JSONDecoder()
            do {
                data = try decoder.decode([String: Data].self, from: settingsFileData)
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
        let fileManager = FileManager.default
        let encoder = JSONEncoder()
        let data = try encoder.encode(value)

        _ = self.data.updateValue(data, forKey: key)
        let dataToPersist = try encoder.encode(self.data)

        try writeSettings(dataToPersist, fileManager: fileManager)
    }

    func get<T: Codable>(forKey key: String) throws -> T? {
        let data = self.data[key]
        let decoder = JSONDecoder()
        if let setting = data {
            return try decoder.decode(T.self, from: setting)
        }

        let fileManager = FileManager.default
        let settingsFileData = try getSettingsFileData(fileManager)
        let settings = try decoder.decode([String: Data].self, from: settingsFileData)
        guard let settingData = settings[key] else {
            return nil
        }

        let setting = try decoder.decode(T.self, from: settingData)
        self.data.updateValue(settingData, forKey: key)

        return setting
    }

    private func writeSettings(_ data: Data, fileManager: FileManager) throws {
        let settingsDirectory = getSettingsDirectory(fileManager)

        let settingsFolderExists = fileManager.fileExists(atPath: settingsDirectory.path())

        if !settingsFolderExists {
            try fileManager.createDirectory(at: settingsDirectory, withIntermediateDirectories: true, attributes: nil)
        }

        let filePath = settingsDirectory.appendingPathComponent("settings").appendingPathExtension(for: .json)

        try data.write(to: filePath, options: [.atomic, .completeFileProtection])
    }

    private func getSettingsFileData(_ fileManager: FileManager) throws -> Data {
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
