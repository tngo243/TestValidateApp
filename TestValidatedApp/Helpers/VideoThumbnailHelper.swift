//
//  VideoThumbnailHelper.swift
//  TestValidatedApp
//
//  Created by Tiến Đạt on 3/7/25.
//

import UIKit
import AVKit
import AVFoundation

struct VideoThumbnailHelper {
    static func generateThumbnail(for fileName: String, completion: @escaping (UIImage?) -> Void) {
        let fileURL = FileManager.default.urls(for: .documentDirectory,
                                               in: .userDomainMask)[0].appendingPathComponent(fileName)
        if fileURL.absoluteString.contains(".m3u8") {
            let asset = AVURLAsset(url: fileURL)
            let item = AVPlayerItem(asset: asset)

            let output = AVPlayerItemVideoOutput(pixelBufferAttributes: [
                kCVPixelBufferPixelFormatTypeKey as String: kCVPixelFormatType_32BGRA
            ])
            item.add(output)

            let player = AVPlayer(playerItem: item)
            player.isMuted = true
            player.play()

            // wait for buffer to ready
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                let time = CMTime(seconds: Double.random(in: 1..<50),
                                  preferredTimescale: 600)
                var actualTime = CMTime.zero

                if output.hasNewPixelBuffer(forItemTime: time),
                   let buffer = output.copyPixelBuffer(forItemTime: time, itemTimeForDisplay: &actualTime) {

                    let ciImage = CIImage(cvPixelBuffer: buffer)
                    let context = CIContext(options: nil)

                    if let cgImage = context.createCGImage(ciImage, from: ciImage.extent) {
                        let image = UIImage(cgImage: cgImage)
                        completion(image)
                    } else {
                        print("❌ Failed to create CGImage for thumbnail")
                        completion(nil)
                    }
                } else {
                    print("❌ No pixel buffer at requested time for thumbnail")
                    completion(nil)
                }

                player.pause()
                player.replaceCurrentItem(with: nil)
            }
        } else {
            let asset = AVAsset(url: fileURL)
            let imageGenerator = AVAssetImageGenerator(asset: asset)
            imageGenerator.appliesPreferredTrackTransform = true
            let time = CMTime(seconds: 1, preferredTimescale: 60)
            do {
                let cgImage = try imageGenerator.copyCGImage(at: time, actualTime: nil)
                completion(UIImage(cgImage: cgImage))
            } catch {
                print("Failed to generate thumbnail: \(error)")
                completion(nil)
            }
        }
    }
    
    static func saveThumbnailImage(_ image: UIImage, for fileName: String) throws {
        guard let data = image.jpegData(compressionQuality: 1) else { return }
        
        let destinationURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0].appendingPathComponent(fileName)
        do {
            let fm = FileManager.default
            if fm.fileExists(atPath: destinationURL.path) {
                try fm.removeItem(at: destinationURL)
            }
            try data.write(to: destinationURL)
        } catch {
            print("Failed to save thumbnail: \(error.localizedDescription)")
        }
    }
    
    static func generateHLSThumbnails(for fileName: String) -> UIImage? {
        let fileURL = FileManager.default.urls(for: .documentDirectory,
                                               in: .userDomainMask)[0].appendingPathComponent(fileName)
        let asset = AVAsset(url: fileURL)
        let videoOutput = AVPlayerItemVideoOutput(pixelBufferAttributes: [String(kCVPixelBufferPixelFormatTypeKey): NSNumber(value: kCVPixelFormatType_32BGRA)])
        
        let player = AVPlayer(playerItem: .init(asset: asset))
        let currentTime: CMTime = player.currentTime()
        
        guard let buffer: CVPixelBuffer = videoOutput.copyPixelBuffer(forItemTime: currentTime, itemTimeForDisplay: nil) else { return nil }
        let ciImage: CIImage = CIImage(cvPixelBuffer: buffer)
        let context: CIContext = CIContext.init(options: nil)
        
        guard let cgImage: CGImage = context.createCGImage(ciImage, from: ciImage.extent) else { return nil }
        let image: UIImage = UIImage.init(cgImage: cgImage)
        
        return image
    }
}
