//
//  VideoPlayerViewModel.swift
//  TestValidateApp
//
//  Created by Nguyen Nam on 10/7/25.
//
import Combine

class VideoPlayerViewModel: BaseViewModel {
    @Published var listOtherLocalVideo: [VideoListCellModel] = []
    private var cancellables = Set<AnyCancellable>()
    var videoData: VideoData
    
    init(videoData: VideoData, coordinator: BaseCoordinator) {
        self.videoData = videoData
        super.init(coordinator: coordinator)
        loadVideos()
    }
    
    func moveToOtherVideo(at index: Int) {
        let model = listOtherLocalVideo[index]
        (coordinator as? VideoPlayerCoordinator)?.start(with: model.videoData)
    }
}

private extension VideoPlayerViewModel {
    func loadVideos() {
        listOtherLocalVideo = UserDefaults.standard.getAllDownloadedVideosMappings().compactMap { (url, info) in
            if url == videoData.remoteURL {
                return nil
            }
            let localURL = UserDefaults.standard.getLocalURL(for: url) ?? URL(fileURLWithPath: "")
            return VideoListCellModel(title: info.name, subtitle: url, thumbnail: nil, videoData: VideoData(name: info.name, remoteURL: url, localURL: localURL))
        }.sorted { $0.title < $1.title }
    }
}
