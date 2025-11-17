import Foundation

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

    try settingsManager.set(createdOneProject, forKey: CREATED_ONE_PROJECT)
  }

  func getUserCreatedProjectFirstTime() -> Bool? {
    do {
      return try settingsManager.get(forKey: CREATED_ONE_PROJECT)
    } catch {
      // TODO: log the error
      print(error)
      return nil
    }
  }
}
