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
    
    // Create a new VideoItem for the download
    let videoItem = VideoItem(
      id: UUID().uuidString,
      name: "Video \(Date().timeIntervalSince1970)",
      url: videoUrl,
      progress: 0.0,
      state: .downloading
    )
    
    // Update the VC with the video item
    view?.addVideoItem(videoItem)
    
    // Start the download
    await interactor.downloadStream(Stream(id: videoItem.id, name: videoItem.name, playlistURL: videoUrl))
  }
  
  func cancelDownloadTapped(videoId: String) async {
    print("cancel download for video ID: \(videoId)")
    
    // Cancel the download through interactor and get the cancelled stream
    if let cancelledStream = await interactor.cancelDownload(for: videoId) {
      // Create a cancelled video item and update the UI
      let cancelledVideoItem = VideoItem(
        id: videoId,
        name: cancelledStream.name,
        url: cancelledStream.playlistURL,
        progress: 0.0,
        state: .cancelled
      )
      view?.updateVideoItem(cancelledVideoItem)
    }
  }
  
  func playBtnTapped(videoUrl: String) async {
    print("play ")
    router?.showPlayerView(videoUrl: videoUrl)
  }
  
  func viewIsReady() async {
    // Load existing video items
//    let videoItems = await interactor.getVideoItems()
//    view?.updateVideoItems(videoItems)
  }
}
