//
//  AlertHelper.swift
//  TestValidateApp
//
//  Created by Linh Vu on 9/7/25.
//

import Foundation
import UIKit

protocol MakeAlert {
    func showAlert(title: String,
                   message: String)
}

extension MakeAlert {
    func showAlert(title: String,
                   message: String) {
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alertController.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        DispatchQueue.main.async {
            UIApplication.getTopViewController()?.present(alertController, animated: true)
        }
    }
}
