//
//  UIViewController+Ext.swift
//  TestValidateApp
//
//  Created by Nguyen Hai Nam on 9/7/25.
//

import UIKit

extension UIViewController {
    internal func executeOnMainQueueIfNeed(withClosure closure: @escaping () -> Void) {
        if Thread.isMainThread {
            closure()
        } else {
            DispatchQueue.main.async(execute: closure)
        }
    }
}
