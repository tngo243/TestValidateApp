//
//  WatchingAVideoInteractor.swift
//  TestValidateApp
//
//  Created Thien Nguyen on 3/7/25.
//

import Foundation

actor WatchingAVideoInteractor {
  fileprivate var streams: [Stream] = []
}

extension WatchingAVideoInteractor: WatchingAVideoInteractorProtocol {
  func didRestoreState() async -> [Asset] {
    return await VideoPersistenceManager.shared.localLoaclAssets()
  }
  
  func downloadStream(_ s: Stream) async {
    do {
      try await VideoPersistenceManager.shared.downloadStream(for: s)
      
      streams.append(s)
    } catch {
      
    }
  }
  
  func cancelDownload(for videoId: String) async -> Stream? {
    if let stream = streams.first(where: { $0.id == videoId }) {
      await VideoPersistenceManager.shared.cancelDownload(for: stream)
      streams.removeAll { $0.id == videoId }
      
      // Return the cancelled stream for UI update
      return stream
    }
    return nil
  }
  
  func loadLocalAsset(videoName: String) async -> URL? {
    return await VideoPersistenceManager.shared.loadLocalAsset(videoName: videoName)
  }
}
