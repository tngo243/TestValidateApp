//
//  VideoDownloader.swift
//  TestValidateApp
//
//  Created by Linh Phan on 2/7/25.
//

import UIKit

import Foundation

class VideoDownloader: NSObject {
    static let shared = VideoDownloader()
    
    private lazy var session: URLSession = {
        let config = URLSessionConfiguration.default
        config.timeoutIntervalForRequest = 60
        return URLSession(configuration: config, delegate: self, delegateQueue: OperationQueue.main)
    }()
    
    private var progressHandlers: [URLSessionDownloadTask: (Double) -> Void] = [:]
    private var completionHandlers: [URLSessionDownloadTask: (URL?) -> Void] = [:]
    private var activeDownloads: [URLSessionDownloadTask: URL] = [:]
    
    private override init() {
        super.init()
    }
    
    func cancelDownload(for url: URL) {
        if let task = self.activeDownloads.first(where: { $0.value == url })?.key {
            task.cancel()
            self.cleanup(task: task)
            print("Canceled download for: \(url)")
        } else {
            print("No active task found for: \(url)")
        }
    }

    
    func download(from url: URL,
                  onProgress: @escaping (Double) -> Void,
                  onCompletion: @escaping (URL?) -> Void) {
        
        if self.activeDownloads.values.contains(url) { return }
        
        let task = self.session.downloadTask(with: url)
        self.activeDownloads[task] = url
        self.progressHandlers[task] = onProgress
        self.completionHandlers[task] = onCompletion
        task.resume()
        
        print("Started download for: \(url)")
    }
}

// MARK: - URLSessionDownloadDelegate
extension VideoDownloader: URLSessionDownloadDelegate {
    
    func urlSession(_ session: URLSession,
                    downloadTask: URLSessionDownloadTask,
                    didWriteData bytesWritten: Int64,
                    totalBytesWritten: Int64,
                    totalBytesExpectedToWrite: Int64) {
        
        guard totalBytesExpectedToWrite > 0,
              let handler = self.progressHandlers[downloadTask] else { return }
        
        let progress = Double(totalBytesWritten) / Double(totalBytesExpectedToWrite)
        handler(progress)
    }
    
    func urlSession(_ session: URLSession,
                    downloadTask: URLSessionDownloadTask,
                    didFinishDownloadingTo location: URL) {
        
        guard let originalURL = self.activeDownloads[downloadTask] else { return }
        
        let fileManager = FileManager.default
        let destURL = fileManager.temporaryDirectory.appendingPathComponent(originalURL.lastPathComponent)
        try? fileManager.removeItem(at: destURL)
        
        do {
            try fileManager.moveItem(at: location, to: destURL)
        } catch {
            print(" Move error for \(originalURL): \(error)")
        }
        
        if let completion = self.completionHandlers[downloadTask] {
            completion(destURL)
        }
        
        self.cleanup(task: downloadTask)
    }
    
    func urlSession(_ session: URLSession,
                    task: URLSessionTask,
                    didCompleteWithError error: Error?) {
        
        guard let downloadTask = task as? URLSessionDownloadTask,
              let originalURL = self.activeDownloads[downloadTask] else { return }
        
        if let err = error {
            print("Download failed for \(originalURL): \(err)")
            if let completion = self.completionHandlers[downloadTask] {
                completion(nil)
            }
        }
        
        self.cleanup(task: downloadTask)
    }
    
    private func cleanup(task: URLSessionDownloadTask) {
        self.activeDownloads[task] = nil
        self.progressHandlers[task] = nil
        self.completionHandlers[task] = nil
    }
}

