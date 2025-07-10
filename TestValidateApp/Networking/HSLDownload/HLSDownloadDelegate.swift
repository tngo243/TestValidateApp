//
//  HLSDownloadDelegate.swift
//  TestValidateApp
//
//  Created by Linh Vu on 9/7/25.
//

import Foundation
import AVFoundation

final class HLSDownloadDelegate: NSObject, AVAssetDownloadDelegate, @unchecked Sendable {
    private let progressHandler: (Float) -> Void
    private let destinationURL: URL
    var completion: ((Result<URL, Error>) -> Void)?
    
    private var task: AVAssetDownloadTask?
    
    init(progress: @escaping (Float) -> Void, destinationURL: URL) {
        self.progressHandler = progress
        self.destinationURL = destinationURL
    }
    
    func assign(task: AVAssetDownloadTask) {
        self.task = task
    }
    
    func cancel() {
        task?.cancel()
    }

    func urlSession(_ session: URLSession,
                    assetDownloadTask: AVAssetDownloadTask,
                    didLoad timeRange: CMTimeRange,
                    totalTimeRangesLoaded loadedTimeRanges: [NSValue],
                    timeRangeExpectedToLoad: CMTimeRange) {
        let loadedDuration = loadedTimeRanges
            .map { $0.timeRangeValue.duration.seconds }
            .reduce(0, +)

        let expectedDuration = timeRangeExpectedToLoad.duration.seconds
        let progress = Float(loadedDuration / expectedDuration)

        DispatchQueue.main.async {
            self.progressHandler(progress)
        }
    }

    var temporaryDownloadLocation: URL?
    func urlSession(_ session: URLSession,
                    assetDownloadTask: AVAssetDownloadTask,
                    willDownloadTo location: URL) {
        self.temporaryDownloadLocation = location
    }

    func urlSession(_ session: URLSession,
                    task: URLSessionTask,
                    didCompleteWithError error: Error?) {
        if let error = error {
            completion?(.failure(error))
            return
        }

        guard let tempLocation = self.temporaryDownloadLocation else {
            completion?(.failure(NSError(domain: "HLSDownload",
                                         code: -2,
                                         userInfo: [NSLocalizedDescriptionKey: "No temp file"])))
            return
        }

        do {
            let fm = FileManager.default
            if fm.fileExists(atPath: destinationURL.path) {
                try fm.removeItem(at: destinationURL)
            } else {
                try fm.createDirectory(atPath: destinationURL.deletingLastPathComponent().path,
                                       withIntermediateDirectories: true)
            }
            try fm.moveItem(at: tempLocation, to: destinationURL)
            completion?(.success(destinationURL))
        } catch {
            completion?(.failure(error))
        }
    }
}
