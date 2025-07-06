//
//  TVAError.swift
//  TestValidateApp
//
//  Created by Thien Nguyen on 3/7/25.
//

import Foundation

enum TVAError: Error, Sendable {
  case lossConnection
  case invalidUrl
  case unknowError(String)
}
extension TVAError: LocalizedError {
  var errorDescription: String? {
    switch self {
    case .lossConnection:
      return "Loss Connection"
    case .invalidUrl:
      return "Invalid URL"
    case .unknowError(let des):
      return des
    }
  }
}

actor ErrorNotificationManager {
  static let shared = ErrorNotificationManager()
  
  func postError(_ error: Error) {
    Task { @MainActor in
      NotificationCenter.postError(error, additionalInfo: nil)
    }
  }
  // Wrapper
  func sendError(_ error: Error) async {
    postError(error)
  }
}

extension Notification.Name {
  static let errorOccurred = Notification.Name("errorOccurred")
}

struct ErrorNotification {
  static let errorKey = "error"
  static let additionalInfoKey = "additionalInfo"
}

private extension NotificationCenter {
  @MainActor
  static func postError(_ error: Error, additionalInfo: [String: Any]? = nil) {
    let userInfo: [String: Any] = [
      ErrorNotification.errorKey: error,
      ErrorNotification.additionalInfoKey: additionalInfo ?? [:]
    ]
    NotificationCenter.default.post(
      name: .errorOccurred,
      object: nil,
      userInfo: userInfo
    )
  }
}
