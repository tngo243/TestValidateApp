//
//  Extension+UIViewController.swift
//  TestValidateApp
//
//  Created by Thien Tung on 2/7/25.
//

import UIKit

extension UIViewController {
    func showAlert(message: String, actionName: String? = nil, action: (() -> Void)? = nil) {
        let alert = UIAlertController(title: "Thông báo", message: message, preferredStyle: .alert)
        if let action = action {
            alert.addAction(UIAlertAction(title: actionName, style: .default, handler: { _ in
                action()
            }))
            alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        } else {
            alert.addAction(UIAlertAction(title: "OK", style: .default))
        }
        
        present(alert, animated: true)
    }
}
