//
//  VideosSavedViewController.swift
//  TestValidatedApp
//
//  Created by Luong Manh on 3/7/25.
//

import UIKit
import AVFoundation
import AVKit

final class VideosSavedViewController: UIViewController {
    let viewModel: VideosSavedViewModel
    
    var videosSaved: [VideoModel] = []
    
    lazy var tableView: UITableView = {
        let tableView = UITableView(frame: .zero, style: .plain)
        tableView.delegate = self
        tableView.dataSource = self
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.register(VideosSavedCell.self)
        return tableView
    }()
    
    init(viewModel: VideosSavedViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        Task {
            videosSaved = await viewModel.fetchVideo()
            tableView.reloadData()
        }
        setupViews()
        setupContrainsts()
    }
    
    func playVideo(videoURL: URL) {
        let videoPlayer = AVPlayer(url: videoURL)
        let playerViewController = AVPlayerViewController()
        playerViewController.player = videoPlayer
        self.present(playerViewController, animated: true) {
            playerViewController.player?.play()
        }
    }
}
