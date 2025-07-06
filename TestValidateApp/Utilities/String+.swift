//
//  String+.swift
//  TestValidateApp
//
//  Created by Thien Nguyen on 6/7/25.
//

extension String {
  func isValidURL() async -> Bool {
    guard !self.isEmpty,
          let url = URL(string: self),
          let scheme = url.scheme,
          let host = url.host,
          !scheme.isEmpty,
          !host.isEmpty
    else {
      return false
    }
    let validSchemes = ["http", "https"]
    return validSchemes.contains(scheme.lowercased())
  }
}
