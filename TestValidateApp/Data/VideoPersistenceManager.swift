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
  
  private var didRestorePersistenceManager = false

  static let shared = VideoPersistenceManager()
      private init() {
        
      }
  
  /// Restores the application state by getting all instances of `AVAssetDownloadTask` and restoring their `Asset` structures.
  func restorePersistenceManager() {
    guard !didRestorePersistenceManager else { return }
    didRestorePersistenceManager = true
    
    /// Grab all the tasks associated with the `assetDownloadURLSession`.
    downloadSession.getAllTasks { [weak self] tasksArray in
      guard let self = self else { return }
      /// For each task, restore the state in the app by recreating `Asset` structures and reusing existing `AVURLAsset` objects.
      for task in tasksArray {
        guard let assetDownloadTask = task as? AVAssetDownloadTask, let assetName = task.taskDescription else { break }
        let urlAsset = assetDownloadTask.urlAsset
        
        let asset = Asset(
          stream: Stream(
            id: UUID().uuidString,
            name: assetName,
            playlistURL: assetDownloadTask.destinationURL.absoluteString // urlAsset always is null? >>> use `destinationURL`
          ),
          urlAsset: urlAsset
        )
        Task { @MainActor in
          await updateActiveDownloadAsync(task: assetDownloadTask, asset: asset)
        }

      }
      Task { @MainActor in
        NotificationCenter.default.post(name: .AssetPersistenceManagerDidRestoreState, object: nil)
      }

    }
  }
  
  func updateActiveDownloadAsync(task: AVAssetDownloadTask, asset: Asset) async {
    activeDownloads[task] = asset
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
                userInfo[Asset.Keys.id] = stream.id
                userInfo[Asset.Keys.name] = stream.name
                userInfo[Asset.Keys.percentDownloaded] = progress.fractionCompleted
              print("thiennq ===== .AssetDownloadProgress >> ", userInfo)
                NotificationCenter.default.post(name: .AssetDownloadProgress, object: nil, userInfo: userInfo)
            }
        }
        progressObservers[task] = progressObservation
        task.resume()
        
        var userInfo = [String: Any]()
        userInfo[Asset.Keys.id] = stream.id
        userInfo[Asset.Keys.name] = stream.name
        userInfo[Asset.Keys.downloadState] = Asset.DownloadState.downloading.rawValue

      await MainActor.run {
        NotificationCenter.default.post(name: .AssetDownloadStateChanged, object: nil, userInfo: userInfo)
      }
    }
    
  func localLoaclAssets() async -> [Asset] {
    let userDefaults = UserDefaults.standard
    let allKeys = userDefaults.dictionaryRepresentation().keys
    var asset: [Asset] = []
    
    for key in allKeys {
      guard let localFileLocation = userDefaults.value(forKey: key) as? Data else { continue }
      
      var bookmarkDataIsStale = false
      do {
        let url = try URL(resolvingBookmarkData: localFileLocation,
                          bookmarkDataIsStale: &bookmarkDataIsStale)
        
        if bookmarkDataIsStale {
          videoLogger.warning("Bookmark data is stale for key: \(key)")
        }
        
        let urlAsset = AVURLAsset(url: url)
        
        asset.append(Asset(
          stream: Stream(
            id: UUID().uuidString,
            name: key,
            playlistURL: url.absoluteString
          ),
          urlAsset: urlAsset
        ))
        
      } catch {
        print("Failed to create URL from bookmark with error: \(error)")
      }
    }
    return asset
  }
  
  func loadLocalAsset(videoName: String) async -> URL? {
    let userDefaults = UserDefaults.standard
    let allKeys = userDefaults.dictionaryRepresentation().keys
    
    if allKeys.contains(videoName) {
      guard let bookmarkData = userDefaults.value(forKey: videoName) as? Data else { return nil }
      
      var bookmarkDataIsStale = false
      do {
        let url = try URL(resolvingBookmarkData: bookmarkData,
                          bookmarkDataIsStale: &bookmarkDataIsStale)
        
        if bookmarkDataIsStale {
          videoLogger.warning("Bookmark data is stale for key: \(videoName)")
          return nil
        }
        
        guard FileManager.default.fileExists(atPath: url.path) else {
          videoLogger.warning("File doesn't exist at path for key: \(videoName)")
          userDefaults.removeObject(forKey: videoName)
          return nil
        }
        
        return url
      } catch {
        videoLogger.warning("Failed to load bookmark for key \(videoName): \(error.localizedDescription)")
        userDefaults.removeObject(forKey: videoName)
      }
    }
    
    return nil
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
                    userInfo[Asset.Keys.id] = stream.id
                    userInfo[Asset.Keys.name] = stream.name
                    userInfo[Asset.Keys.downloadState] = Asset.DownloadState.notDownloaded.rawValue
                    NotificationCenter.default.post(name: .AssetDownloadStateChanged, object: nil, userInfo: userInfo)
                } catch {
                  videoLogger.warning("Error deleting file: \(error.localizedDescription)")
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
      guard let asset = activeDownloads.removeValue(forKey: task) else { return }
      guard let location = willDownloadToUrlMap.removeValue(forKey: task) else {
        videoLogger.warning("No download location found for task")
        return
      }
      
        let userDefaults = UserDefaults.standard
        var userInfo = [String: Any]()
        userInfo[Asset.Keys.id] = asset.stream.id
        userInfo[Asset.Keys.name] = asset.stream.name
        if let error = error as NSError? {
            switch (error.domain, error.code) {
            case (NSURLErrorDomain, NSURLErrorCancelled):
                await deleteAsset(for: asset.stream)
                userInfo[Asset.Keys.downloadState] = Asset.DownloadState.notDownloaded.rawValue
            default:
                videoLogger.error("Unexpected error: \(error)")
              await ErrorNotificationManager.shared.postError(error)
            }
        } else {
                do {
                    let bookmark = try location.bookmarkData()
                    userDefaults.set(bookmark, forKey: asset.stream.name)
                    userInfo[Asset.Keys.downloadState] = Asset.DownloadState.downloaded.rawValue
                    userInfo[Asset.Keys.downloadSelectionDisplayName] = ""
                } catch {
                    videoLogger.error("Failed to create bookmarkData for download URL.")
                  await ErrorNotificationManager.shared.postError(TVAError.unknowError("Failed to save video."))
                }
        }
        await MainActor.run {
          print("thiennq ```````` .AssetDownloadStateChanged >> ", userInfo)
            NotificationCenter.default.post(name: .AssetDownloadStateChanged, object: nil, userInfo: userInfo)
        }
        self.removeTask(task)
    }
    
    func handleWillDownloadTo(task: AVAssetDownloadTask, location: URL) async {
        self.setWillDownloadTo(task: task, location: location)
    }
    
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
      Task {
        await owner?.handleWillDownloadTo(task: assetDownloadTask, location: location)
      }
    }
}

// MARK: - Objective-C Wrapper
@objc class VideoPersistenceManagerWrapper: NSObject {
  @objc static func restorePersistenceManager() {
    Task {
      await VideoPersistenceManager.shared.restorePersistenceManager()
    }
  }
}

extension Notification.Name {
    static let AssetDownloadProgress = Notification.Name(rawValue: "AssetDownloadProgressNotification")
    static let AssetDownloadStateChanged = Notification.Name(rawValue: "AssetDownloadStateChangedNotification")
    /// Notification for when `AssetPersistenceManager` has completely restored its state.
    static let AssetPersistenceManagerDidRestoreState = Notification.Name(rawValue: "AssetPersistenceManagerDidRestoreStateNotification")

}

