//
//  VideoDownloadService.swift
//  TestValidateApp
//
//  Created by Nguyen Nam on 9/7/25.
//

import Foundation
import AVFoundation
import Combine

class VideoDownloadManager: NSObject {
    
    // MARK: - Properties
    private var assetURLSession: AVAssetDownloadURLSession?
    private var activeDownloads: [String: AVAssetDownloadTask] = [:]
    private let progressSubject = PassthroughSubject<(url: String, percentage: Int), Never>()
    
    var progressPublisher: AnyPublisher<(url: String, percentage: Int), Never> {
        progressSubject.eraseToAnyPublisher()
    }
    // MARK: - Singleton
    static let shared = VideoDownloadManager()
    
    override init() {
        super.init()
        setupDownloadSession()
    }
    
    // MARK: - Setup
    private func setupDownloadSession() {
        let backgroundConfig = URLSessionConfiguration.background(withIdentifier: "assetDownloadConfig")
        assetURLSession = AVAssetDownloadURLSession(configuration: backgroundConfig,
                                                   assetDownloadDelegate: self,
                                                   delegateQueue: nil)
    }
    
    // MARK: - Download Methods
    func downloadVideo(url: String, title: String, completion: @escaping (Result<URL, DownloadError>) -> Void) {
        guard let videoURL = URL(string: url) else {
            completion(.failure(.invalidURL))
            return
        }
        
        // Check network connectivity
        guard NetworkReachability.isConnected else {
            completion(.failure(.noInternetConnection))
            return
        }
        
        // Check if already downloading
        if activeDownloads[url] != nil {
            completion(.failure(.alreadyDownloading))
            return
        }
        
        let hlsAsset = AVURLAsset(url: videoURL)
        
        guard let assetURLSession = assetURLSession else {
            completion(.failure(.sessionNotAvailable))
            return
        }
        
        let assetDownloadTask = assetURLSession.makeAssetDownloadTask(
            asset: hlsAsset,
            assetTitle: title,
            assetArtworkData: nil,
            options: nil
        )
        
        guard let downloadTask = assetDownloadTask else {
            completion(.failure(.taskCreationFailed))
            return
        }
        
        // Store the task
        activeDownloads[url] = downloadTask
        
        // Store completion handler
        downloadCompletions[url] = completion
        
        downloadTask.resume()
    }
    
    func cancelDownload(url: String) {
        guard let downloadTask = activeDownloads[url] else { return }
        
        downloadTask.cancel()
        activeDownloads.removeValue(forKey: url)
        downloadCompletions.removeValue(forKey: url)
    }
    
    func pauseDownload(url: String) {
        guard let downloadTask = activeDownloads[url] else { return }
        downloadTask.suspend()
    }
    
    func resumeDownload(url: String) {
        guard let downloadTask = activeDownloads[url] else { return }
        downloadTask.resume()
    }
    
    // MARK: - Helper Properties
    private var downloadCompletions: [String: (Result<URL, DownloadError>) -> Void] = [:]
    
    // MARK: - Error Handling
    enum DownloadError: Error {
        case invalidURL
        case noInternetConnection
        case alreadyDownloading
        case sessionNotAvailable
        case taskCreationFailed
        case downloadFailed(Error)
        case cancelled
        
        var localizedDescription: String {
            switch self {
            case .invalidURL:
                return "URL không hợp lệ"
            case .noInternetConnection:
                return "Không có kết nối mạng"
            case .alreadyDownloading:
                return "Video đang được tải xuống"
            case .sessionNotAvailable:
                return "Session không khả dụng"
            case .taskCreationFailed:
                return "Không thể tạo task download"
            case .downloadFailed(let error):
                return "Lỗi tải xuống: \(error.localizedDescription)"
            case .cancelled:
                return "Đã hủy tải xuống"
            }
        }
    }
}

// MARK: - AVAssetDownloadDelegate
extension VideoDownloadManager: AVAssetDownloadDelegate {
    
    func urlSession(_ session: URLSession, assetDownloadTask: AVAssetDownloadTask, didFinishDownloadingTo location: URL) {
        print("Download finished to location: \(location)")
        
        // Find the corresponding URL
        let taskURL = findURLForTask(assetDownloadTask)
        
        // Remove from active downloads
        if let url = taskURL {
            activeDownloads.removeValue(forKey: url)
            
            // Call completion handler
            if let completion = downloadCompletions[url] {
                completion(.success(location))
                downloadCompletions.removeValue(forKey: url)
            }
        }
    }
    
    func urlSession(_ session: URLSession, assetDownloadTask: AVAssetDownloadTask, didLoad timeRange: CMTimeRange, totalTimeRangesLoaded loadedTimeRanges: [NSValue], timeRangeExpectedToLoad: CMTimeRange) {
        
        // Calculate progress
        var percentComplete = 0.0
        for value in loadedTimeRanges {
            let loadedTimeRange = value.timeRangeValue
            percentComplete += loadedTimeRange.duration.seconds / timeRangeExpectedToLoad.duration.seconds
        }
        
        print("Download progress: \(percentComplete * 100)%")
        
        // Notify progress if needed
        if let taskURL = findURLForTask(assetDownloadTask) {
            print("Progress for \(taskURL): \(percentComplete * 100)%")
            progressSubject.send((url: taskURL, percentage: Int(percentComplete * 100)))
        }
    }
    
    func urlSession(_ session: URLSession, task: URLSessionTask, didCompleteWithError error: Error?) {
        guard let assetDownloadTask = task as? AVAssetDownloadTask else { return }
        
        let taskURL = findURLForTask(assetDownloadTask)
        
        if let error = error {
            print("Download failed with error: \(error.localizedDescription)")
            
            // Handle specific error types
            if (error as NSError).code == NSURLErrorCancelled {
                // Download was cancelled
                if let url = taskURL, let completion = downloadCompletions[url] {
                    completion(.failure(.cancelled))
                    downloadCompletions.removeValue(forKey: url)
                }
            } else {
                // Other download errors
                if let url = taskURL, let completion = downloadCompletions[url] {
                    completion(.failure(.downloadFailed(error)))
                    downloadCompletions.removeValue(forKey: url)
                }
            }
        }
        
        // Clean up
        if let url = taskURL {
            activeDownloads.removeValue(forKey: url)
        }
    }
    
    func urlSession(_ session: URLSession, assetDownloadTask: AVAssetDownloadTask, didResolve resolvedMediaSelection: AVMediaSelection) {
        print("Media selection resolved")
    }
    
    // Helper method to find URL for task
    private func findURLForTask(_ task: AVAssetDownloadTask) -> String? {
        for (url, activeTask) in activeDownloads {
            if activeTask == task {
                return url
            }
        }
        return nil
    }
}

// MARK: - Network Reachability Helper
class NetworkReachability {
    static var isConnected: Bool {
        // Implement network reachability check
        // You can use Network framework or a third-party library
        return true // Simplified for example
    }
}

// MARK: - Notification Names
extension Notification.Name {
    static let downloadProgress = Notification.Name("downloadProgress")
    static let downloadCompleted = Notification.Name("downloadCompleted")
    static let downloadFailed = Notification.Name("downloadFailed")
}
