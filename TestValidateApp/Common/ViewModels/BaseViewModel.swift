//
//  BaseViewModel.swift
//  TestValidateApp
//
//  Created by Nguyen Nam on 10/7/25.
//

import ObjectiveC
import Combine

protocol BaseViewModelProtocol {
    var coordinator: BaseCoordinator? { get set }
}

class BaseViewModel: NSObject, BaseViewModelProtocol {
    weak var coordinator: BaseCoordinator?
    var disposeBag = Set<AnyCancellable>()
    
    init(coordinator: BaseCoordinator) {
        self.coordinator = coordinator
    }
}
