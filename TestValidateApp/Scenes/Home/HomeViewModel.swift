//
//  HomeViewModel.swift
//  TestValidateApp
//
//  Created by Linh Vu on 9/7/25.
//

import Foundation
import Combine
import UIKit
import Foundation
import AVKit

class HomeViewModel {
    let navigator: any HomeNavigatorType
    let videoUseCase = UseCaseProvider.makeVideUseCase()
    var task: VideoDownloadTask?
    var hlsTask: HLSDownloadTask?
    
    init(navigator: any HomeNavigatorType) {
        self.navigator = navigator
    }
}

extension HomeViewModel {
    func downloadHLSVideo(from url: String,
                          progressCompletion: ((Float) -> Void)? = nil,
                          didFinishTask: (() -> Void)? = nil) {
        
        let fileName = "video-\(Date()).m3u8"
        let thumbFileName = "thumb-\(Date()).jpeg"
        
        self.hlsTask = HLSVideoDownloadTask(
            url: url,
            fileName: fileName
        )
        
        Task {
            do {
                let saved = try await self.hlsTask?.start { progress in
                    debugPrint("⬇️ Progress: \(Int(progress * 100))%")
                    progressCompletion?(progress)
                }
                
                debugPrint("✅ Downloaded to: \(String(describing: saved))")
                
                await MainActor.run {
                    
                    VideoThumbnailHelper.generateThumbnail(for: fileName) { thumbnail in
                        do {
                            if let thumbnail = thumbnail {
                                try VideoThumbnailHelper.saveThumbnailImage(thumbnail, for: thumbFileName)
                            }
                        } catch {
                            debugPrint(error.localizedDescription)
                        }
                    }

                    videoUseCase.saveVideo(
                        VideoModel(
                            name: fileName,
                            url: url,
                            thumbnailPath: thumbFileName,
                            createdAt: Date()
                        )
                    )
                    
                    debugPrint("🎉 Video saved to Core Data successfully!")
                }
                
                didFinishTask?()
            } catch {
                debugPrint(">>", error.localizedDescription)
                showAlert(title: "Error to download", message: error.localizedDescription)
            }
        }
    }
    
    
    func downloadVideo(from url: String,
                       progressCompletion: ((Float) -> Void)? = nil,
                       didFinishTask: (() -> Void)? = nil) {
        
        let fileName = "video-\(Date()).m3u8"
        let thumbFileName = "thumb-\(Date()).jpeg"
        
        self.hlsTask = HLSVideoDownloadTask(
            url: url,
            fileName: fileName
        )
        
        Task {
            do {
                let saved = try await self.hlsTask?.start { progress in
                    debugPrint("⬇️ Progress: \(Int(progress * 100))%")
                    progressCompletion?(progress)
                }
                
                debugPrint("✅ Downloaded to: \(String(describing: saved))")
                
                await MainActor.run {
                    VideoThumbnailHelper.generateThumbnail(for: fileName) { thumbnail in
                        do {
                            if let thumbnail = thumbnail {
                                try VideoThumbnailHelper.saveThumbnailImage(thumbnail, for: thumbFileName)
                            }
                        } catch {
                            debugPrint(error.localizedDescription)
                        }
                    }

                    videoUseCase.saveVideo(
                        VideoModel(
                            name: fileName,
                            url: url,
                            thumbnailPath: thumbFileName,
                            createdAt: Date()
                        )
                    )
                    
                    debugPrint("🎉 Video saved to Core Data successfully!")
                }
                
                didFinishTask?()
            } catch {
                debugPrint(">>", error.localizedDescription)
                showAlert(title: "Error to download", message: error.localizedDescription)
            }
        }
    }
    
    func cancelDownload() {
        task?.cancel()
        hlsTask?.cancel()
    }
    
    func navigateToVideosSaved(_ uiNavigationController: UINavigationController) {
        let viewController = navigator.makeVideosSaved().makeViewController()
        uiNavigationController.pushViewController(viewController, animated: true)
    }
    
    func showAlert(title: String, message: String) {
        navigator.showAlert(title: title, message: message)
    }
    
    func validateURL(_ url: String) -> Bool {
        return ValidationServices.shared.validateUrl(url)
    }
}
