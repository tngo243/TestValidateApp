//
//  WatchingAVideoRouter.swift
//  TestValidateApp
//
//  Created by Thien Nguyen on 3/7/25.
//

import AVKit

final class WatchingAVideoRouter: WatchingAVideoRouterInput {
  private unowned let viewController: UIViewController
  init(viewController: UIViewController) {
    self.viewController = viewController
  }
  
}

@MainActor
extension WatchingAVideoRouter {
  func showPlayerView(videoUrl: String) {
    
    guard let videoURL = URL(string: videoUrl) else {
      return
    }
    let player = AVPlayer(url: videoURL)
    let playerViewController = AVPlayerViewController()
    playerViewController.player = player
    viewController.present(playerViewController, animated: true) {
      playerViewController.player?.play()
    }
  }
  
  func showPlayerView(videoUrl: URL) {
    let player = AVPlayer(url: videoUrl)
    let playerViewController = AVPlayerViewController()
    playerViewController.player = player
    viewController.present(playerViewController, animated: true) {
      playerViewController.player?.play()
    }
  }
}

