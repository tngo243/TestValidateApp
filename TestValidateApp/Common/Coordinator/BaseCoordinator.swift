//
//  BaseCoordinator.swift
//  TestValidateApp
//
//  Created by Nguyen Nam on 10/7/25.
//

import UIKit

protocol BaseCoordinator: AnyObject {
    var navigationController: UINavigationController { get set }
    var childCoordinators: [BaseCoordinator] { get set }
    
    func start()
    func addChild(_ coordinator: BaseCoordinator)
    func removeChild(_ coordinator: BaseCoordinator)
}

extension BaseCoordinator {
    func addChild(_ coordinator: BaseCoordinator) {
        childCoordinators.append(coordinator)
    }
    
    func removeChild(_ coordinator: BaseCoordinator) {
        childCoordinators.removeAll { $0 === coordinator }
    }
}
