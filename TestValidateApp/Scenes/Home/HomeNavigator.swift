//
//  HomeNavigator.swift
//  TestValidateApp
//
//  Created by Linh Vu on 9/7/25.
//

import Foundation
import UIKit

protocol HomeNavigatorType: MakeHome, MakeAlert, MakeVideosSaved {
    func makeViewController() -> UIViewController
}

protocol MakeHome {
    func makeHome() -> any HomeNavigatorType
}

extension MakeHome {
    func makeHome() -> any HomeNavigatorType {
        return HomeNavigator()
    }
}

struct HomeNavigator: HomeNavigatorType {
    func makeViewController() -> UIViewController {
        let viewModel = HomeViewModel(navigator: self)
        let viewController = HomeViewController(viewModel: viewModel)
        return viewController
    }
}
