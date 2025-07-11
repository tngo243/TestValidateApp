//
//  VideoListViewController.swift
//  TestValidateApp
//
//  Created by Nguyen Nam on 10/7/25.
//

import UIKit
import Combine

class VideoListViewController: BaseViewController {
    @IBOutlet weak var wrapTableView: UIView!
    @IBOutlet weak var videoListTableView: UITableView!
    
    private var viewModel: VideoListViewModel!
    private var cancellables = Set<AnyCancellable>()
    
    init(viewModel: VideoListViewModel!) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setUpTableView()
        bindViewModel()
    }
    
    override func setupUI() {
        wrapTableView.roundCorners(corners: [.layerMinXMinYCorner, .layerMaxXMinYCorner], radius: 16)
    }
    
    override func bindViewModel() {
        viewModel.$listLocalVideo
            .receive(on: DispatchQueue.main)
            .sink { [weak self] _ in
                self?.videoListTableView.reloadData()
            }
            .store(in: &cancellables)
    }
    
    private func setUpTableView() {
        videoListTableView.delegate = self
        videoListTableView.dataSource = self
        videoListTableView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: 100, right: 0)
        videoListTableView.register(UINib(nibName: "VideoListTableViewCell", bundle: nil), forCellReuseIdentifier: "VideoListTableViewCell")
        videoListTableView.estimatedRowHeight = 100
    }
}

extension VideoListViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.listLocalVideo.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "VideoListTableViewCell", for: indexPath) as? VideoListTableViewCell else {
            return UITableViewCell()
        }
        
        let user = viewModel.listLocalVideo[indexPath.row]
        cell.configure(with: user)
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let selectedItem = viewModel.listLocalVideo[indexPath.row]
        (self.viewModel.coordinator as? VideoListCoordinator)?.showVideoPlayer(with: selectedItem.videoData)
    }
    
}
