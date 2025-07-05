//
//  WatchingAVideoInteractor.swift
//  TestValidateApp
//
//  Created Thien Nguyen on 3/7/25.
//

import Foundation

actor WatchingAVideoInteractor {
}

extension WatchingAVideoInteractor: WatchingAVideoInteractorProtocol {
  func downloadStream(_ s: Stream) async {
    try? await VideoPersistenceManager.shared.downloadStream(for: s)
  }

}
