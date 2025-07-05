//
//  DownloadDelegate.swift
//  TestValidatedApp
//
//  Created by Luong Manh on 1/7/25.
//

import Foundation

final class DownloadDelegate: NSObject, URLSessionDownloadDelegate {
    private let progressHandler: (Float) -> Void
    private let destinationURL: URL
    var completion: ((Result<URL, Error>) -> Void)?

    private var task: URLSessionDownloadTask?

    init(progress: @escaping (Float) -> Void, destinationURL: URL) {
        self.progressHandler = progress
        self.destinationURL = destinationURL
    }

    func assign(task: URLSessionDownloadTask) {
        self.task = task
    }

    func cancel() {
        task?.cancel()
    }

    func urlSession(_ session: URLSession,
                    downloadTask: URLSessionDownloadTask,
                    didWriteData bytesWritten: Int64,
                    totalBytesWritten: Int64,
                    totalBytesExpectedToWrite: Int64) {
        guard totalBytesExpectedToWrite > 0 else { return }
        let progress = Float(totalBytesWritten) / Float(totalBytesExpectedToWrite)
        DispatchQueue.main.async {
            self.progressHandler(progress)
        }
    }

    func urlSession(_ session: URLSession,
                    downloadTask: URLSessionDownloadTask,
                    didFinishDownloadingTo location: URL) {
        do {
            let fm = FileManager.default
            if fm.fileExists(atPath: destinationURL.path) {
                try fm.removeItem(at: destinationURL)
            }
            try fm.moveItem(at: location, to: destinationURL)
            completion?(.success(destinationURL))
        } catch {
            completion?(.failure(error))
        }
    }

    func urlSession(_ session: URLSession,
                    task: URLSessionTask,
                    didCompleteWithError error: Error?) {
        if let error = error {
            completion?(.failure(error))
        }
    }
}
