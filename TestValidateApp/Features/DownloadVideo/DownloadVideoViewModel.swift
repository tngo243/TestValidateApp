//
//  DownloadVideoViewModel.swift
//  TestValidateApp
//
//  Created by Nguyen Nam on 10/7/25.
//

import Foundation

@objc protocol DownloadVideoViewModelDelegate: AnyObject {
    @objc func downloadVideoViewModelUpdateListItem(_ viewModel: DownloadVideoViewModel)
    @objc func downloadVideoViewModel(_ viewModel: DownloadVideoViewModel, didFinishWithSuccess success: Bool)
//    func userListViewModel(_ viewModel: DownloadVideoViewModel, didFailWithError error: NSError)
}

protocol DownloadVideoViewModelInput {
    func downloadVideo(url: String)
    func getListVideoDownloadingItem() -> [DownloadTableCellModel]
    func viewDidLoad()
}

@objc class DownloadVideoViewModel: BaseViewModel {
    @objc weak var delegate: DownloadVideoViewModelDelegate?
    private var videoDownloadManager: VideoDownloadManager?
    private var listVideoDownloadingItem = [DownloadTableCellModel]()
    
    @objc func setVideoDownloadManager(_ videoDownloadManager: VideoDownloadManager) {
        self.videoDownloadManager = videoDownloadManager
    }
}

@objc extension DownloadVideoViewModel: DownloadVideoViewModelInput {
    @objc func getListVideoDownloadingItem() -> [DownloadTableCellModel] {
        return listVideoDownloadingItem
    }
    
    @objc func downloadVideo(url: String) {
        let name = "Video-\(Int(Date().timeIntervalSince1970 * 1000))"

        // Add new downloadTask to the list
        let newDownloadItem = DownloadTableCellModel(videoName: name, link: url, status: .downloading)
        listVideoDownloadingItem.append(newDownloadItem)
        delegate?.downloadVideoViewModelUpdateListItem(self)
        
        videoDownloadManager?.downloadVideo(url: url, title: name) { result in
            switch result {
            case .success(let location):
                print("Download completed successfully: \(location)")
//                statusLabel.text = "Tải xuống thành công"
//                
//                // Use the downloaded video
//                useDownloadedVideo(at: location)
                
            case .failure(let error):
                print("Download failed: \(error.localizedDescription)")
//                statusLabel.text = "Lỗi: \(error.localizedDescription)"
//                
//                // Handle specific errors
//                handleDownloadError(error)
            }
        }
    }
    
    @objc func viewDidLoad() {
        self.videoDownloadManager?.progressPublisher
            .receive(on: DispatchQueue.main)
            .sink { [weak self] (url, percentage) in
                guard let self else { return }
                self.listVideoDownloadingItem.forEach { model in
                    print(model.link)
                }
                let model = self.listVideoDownloadingItem.first { $0.link == url }
                model?.status = .downloading
                model?.progress = percentage
                
                self.delegate?.downloadVideoViewModelUpdateListItem(self)
            }.store(in: &self.disposeBag)
    }
}
