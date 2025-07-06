//
//  VideoItemState.swift
//  TestValidateApp
//
//  Created by Thien Nguyen on 4/7/25.
//

import Foundation

class VideoItem {
  let id: String
  let name: String
  let url: String
  var progress: Double
  var state: VideoItemState
  init(id: String, name: String, url: String, progress: Double, state: VideoItemState) {
    self.id = id
    self.name = name
    self.url = url
    self.progress = progress
    self.state = state
  }
}

enum VideoItemState {
  case downloading
  case completed
  case cancelled
  
  init(from assetState: Asset.DownloadState) {
    switch assetState {
    case .downloading:
      self = .downloading
    case .downloaded:
      self = .completed
    case .notDownloaded:
      self = .cancelled
    }
  }
}
