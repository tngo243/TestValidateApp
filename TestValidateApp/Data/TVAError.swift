//
//  TVAError.swift
//  TestValidateApp
//
//  Created by Thien Nguyen on 3/7/25.
//

import Foundation

enum TVAError: Error {
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
