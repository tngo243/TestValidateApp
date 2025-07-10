//
//  Downloadable.swift
//  TestValidateApp
//
//  Created by Linh Vu on 9/7/25.
//

import Foundation

protocol DownloadTaskDefinition {
    var url: String { get }
    var fileName: String { get }
    var sourceURL: URL { get }
    var destinationURL: URL { get }
}

typealias DownloadTask = Downloadable & DownloadTaskDefinition

protocol Downloadable {
    func start(progress: @escaping (Float) -> Void) async throws -> URL
}

extension Downloadable where Self: DownloadTaskDefinition {
    func start(progress: @escaping (Float) -> Void) async throws -> URL {
        let delegate = DownloadDelegate(progress: progress,
                                        destinationURL: destinationURL)
        let session = URLSession(configuration: .ephemeral,
                                 delegate: delegate,
                                 delegateQueue: nil)

        return try await withCheckedThrowingContinuation { continuation in
            delegate.completion = { result in
                continuation.resume(with: result)
                DownloadQueueManager.shared.cancelAndRemove(fileName: fileName)
            }

            let task = session.downloadTask(with: sourceURL)
            delegate.assign(task: task)

            DownloadQueueManager.shared.add(delegate: delegate, to: fileName)
            task.resume()
        }
    }

    func cancel() {
        DownloadQueueManager.shared.cancelAndRemove(fileName: fileName)
    }
}
