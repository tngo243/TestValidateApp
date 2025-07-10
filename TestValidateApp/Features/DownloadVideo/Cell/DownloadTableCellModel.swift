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
    public var title: String
    public var subtitle: String
    public var status: DownloadStatus
    public var progress: Double = 0.0  // Only for `.downloading`
    public var errorMessage: String?   // Only for `.failed`

    public init(title: String, subtitle: String, status: DownloadStatus, progress: Double = 0.0, errorMessage: String? = nil) {
        self.title = title
        self.subtitle = subtitle
        self.status = status
        self.progress = progress
        self.errorMessage = errorMessage
    }
}
