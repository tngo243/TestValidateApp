//
//  WatchingAVideoContracts.swift
//  TestValidateApp
//
//  Created Thien Nguyen on 3/7/25.
//

import Foundation

@MainActor
protocol WatchingAVideoViewInput: AnyObject {
  func updateVideoItem(_ state: VideoItemState)
//  func playBtnTapped(videoUrl: String) 

}

@MainActor
protocol WatchingAVideoViewOutput: AnyObject {
  func viewIsReady() async
  
  func downloadBtnTapped(videoUrl: String) async
  func cancelBtnTapped(videoUrl: String) async
  func playBtnTapped(videoUrl: String) async

}

protocol WatchingAVideoInteractorProtocol: Actor {
  func downloadStream(_ s: Stream) async
  
}

@MainActor
protocol WatchingAVideoRouterInput: AnyObject {
  func showPlayerView(videoUrl: String)
}
