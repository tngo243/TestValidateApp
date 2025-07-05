//
//  VideoDownloadTask.swift
//  TestValidatedApp
//
//  Created by Luong Manh on 2/7/25.
//

import Foundation

class VideoDownloadTask: DownloadTask {
    let url: String
    let fileName: String

    var destinationURL: URL {
        return FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0].appendingPathComponent(fileName)
    }

    var sourceURL: URL {
        return URL(string: url)!
    }

    init(url: String, fileName: String) {
        self.url = url
        self.fileName = fileName
    }
}
