//
//  UIviewControllerExt.swift
//  TestValidateApp
//
//  Created by Linh Phan on 3/7/25.
//

import UIKit

extension UIViewController {
    func hideKeyboard(){
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(
            target: self,
            action: #selector(UIViewController.dismissKeyboard))
        tap.cancelsTouchesInView = false
        view.addGestureRecognizer(tap)
    }
    
    @objc func dismissKeyboard(){
        view.endEditing(true)
    }
    
    func showAlert(title: String = "Notice", message: String, buttonTitle: String = "OK", completion: (() -> Void)? = nil) {
            let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)

            let action = UIAlertAction(title: buttonTitle, style: .default) { _ in
                completion?()
            }

            alert.addAction(action)
            self.present(alert, animated: true, completion: nil)
        }
}
