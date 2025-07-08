//
//  AppDelegate.swift
//  TestValidateApp
//
//  Created by Thien Tung on 1/7/25.
//

import UIKit

@main
class AppDelegate: UIResponder, UIApplicationDelegate {
    
    var window: UIWindow?
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {

        window = UIWindow(frame: UIScreen.main.bounds)
        window?.rootViewController = createTabBar()
        window?.makeKeyAndVisible()
        
        return true
    }
    
    private func createTabBar() -> UITabBarController {
        let tabBarController = UITabBarController()
        let downloadVC = UINavigationController(rootViewController: DownloadingVideoViewController())
        let downloadedVC = UINavigationController(rootViewController: DownloadedViewController())
        let hlsVC = UINavigationController(rootViewController: HLSViewController())
        
        downloadVC.tabBarItem = UITabBarItem(title: "Tải xuống", image: UIImage(systemName: "square.and.arrow.down"), tag: 0)
        downloadedVC.tabBarItem = UITabBarItem(title: "Đã tải", image: UIImage(systemName: "video"), tag: 1)
        hlsVC.tabBarItem = UITabBarItem(title: "HLS", image: UIImage(systemName: "square.and.arrow.up"), tag: 2)
        
        tabBarController.viewControllers = [downloadVC, downloadedVC, hlsVC]
        return tabBarController
    }
}

