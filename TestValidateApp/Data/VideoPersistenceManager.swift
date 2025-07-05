//
//  VideoPersistenceManager.swift
//  TestValidateApp
//
//  Created by Thien Nguyen on 4/7/25.
//

import Foundation
import AVFoundation
import os

private let videoLogger = Logger(subsystem: "com.example.VideoPersistenceManager", category: "VideoPersistenceManager")

actor VideoPersistenceManager {
    
  private lazy var downloadSession: AVAssetDownloadURLSession = { [unowned self] in
      let config = URLSessionConfiguration.background(withIdentifier: "VideoPersistenceManager.Identifier")
      let delegate = VideoPersistenceManagerDelegate(owner: self)
      return AVAssetDownloadURLSession(configuration: config, assetDownloadDelegate: delegate, delegateQueue: OperationQueue.main)
  }()

    private var activeDownloads: [AVAssetDownloadTask: Asset] = [:]
    private var willDownloadToUrlMap: [AVAssetDownloadTask: URL] = [:]
    private var progressObservers: [AVAssetDownloadTask: NSKeyValueObservation] = [:]

  static let shared = VideoPersistenceManager()
      private init() {
        
      }
    
    // MARK: - Download
    func downloadStream(for stream: Stream) async throws {
        let url = URL(string: stream.playlistURL)!
        let urlAsset = AVURLAsset(url: url)
        let asset = Asset(stream: stream, urlAsset: urlAsset)
        let config = AVAssetDownloadConfiguration(asset: urlAsset, title: stream.name)
        let task = downloadSession.makeAssetDownloadTask(downloadConfiguration: config)
        task.taskDescription = stream.name
        activeDownloads[task] = asset
        
        let progressObservation = task.progress.observe(\.fractionCompleted) { progress, _ in
          
            Task { @MainActor in
                var userInfo = [String: Any]()
                userInfo[Asset.Keys.name] = stream.name
                userInfo[Asset.Keys.percentDownloaded] = progress.fractionCompleted
              print("thiennq ===== .AssetDownloadProgress >> ", userInfo)
                NotificationCenter.default.post(name: .AssetDownloadProgress, object: nil, userInfo: userInfo)
            }
        }
        progressObservers[task] = progressObservation
        task.resume()
        
        var userInfo = [String: Any]()
        userInfo[Asset.Keys.name] = stream.name
        userInfo[Asset.Keys.downloadState] = Asset.DownloadState.downloading.rawValue
      sleep(9)
      await MainActor.run {
        NotificationCenter.default.post(name: .AssetDownloadStateChanged, object: nil, userInfo: userInfo)
      }
    }
    
    // MARK: - State
    func downloadState(for stream: Stream) -> Asset.DownloadState {
        for (_, asset) in activeDownloads where asset.stream == stream {
            return .downloading
        }
        // Check if file exists on disk
        let userDefaults = UserDefaults.standard
        if let localFileLocation = userDefaults.value(forKey: stream.name) as? Data {
            var isStale = false
            if let url = try? URL(resolvingBookmarkData: localFileLocation, bookmarkDataIsStale: &isStale),
               FileManager.default.fileExists(atPath: url.path) {
                return .downloaded
            }
        }
        return .notDownloaded
    }
    
    func deleteAsset(for stream: Stream) async {
        let userDefaults = UserDefaults.standard
        if let localFileLocation = userDefaults.value(forKey: stream.name) as? Data {
            var isStale = false
            if let url = try? URL(resolvingBookmarkData: localFileLocation, bookmarkDataIsStale: &isStale) {
                do {
                    try FileManager.default.removeItem(at: url)
                    userDefaults.removeObject(forKey: stream.name)
                    var userInfo = [String: Any]()
                    userInfo[Asset.Keys.name] = stream.name
                    userInfo[Asset.Keys.downloadState] = Asset.DownloadState.notDownloaded.rawValue
                    NotificationCenter.default.post(name: .AssetDownloadStateChanged, object: nil, userInfo: userInfo)
                } catch {
                    videoLogger.error("Error deleting file: \(error.localizedDescription)")
                }
            }
        }
    }
    
    func cancelDownload(for stream: Stream) async {
        if let (task, _) = activeDownloads.first(where: { $0.value.stream == stream }) {
            task.cancel()
        }
    }
    
    // Called by delegate
    func handleDownloadFinished(task: AVAssetDownloadTask, error: Error?) async {
        guard let asset = activeDownloads[task] else { return }
        let userDefaults = UserDefaults.standard
        var userInfo = [String: Any]()
        userInfo[Asset.Keys.name] = asset.stream.name
        if let error = error as NSError? {
            switch (error.domain, error.code) {
            case (NSURLErrorDomain, NSURLErrorCancelled):
                await deleteAsset(for: asset.stream)
                userInfo[Asset.Keys.downloadState] = Asset.DownloadState.notDownloaded.rawValue
            default:
                videoLogger.error("Unexpected error: \(error)")
            }
        } else {
            if let location = willDownloadToUrlMap[task] {
                do {
                    let bookmark = try location.bookmarkData()
                    userDefaults.set(bookmark, forKey: asset.stream.name)
                    userInfo[Asset.Keys.downloadState] = Asset.DownloadState.downloaded.rawValue
                    userInfo[Asset.Keys.downloadSelectionDisplayName] = ""
                } catch {
                    videoLogger.error("Failed to create bookmarkData for download URL.")
                }
            } else {
                videoLogger.error("No download location found for task")
            }
        }
        await MainActor.run {
          print("thiennq ```````` .AssetDownloadStateChanged >> ", userInfo)
            NotificationCenter.default.post(name: .AssetDownloadStateChanged, object: nil, userInfo: userInfo)
        }
        self.removeTask(task)
    }
    
//    func handleWillDownloadTo(task: AVAssetDownloadTask, location: URL) async {
//      print(#function)
//        await self.setWillDownloadTo(task: task, location: location)
//    }
    
    func setWillDownloadTo(task: AVAssetDownloadTask, location: URL) {
        willDownloadToUrlMap[task] = location
      print("thiennq````````````` ", willDownloadToUrlMap.count)
    }
    
    private func removeTask(_ task: AVAssetDownloadTask) {
        activeDownloads.removeValue(forKey: task)
        willDownloadToUrlMap.removeValue(forKey: task)
        progressObservers[task]?.invalidate()
        progressObservers.removeValue(forKey: task)
    }
}

// MARK: - Delegate Wrapper

class VideoPersistenceManagerDelegate: NSObject, AVAssetDownloadDelegate, @unchecked Sendable {
    weak var owner: VideoPersistenceManager?
    init(owner: VideoPersistenceManager) {
        self.owner = owner
    }
    
    func urlSession(_ session: URLSession, task: URLSessionTask, didCompleteWithError error: Error?) {
        guard let downloadTask = task as? AVAssetDownloadTask else { return }
        Task {
            await owner?.handleDownloadFinished(task: downloadTask, error: error)
        }
    }
    
    func urlSession(_ session: URLSession, assetDownloadTask: AVAssetDownloadTask, willDownloadTo location: URL) {
      Task {await owner?.setWillDownloadTo(task: assetDownloadTask, location: location)}
//        Task {
//            await owner?.handleWillDownloadTo(task: assetDownloadTask, location: location)
//        }
    }
}

extension Notification.Name {
    static let AssetDownloadProgress = Notification.Name(rawValue: "AssetDownloadProgressNotification")
    static let AssetDownloadStateChanged = Notification.Name(rawValue: "AssetDownloadStateChangedNotification")
}

