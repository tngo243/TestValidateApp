//
//  ApplicationNavigatorType.swift
//  TestValidateApp
//
//  Created by Linh Vu on 9/7/25.
//

import Foundation
import UIKit
import Combine

protocol ApplicationNavigatorType {
   func makeRootNavigator() -> HomeNavigatorType
}

extension ApplicationNavigatorType {
    func makeRootNavigator() -> HomeNavigatorType {
        let navigator = HomeNavigator()
        return navigator
    }
}

struct ApplicationNavigator: ApplicationNavigatorType {
   
}
