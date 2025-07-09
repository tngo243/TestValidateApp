//
//  AppCoordinator.swift
//  TestValidateApp
//
//  Created by Nguyen Nam on 10/7/25.
//

import UIKit

@objc class AppCoordinator: NSObject {
    @objc var navigationController: UINavigationController
    @objc var childCoordinators: [Any] = []

    @objc init(navigationController: UINavigationController) {
        self.navigationController = navigationController
        super.init()
    }

    @objc func start() {
        showTabBarController()
    }

    private func showTabBarController() {
        let tabBarCoordinator = TabBarCoordinator(navigationController: navigationController)
        childCoordinators.append(tabBarCoordinator)
        tabBarCoordinator.start()
    }
}
