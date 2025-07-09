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
    
    init(navigationController: UINavigationController) {
        self.navigationController = navigationController
    }
    
    func start(/*with videoData: VideoData*/) {
//        let viewModel = VideoPlayerViewModel(coordinator: self, videoData: videoData)
//        let viewController = VideoPlayerViewController(viewModel: viewModel)
        let viewModel = VideoPlayerViewModel(coordinator: self)
        let viewController = VideoPlayerViewController(viewModel: viewModel)

        // Present full screen from bottom like YouTube
        viewController.modalPresentationStyle = .fullScreen
        viewController.modalTransitionStyle = .coverVertical
        
        navigationController.present(viewController, animated: true)
    }
    
    func dismissVideoPlayer() {
        navigationController.dismiss(animated: true) { [weak self] in
            guard let self = self else { return }
            self.parentCoordinator?.removeChild(self)
        }
    }
}
