import Foundation
import Logging
import Synchronization

private let CREATED_ONE_PROJECT = "Created Project First Time"

final class UserSettings: @unchecked Sendable {
  private let settingsManager: any Settings
  private let createdOneProjectLock: Mutex<Bool>
  private let logger: AppLogger

  init(
    settingsDirectory: String,
    logger: AppLogger
  ) {
    settingsManager = AppSettings(directoryName: settingsDirectory, logger: logger)
    self.logger = logger

    logger.info("instantiating settings manager")

    let initialValue: Bool
    do {
      initialValue = try settingsManager.get(forKey: CREATED_ONE_PROJECT) ?? false
    } catch {
      initialValue = false
    }

    createdOneProjectLock = Mutex(initialValue)
  }

  func userCreatedProjectFirstTime(val: Bool) throws {
    let oldVal = createdOneProjectLock.withLock { createdOneProject in
      let oldVal = createdOneProject
      createdOneProject = val
      return oldVal
    }

    do {
      try settingsManager.set(val, forKey: CREATED_ONE_PROJECT)
    } catch {
      createdOneProjectLock.withLock { createdOneProject in
        createdOneProject = oldVal
      }

      let metadata: Logger.Metadata = [
        "error": .string(error.localizedDescription), "key": .string(CREATED_ONE_PROJECT),
        "value": .stringConvertible(val),
      ]
      logger.error("couldn't save user created project setting to disk", metadata: metadata)

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
