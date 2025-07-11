//
//  VideoListViewModel.swift
//  TestValidateApp
//
//  Created by Nguyen Nam on 10/7/25.
//

import Combine

class VideoListViewModel: BaseViewModel, ObservableObject {
    @Published var listLocalVideo: [VideoListCellModel] = []
    private var videoDownloadManager: VideoDownloadManager
    
    func setVideoDownloadManager(_ videoDownloadManager: VideoDownloadManager) {
        self.videoDownloadManager = videoDownloadManager
    }
    
    private var cancellables = Set<AnyCancellable>()
    
    init(coordinator: BaseCoordinator, videoDownloadManager: VideoDownloadManager) {
        self.videoDownloadManager = videoDownloadManager
        super.init(coordinator: coordinator)
        loadVideos()
        bindDownloadManager()
    }

    private func loadVideos() {
        listLocalVideo = UserDefaults.standard.getAllDownloadedVideosMappings().map { (url, info) in
            let localURL = UserDefaults.standard.getLocalURL(for: url) ?? URL(fileURLWithPath: "")
            return VideoListCellModel(title: info.name, subtitle: url, thumbnail: nil, videoData: VideoData(name: info.name, remoteURL: url, localURL: localURL))
        }.sorted { $0.title < $1.title }
    }
    
    private func bindDownloadManager() {
        videoDownloadManager.successPublisher
            .receive(on: DispatchQueue.main)
            .sink { [weak self] url in
                guard let self = self else { return }
                if let info = UserDefaults.standard.getVideoInfo(for: url), let localURL = UserDefaults.standard.getLocalURL(for: url) {
                    listLocalVideo.append(VideoListCellModel(title: info.name, subtitle: url, thumbnail: info.thumbnail, videoData: VideoData(name: info.name, remoteURL: url, localURL: localURL)))
                }
            }
            .store(in: &cancellables)
    }

}
