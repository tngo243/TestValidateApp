//
//  WatchingAVideoContracts.swift
//  TestValidateApp
//
//  Created Thien Nguyen on 3/7/25.
//

import Foundation

@MainActor
protocol WatchingAVideoViewInput: AnyObject {
}

@MainActor
protocol WatchingAVideoViewOutput: AnyObject {
  func viewIsReady() async
}

protocol WatchingAVideoInteractorProtocol: Actor {
}
