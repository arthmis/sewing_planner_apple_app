import Foundation
import Logging

private let CREATED_ONE_PROJECT = "Created Project First Time"

class UserSettings {
  private let settingsManager: any Settings
  private var createdOneProject: Bool
  private let logger: AppLogger

  init(
    settingsDirectory: String,
    logger: AppLogger
  ) {
    settingsManager = AppSettings(directoryName: settingsDirectory, logger: logger)
    self.logger = logger

    logger.info("instantiating settings manager")

    do {
      createdOneProject = try settingsManager.get(forKey: CREATED_ONE_PROJECT) ?? false
    } catch {
      createdOneProject = false
    }
  }

  func userCreatedProjectFirstTime(val: Bool) throws {
    let createdOneProject = val

    do {
      try settingsManager.set(createdOneProject, forKey: CREATED_ONE_PROJECT)
    } catch {
      let metadata: Logger.Metadata = [
        "error": .string(error.localizedDescription), "key": .string(CREATED_ONE_PROJECT),
        "value": .stringConvertible(val),
      ]
      logger.error("couldn't get user created project setting", metadata: metadata)
      throw error
    }
  }

  func getUserCreatedProjectFirstTime() -> Bool? {
    do {
      return try settingsManager.get(forKey: CREATED_ONE_PROJECT)
    } catch {
      let metadata: Logger.Metadata = [
        "error": .string(error.localizedDescription), "key": .string(CREATED_ONE_PROJECT),
      ]
      logger.error("couldn't get user created project setting", metadata: metadata)
      return nil
    }
  }
}
