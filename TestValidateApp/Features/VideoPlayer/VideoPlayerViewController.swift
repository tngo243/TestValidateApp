//
//  VideoPlayerViewController.swift
//  TestValidateApp
//
//  Created by Nguyen Nam on 11/7/25.
//

import UIKit
import Combine
import AVKit

class VideoPlayerViewController: BaseViewController {

    @IBOutlet weak var playerViewBound: UIView!
    @IBOutlet weak var informationTableView: UITableView!
    var player: HNVideoPlayer!
    private var cancellables = Set<AnyCancellable>()
    
    private var viewModel: VideoPlayerViewModel
    
    init(viewModel: VideoPlayerViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupTableView()
        bindViewModel()
    }

    override func bindViewModel() {
        viewModel.$listOtherLocalVideo
            .receive(on: DispatchQueue.main)
            .sink { [weak self] _ in
                self?.informationTableView.reloadData()
            }
            .store(in: &cancellables)
    }
    
    override func setupUI() {
        informationTableView.backgroundColor = .clear
        informationTableView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: 100, right: 0)
        
        self.player = HNVideoPlayer()
        self.player.view.frame = self.playerViewBound.bounds

        self.addChild(self.player)
        self.view.addSubview(self.player.view)
        self.player.didMove(toParent: self)
        player.view.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            player.view.leadingAnchor.constraint(equalTo: playerViewBound.leadingAnchor),
            player.view.trailingAnchor.constraint(equalTo: playerViewBound.trailingAnchor),
            player.view.topAnchor.constraint(equalTo: playerViewBound.topAnchor),
            player.view.bottomAnchor.constraint(equalTo: playerViewBound.bottomAnchor)
        ])
        self.player.view.backgroundColor = UIColor.black
    }
    
    private func setupTableView() {
        informationTableView.delegate = self
        informationTableView.dataSource = self
        
        informationTableView.register(UINib(nibName: "VideoListTableViewCell", bundle: nil), forCellReuseIdentifier: "VideoListTableViewCell")
        informationTableView.register(UINib(nibName: "InformationTableViewCell", bundle: nil), forCellReuseIdentifier: "InformationTableViewCell")
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        self.player.url = viewModel.videoData.localURL
        self.player.playFromBeginning()
    }
    
    @IBAction func backButtonTapped(_ sender: Any) {
        navigationController?.popViewController(animated: true)
    }
}

extension VideoPlayerViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.listOtherLocalVideo.count + 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if indexPath.row == 0 {
            guard let headerCell = tableView.dequeueReusableCell(withIdentifier: "InformationTableViewCell") as? InformationTableViewCell else {
                return UITableViewCell()
            }
            headerCell.configure(with: viewModel.videoData)
            return headerCell
        } else {
            guard let cell = tableView.dequeueReusableCell(withIdentifier: "VideoListTableViewCell", for: indexPath) as? VideoListTableViewCell else {
                return UITableViewCell()
            }
            
            let information = viewModel.listOtherLocalVideo[indexPath.row - 1]
            cell.configure(with: information)
            return cell
        }
    }
}
