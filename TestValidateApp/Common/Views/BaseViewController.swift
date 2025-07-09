//
//  BaseViewController.swift
//  TestValidateApp
//
//  Created by Nguyen Nam on 10/7/25.
//

import UIKit

// MARK: - Base View Controller
class BaseViewController: UIViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        bindViewModel()
    }
    
    func setupUI() {}
    
    func bindViewModel() {}
}
