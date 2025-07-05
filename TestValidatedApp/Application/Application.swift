//
//  Application.swift
//  TestValidatedApp
//
//  Created by Luong Manh on 1/7/25.
//

import UIKit

class Application {
    static let shared = Application()
    
    func configMainInterface(in window: UIWindow?,
                             launchOptions: [UIApplication.LaunchOptionsKey: Any]? = nil) {
        let navigator = ApplicationNavigator()
        let viewController = UINavigationController(
            rootViewController: navigator.makeRootNavigator().makeViewController())
        window?.rootViewController = viewController
        window?.makeKeyAndVisible()
        
    }
}
