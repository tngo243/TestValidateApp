//
//  VideosSavedViewController.swift
//  TestValidatedApp
//
//  Created by Luong Manh on 3/7/25.
//

import UIKit

protocol VideosSavedNavigatorType: MakeVideosSaved, MakeAlert {
    func makeViewController() -> UIViewController
}

protocol MakeVideosSaved {
    func makeVideosSaved() -> any VideosSavedNavigatorType
}

extension MakeVideosSaved {
    func makeVideosSaved() -> any VideosSavedNavigatorType {
        return VideosSavedNavigator()
    }
}

struct VideosSavedNavigator: VideosSavedNavigatorType {
    func makeViewController() -> UIViewController {
        let viewModel = VideosSavedViewModel(navigator: self)
        let viewController = VideosSavedViewController(viewModel: viewModel)
        return viewController
    }
}
