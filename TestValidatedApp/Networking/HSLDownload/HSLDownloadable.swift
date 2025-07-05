//
//  HSLDownloadable.swift
//  TestValidatedApp
//
//  Created by Luong Manh on 7/7/25.
//

import Foundation
import AVFoundation

typealias HLSDownloadTask = HLSDownloadable & DownloadTaskDefinition

protocol HLSDownloadable {
    func start(progress: @escaping (Float) -> Void) async throws -> URL
}

extension HLSDownloadable where Self: DownloadTaskDefinition {
    func start(progress: @escaping (Float) -> Void) async throws -> URL {
        
        let delegate = HLSDownloadDelegate(progress: progress, destinationURL: destinationURL)
        
        let session = AVAssetDownloadURLSession(
            configuration: .background(withIdentifier: "com.testValidatedApp.HLSDownloadSession.\(fileName)"),
            assetDownloadDelegate: delegate,
            delegateQueue: OperationQueue.main)
        
        return try await withCheckedThrowingContinuation { continuation in
            delegate.completion = { result in
                continuation.resume(with: result)
                DownloadQueueManager.shared.cancelAndRemove(fileName: fileName)
            }
            
            let urlAsset = AVURLAsset(url: sourceURL)
            let config = AVAssetDownloadConfiguration(asset: urlAsset, title: fileName)
            
            let task = session.makeAssetDownloadTask(downloadConfiguration: config)
            delegate.assign(task: task)
            
            DownloadQueueManager.shared.addHLS(delegate: delegate, to: fileName)
            task.resume()
        }
        
    }
    
    func cancel() {
        DownloadQueueManager.shared.cancelAndRemoveHLS(fileName: fileName)
    }
}
