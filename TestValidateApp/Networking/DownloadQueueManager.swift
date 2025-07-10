//
//  DownloadQueueManager.swift
//  TestValidateApp
//
//  Created by Linh Vu on 9/7/25.
//

import Foundation

class DownloadQueueManager {
    static var shared = DownloadQueueManager()
    private var downloadDelegateMap = [String: DownloadDelegate]()
    private var hlsDownloadDelegateMap = [String: HLSDownloadDelegate]()
    
    func add(delegate: DownloadDelegate, to fileName: String) {
        downloadDelegateMap[fileName] = delegate
    }
    
    func addHLS(delegate: HLSDownloadDelegate, to fileName: String) {
        hlsDownloadDelegateMap[fileName] = delegate
    }
    
    func cancelAndRemoveHLS(fileName: String) {
        hlsDownloadDelegateMap[fileName]?.cancel()
        hlsDownloadDelegateMap[fileName] = nil
    }
    
    func cancelAndRemove(fileName: String) {
        downloadDelegateMap[fileName]?.cancel()
        downloadDelegateMap[fileName] = nil
    }
}
