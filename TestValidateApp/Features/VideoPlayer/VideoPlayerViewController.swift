//
//  VideoPlayerViewController.swift
//  TestValidateApp
//
//  Created by Nguyen Nam on 10/7/25.
//

import UIKit

class VideoPlayerViewController: BaseViewController {
    var viewModel: VideoPlayerViewModel!
    
    init(viewModel: VideoPlayerViewModel!) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
