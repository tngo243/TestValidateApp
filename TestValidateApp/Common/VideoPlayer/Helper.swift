//
//  Helper.swift
//  TestValidateApp
//
//  Created by Nguyen Nam on 11/7/25.
//

import AVFoundation

class Helper {
    static func generateThumbnail(for url: URL) -> UIImage? {
        let asset = AVAsset(url: url)
        let generator = AVAssetImageGenerator(asset: asset)
        generator.appliesPreferredTrackTransform = true
        let time = CMTime(seconds: 1.0, preferredTimescale: 100)
        var actualTime: CMTime = CMTime.zero

        do {
            let imageRef = try generator.copyCGImage(at: time, actualTime: &actualTime)
            return UIImage(cgImage: imageRef)
        } catch {
            print("Thumbnail error: \(error.localizedDescription)")
            return nil
        }
    }
}
