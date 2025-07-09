//
//  BaseViewModel.swift
//  TestValidateApp
//
//  Created by Nguyen Nam on 10/7/25.
//

import ObjectiveC

protocol BaseViewModelProtocol {
    var coordinator: BaseCoordinator? { get set }
}

class BaseViewModel: NSObject, BaseViewModelProtocol {
    weak var coordinator: BaseCoordinator?
    
    init(coordinator: BaseCoordinator) {
        self.coordinator = coordinator
    }
}
