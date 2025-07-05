//
//  WatchingAVideoInteractor.swift
//  TestValidateApp
//
//  Created Thien Nguyen on 3/7/25.
//

import Foundation

actor WatchingAVideoInteractor {
  fileprivate var streams: [Stream] = []
  
  func getStreams() async -> [Stream] {
    return streams
  }
  
//  func addStream(from videoItem: VideoItem) async {
//    let stream = Stream(
//      id: videoItem.id,
//      name: videoItem.name,
//      playlistURL: videoItem.url
//    )
//    streams.append(stream)
//  }
//  
  func updateStream(from videoItem: VideoItem) async {
    let stream = Stream(
      id: videoItem.id,
      name: videoItem.name,
      playlistURL: videoItem.url
    )
    if let index = streams.firstIndex(where: { $0.id == stream.id }) {
      streams[index] = stream
    }
  }
  
  func removeStream(withId id: String) async {
    streams.removeAll { $0.id == id }
  }
  
  func getVideoItems() async -> [VideoItem] {
    // Convert streams to video items for UI display
    return streams.map { stream in
      VideoItem(
        id: stream.id,
        name: stream.name,
        url: stream.playlistURL,
        progress: 0.0,
        state: .downloading
      )
    }
  }
}

extension WatchingAVideoInteractor: WatchingAVideoInteractorProtocol {
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
}
