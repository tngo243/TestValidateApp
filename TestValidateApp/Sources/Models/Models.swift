//
//  Models.swift
//  TestValidateApp
//
//  Created by Linh Phan on 2/7/25.
//

import Foundation
import UIKit


struct DownloadItem: Codable {
    let urlString: String
    var progress: Double
    var isCompleted: Bool
    var localFileURL: URL?
    var thumbnailData: Data?
    var url: URL? {
        return URL(string: urlString)
    }
    var thumbnail: UIImage? {
        guard let data = thumbnailData else { return nil }
        return UIImage(data: data)
    }
}
