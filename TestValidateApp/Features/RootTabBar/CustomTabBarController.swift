//
//  CustomTabBarController.swift
//  TestValidateApp
//
//  Created by Nguyen Nam on 10/7/25.
//

import UIKit

class CustomTabBarController: UITabBarController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupCustomTabBar()
    }
    
    private func setupCustomTabBar() {
        // Hide default tab bar
        tabBar.isHidden = true
        
        // Add custom tab bar view
        let customTabBar = CustomTabBarView.fromNib() as CustomTabBarView
        customTabBar.delegate = self
        customTabBar.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(customTabBar)
        
        NSLayoutConstraint.activate([
            customTabBar.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            customTabBar.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }
}

extension CustomTabBarController: CustomTabBarViewDelegate {
    func tabBarView(_ tabBarView: CustomTabBarView, didSelectTabAt index: Int) {
        selectedIndex = index
    }
}
