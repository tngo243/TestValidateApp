//
//  VideosSavedViewModel.swift
//  TestValidateApp
//
//  Created by Linh Vu on 9/7/25.
//

import Foundation
import UIKit

final class VideosSavedViewModel {
    let navigator: any VideosSavedNavigatorType
    let videoUseCase = UseCaseProvider.makeVideUseCase()
    
    init(navigator: any VideosSavedNavigatorType) {
        self.navigator = navigator
    }
    
    func fetchVideo() async -> [VideoModel] {
        await MainActor.run {
            let videos = videoUseCase.fetchVideos()
            
            return videos
        }
    }
    
    @MainActor
    func deleteVideo(_ video: VideoModel) {
        do {
            try videoUseCase.deleteVideo(name: video.name)
        } catch {
            navigator.showAlert(title: "Delete failed", message: error.localizedDescription)
        }
    }
}
