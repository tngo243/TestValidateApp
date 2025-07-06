//
//  UIViewController+.swift
//  TestValidateApp
//
//  Created by Thien Nguyen on 6/7/25.
//

import UIKit

extension UIViewController {
  @MainActor
  func popupAlert(title: String?, message: String?, actionTitles:[String?], actions:[((UIAlertAction) -> Void)?]) async {
    let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
    for (index, title) in actionTitles.enumerated() {
      let action = UIAlertAction(title: title, style: .default, handler: actions[index])
      alert.addAction(action)
    }
    self.present(alert, animated: true, completion: nil)
  }
}
