//
//  WatchingAVideoPresenter.swift
//  TestValidateApp
//
//  Created Thien Nguyen on 3/7/25.
//

import Foundation

final class WatchingAVideoPresenter {
  weak var view: (any WatchingAVideoViewInput)?
  var interactor: any WatchingAVideoInteractorProtocol

  init(interactor: some WatchingAVideoInteractorProtocol) {
    self.interactor = interactor
  }
}

@MainActor
extension WatchingAVideoPresenter: WatchingAVideoViewOutput {
  func viewIsReady() async {
  }
}
