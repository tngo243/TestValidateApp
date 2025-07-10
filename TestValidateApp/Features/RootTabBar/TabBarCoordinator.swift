//
//  TabBarCoordinator.swift
//  TestValidateApp
//
//  Created by Nguyen Nam on 10/7/25.
//

import UIKit

class TabBarCoordinator: BaseCoordinator {
    var navigationController: UINavigationController
    var childCoordinators: [BaseCoordinator] = []
    private var tabBarController: CustomTabBarController?
    
    init(navigationController: UINavigationController) {
        self.navigationController = navigationController
    }
    
    func start() {
        setupTabBarController()
    }
    
    private func setupTabBarController() {
        tabBarController = CustomTabBarController()
        
        // Setup Tab 1 - Download Video
        let downloadVidTabNav = UINavigationController()
        let downloadVidTabCoordinator = DownloadVideoCoordinator(navigationController: downloadVidTabNav)
        downloadVidTabCoordinator.parentCoordinator = self
        addChild(downloadVidTabCoordinator)
        downloadVidTabCoordinator.start()
        
        // Setup Tab 2 - Video List
        let videoListNav = UINavigationController()
        let videoListCoordinator = VideoListCoordinator(navigationController: videoListNav)
        videoListCoordinator.parentCoordinator = self
        addChild(videoListCoordinator)
        videoListCoordinator.start()

        // Configure tab bar
        tabBarController?.viewControllers = [downloadVidTabNav, videoListNav]
        
        navigationController.setViewControllers([tabBarController!], animated: false)
    }
    
    func presentVideoPlayer(with videoData: VideoData) {
        let videoPlayerCoordinator = VideoPlayerCoordinator(navigationController: navigationController)
        videoPlayerCoordinator.parentCoordinator = self
        addChild(videoPlayerCoordinator)
        videoPlayerCoordinator.start(with: videoData)
    }
}
