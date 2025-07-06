//
//  WatchingAVideoContracts.swift
//  TestValidateApp
//
//  Created Thien Nguyen on 3/7/25.
//

import Foundation

@MainActor
protocol WatchingAVideoViewInput: AnyObject {
  func updateVideoItems(_ items: [VideoItem])
  func addVideoItem(_ item: VideoItem)
  func updateVideoItem(_ item: VideoItem)
}

@MainActor
protocol WatchingAVideoViewOutput: AnyObject {
  func viewIsReady() async
  func didRestoreState() async
  
  func downloadBtnTapped(videoUrl: String) async
  func cancelDownloadTapped(videoId: String) async
  func playBtnTapped(videoUrl: String) async
  func videoItemSelected(videoName: String) async
}

protocol WatchingAVideoInteractorProtocol: Actor {
  func didRestoreState() async -> [Asset]
  // Stream management methods (accept VideoItem for mapping)
  func getStreams() async -> [Stream]
//  func addStream(from videoItem: VideoItem) async
  func updateStream(from videoItem: VideoItem) async
  func removeStream(withId id: String) async
  
  // VideoItem conversion for UI
//  func getVideoItems() async -> [VideoItem]
  
  // Download functionality
  func downloadStream(_ s: Stream) async
  func cancelDownload(for videoId: String) async -> Stream?
  
  // Load local asset
  func loadLocalAsset(videoName: String) async -> URL?
}

@MainActor
protocol WatchingAVideoRouterInput: AnyObject {
  func showPlayerView(videoUrl: String)
  func showPlayerView(videoUrl: URL)
}
