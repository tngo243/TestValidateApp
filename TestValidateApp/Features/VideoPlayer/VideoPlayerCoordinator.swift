//
//  VideoPlayerCoordinator.swift
//  TestValidateApp
//
//  Created by Nguyen Nam on 10/7/25.
//

import UIKit

class VideoPlayerCoordinator: BaseCoordinator {
    var navigationController: UINavigationController
    var childCoordinators: [BaseCoordinator] = []
    weak var parentCoordinator: TabBarCoordinator?
    
    private var videoData: VideoData?
    
    init(navigationController: UINavigationController) {
        self.navigationController = navigationController
    }
    
    func start() {
        guard let videoData else {
            print("Video data not set")
            return
        }
        let viewModel = VideoPlayerViewModel(videoData: videoData, coordinator: self)
        let viewController = VideoPlayerViewController(viewModel: viewModel)

        navigationController.pushViewController(viewController, animated: true)
    }

    func start(with videoData: VideoData) {
        self.videoData = videoData
        start()
    }
}
