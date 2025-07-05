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
  var router: (any WatchingAVideoRouterInput)?
  
  init(interactor: some WatchingAVideoInteractorProtocol) {
    self.interactor = interactor
    
  }
}

@MainActor
extension WatchingAVideoPresenter: WatchingAVideoViewOutput {
  func downloadBtnTapped(videoUrl: String) async {
    print("download")
//    await interactor.downloadStream(Stream(name: "raw text", playlistURL: videoUrl))

    await interactor.downloadStream(Stream(name: "Basic Stream", playlistURL: "https://devstreaming-cdn.apple.com/videos/streaming/examples/bipbop_4x3/bipbop_4x3_variant.m3u8"))
  }
  
  func cancelBtnTapped(videoUrl: String) async {
    print("cancel download for: \(videoUrl)")
    // TODO: Implement cancel download logic
  }
  
  func playBtnTapped(videoUrl: String) async {
    print("play ")
    router?.showPlayerView(videoUrl: videoUrl)
  }
  
  func viewIsReady() async {
  }
}
