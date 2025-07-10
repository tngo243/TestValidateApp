//
//  DownloadTableCellModel.swift
//  TestValidateApp
//
//  Created by Nguyen Nam on 10/7/25.
//

@objc public enum DownloadStatus: Int {
    case downloading
    case completed
    case failed
    case cancelled
}

@objcMembers
public class DownloadTableCellModel: NSObject {
    public var videoName: String
    public var link: String
    public var status: DownloadStatus
    public var progress: Int = 0  // Only for `.downloading`
    public var errorMessage: String?   // Only for `.failed`

    public init(videoName: String, link: String, status: DownloadStatus, progress: Int = 0, errorMessage: String? = nil) {
        self.videoName = videoName
        self.link = link
        self.status = status
        self.progress = progress
        self.errorMessage = errorMessage
    }
}
