//
//  DownloadVideoCoordinator.swift
//  TestValidateApp
//
//  Created by Nguyen Nam on 10/7/25.
//

import UIKit

class DownloadVideoCoordinator: BaseCoordinator {
    var navigationController: UINavigationController
    var childCoordinators: [BaseCoordinator] = []
    weak var parentCoordinator: TabBarCoordinator?
    
    init(navigationController: UINavigationController) {
        self.navigationController = navigationController
    }
    
    func start() {
        let viewModel = DownloadVideoViewModel(coordinator: self)
        guard let viewController = DownloadVideoViewController(viewModel: viewModel) else {
            return
        }
        navigationController.setViewControllers([viewController], animated: false)
    }
}
