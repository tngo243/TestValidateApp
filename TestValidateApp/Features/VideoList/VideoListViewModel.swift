//
//  VideoListViewModel.swift
//  TestValidateApp
//
//  Created by Nguyen Nam on 10/7/25.
//

import Combine

class VideoListViewModel: BaseViewModel, ObservableObject {
    @Published var listLocalVideo: [VideoListCellModel] = []
    
    private var cancellables = Set<AnyCancellable>()
    
    override init(coordinator: BaseCoordinator) {
        super.init(coordinator: coordinator)
        loadVideos()
    }

    func loadVideos() {
        listLocalVideo = UserDefaults.standard.getAllDownloadedVideosMappings().map { (url, info) in
            let localURL = UserDefaults.standard.getLocalURL(for: url) ?? URL(fileURLWithPath: "")
            return VideoListCellModel(title: info.name, subtitle: url, thumbnail: nil, videoData: VideoData(name: info.name, remoteURL: url, localURL: localURL))
        }.sorted { $0.title < $1.title }
    }

}
