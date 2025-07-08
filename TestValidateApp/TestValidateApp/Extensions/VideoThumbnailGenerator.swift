//
//  VideoThumbnailGenerator.swift
//  TestValidateApp
//
//  Created by Thien Tung on 1/7/25.
//

import UIKit
import AVFoundation

class Commons {
    static let shared = Commons()
    
    func generateThumbnail(for url: URL) -> UIImage? {
        let asset = AVAsset(url: url)
        let generator = AVAssetImageGenerator(asset: asset)
        generator.appliesPreferredTrackTransform = true
        let time = CMTime(seconds: 5.0, preferredTimescale: 600)
        do {
            let imageRef = try generator.copyCGImage(at: time, actualTime: nil)
            return UIImage(cgImage: imageRef)
        } catch {
            print("Thumbnail error: \(error.localizedDescription)")
            return nil
        }
    }

    func getFormattedCreationDate(from fileURL: URL, format: String = "dd-MM-yyyy HH:mm") -> String {
        do {
            let attributes = try FileManager.default.attributesOfItem(atPath: fileURL.path)
            if let creationDate = attributes[.creationDate] as? Date {
                let formatter = DateFormatter()
                formatter.dateFormat = format
                return formatter.string(from: creationDate)
            } else {
                return "Unknown"
            }
        } catch {
            print("Lỗi khi lấy thông tin file: \(error.localizedDescription)")
            return "Unknown"
        }
    }

}
