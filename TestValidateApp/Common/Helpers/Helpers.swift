//
//  InternetMonitor.swift
//  TestValidateApp
//
//  Created by Nguyen Nam on 11/7/25.
//

import Foundation
import SystemConfiguration

class Helpers {
    static func isConnectedToNetwork() -> Bool {
        var zeroAddress = sockaddr_in()
        zeroAddress.sin_len = UInt8(MemoryLayout<sockaddr_in>.size)
        zeroAddress.sin_family = sa_family_t(AF_INET)
        
        guard let defaultRouteReachability = withUnsafePointer(to: &zeroAddress, {
            $0.withMemoryRebound(to: sockaddr.self, capacity: 1) {
                SCNetworkReachabilityCreateWithAddress(nil, $0)
            }
        }) else {
            return false
        }
        
        var flags: SCNetworkReachabilityFlags = []
        if !SCNetworkReachabilityGetFlags(defaultRouteReachability, &flags) {
            return false
        }
        if flags.isEmpty {
            return false
        }
        
        let isReachable = flags.contains(.reachable)
        let needsConnection = flags.contains(.connectionRequired)
        
        return isReachable && !needsConnection
    }
    
    static func getTopMostViewController(controller: UIViewController? =
        UIApplication.shared.keyWindow?.rootViewController) -> UIViewController
    {
        if let navigationController = controller as? UINavigationController {
            return getTopMostViewController(controller: navigationController.visibleViewController)
        }
        if let tabController = controller as? UITabBarController {
            if let selected = tabController.selectedViewController {
                return getTopMostViewController(controller: selected)
            } else if let seledted = tabController.viewControllers?.first {
                return getTopMostViewController(controller: seledted)
            }
        }
        if let presented = controller?.presentedViewController {
            return getTopMostViewController(controller: presented)
        }
        return controller ?? UIViewController()
    }
    
    static func showAlert(title: String, message: String, on viewController: UIViewController = getTopMostViewController()) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        viewController.present(alert, animated: true, completion: nil)
    }
}
