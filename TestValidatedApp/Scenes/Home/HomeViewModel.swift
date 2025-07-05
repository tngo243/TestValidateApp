//
//  HomeViewModel.swift
//  RxSwiftStudy
//
//  Created by Luong Manh on 17/7/24.
//

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
                    if let thumbnail = VideoThumbnailHelper.generateHLSThumbnails(for: fileName) {
                        do {
                            try VideoThumbnailHelper.saveThumbnailImage(thumbnail, for: thumbFileName)
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
        
        self.task = VideoDownloadTask(
            url: url,
            fileName: fileName
        )
        
        Task {
            do {
                let saved = try await self.task?.start { progress in
                    debugPrint("⬇️ Progress: \(Int(progress * 100))%")
                    progressCompletion?(progress)
                }
                
                debugPrint("✅ Downloaded to: \(String(describing: saved))")
                
                await MainActor.run {
                    
                    if let thumbnail = VideoThumbnailHelper.generateThumbnail(for: fileName) {
                        do {
                            try VideoThumbnailHelper.saveThumbnailImage(thumbnail, for: thumbFileName)
                        } catch {
                            debugPrint(error.localizedDescription)
                        }
                    }
                    
                    debugPrint("🎉 Video saved to Core Data successfully!")
                }
                
                didFinishTask?()
            } catch {
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
        let validator = ObjectiveServices()
        return validator.validateUrl(url)
    }
}
