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
    private let cancelSubject = PassthroughSubject<String, Never>()
    private let successSubject = PassthroughSubject<String, Never>()

    var progressPublisher: AnyPublisher<(url: String, percentage: Int), Never> {
        progressSubject.eraseToAnyPublisher()
    }
    var cancelPublisher: AnyPublisher<String, Never> {
        cancelSubject.eraseToAnyPublisher()
    }
    var successPublisher: AnyPublisher<String, Never> {
        successSubject.eraseToAnyPublisher()
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
        
        guard Helpers.isConnectedToNetwork() else {
            completion(.failure(.noInternetConnection))
            return
        }
        
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
        
        activeDownloads[url] = downloadTask
        downloadCompletions[url] = completion
        
        downloadTask.resume()
    }
    
    func cancelDownload(url: String) {
        guard let downloadTask = activeDownloads[url] else { return }
        
        downloadTask.cancel()
        cancelSubject.send(url)
        activeDownloads.removeValue(forKey: url)
        downloadCompletions.removeValue(forKey: url)
    }
    
    func cancelAllDownloads() {
        for (url, downloadTask) in activeDownloads {
            downloadTask.cancel()
            cancelSubject.send(url)
            downloadCompletions.removeValue(forKey: url)
        }
        activeDownloads.removeAll()
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
        let taskURL = findURLForTask(assetDownloadTask)
        
        if let url = taskURL {
            activeDownloads.removeValue(forKey: url)
            if let completion = downloadCompletions[url] {
                completion(.success(location))
                downloadCompletions.removeValue(forKey: url)
            }
            successSubject.send(url)
        }
    }
    
    func urlSession(_ session: URLSession, assetDownloadTask: AVAssetDownloadTask, didLoad timeRange: CMTimeRange, totalTimeRangesLoaded loadedTimeRanges: [NSValue], timeRangeExpectedToLoad: CMTimeRange) {
        
        var percentComplete = 0.0
        for value in loadedTimeRanges {
            let loadedTimeRange = value.timeRangeValue
            percentComplete += loadedTimeRange.duration.seconds / timeRangeExpectedToLoad.duration.seconds
        }
        
        if let taskURL = findURLForTask(assetDownloadTask) {
            progressSubject.send((url: taskURL, percentage: Int(percentComplete * 100)))
        }
    }
    
    func urlSession(_ session: URLSession, task: URLSessionTask, didCompleteWithError error: Error?) {
        guard let assetDownloadTask = task as? AVAssetDownloadTask else { return }
        
        let taskURL = findURLForTask(assetDownloadTask)
        
        if let error = error {
            if (error as NSError).code == NSURLErrorCancelled {
                if let url = taskURL, let completion = downloadCompletions[url] {
                    completion(.failure(.cancelled))
                    downloadCompletions.removeValue(forKey: url)
                }
            } else {
                if let url = taskURL, let completion = downloadCompletions[url] {
                    completion(.failure(.downloadFailed(error)))
                    downloadCompletions.removeValue(forKey: url)
                }
            }
        }
        
        if let url = taskURL {
            activeDownloads.removeValue(forKey: url)
        }
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
