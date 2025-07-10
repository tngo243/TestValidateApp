//
//  VideoListCoordinator.swift
//  TestValidateApp
//
//  Created by Nguyen Nam on 10/7/25.
//

import UIKit

class VideoListCoordinator: BaseCoordinator {
    var navigationController: UINavigationController
    var childCoordinators: [BaseCoordinator] = []
    weak var parentCoordinator: TabBarCoordinator?
    
    init(navigationController: UINavigationController) {
        self.navigationController = navigationController
    }
    
    func start() {
        let viewModel = VideoListViewModel(coordinator: self)
        let viewController = VideoListViewController(viewModel: viewModel)
        navigationController.setViewControllers([viewController], animated: false)
    }
    
    func showVideoPlayer(with videoData: VideoData) {
        parentCoordinator?.presentVideoPlayer(with: videoData)
    }
}
