//
//  BaseApplication.swift
//  RxSwiftStudy
//
//  Created by Luong Manh on 01/03/2024.
//

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
