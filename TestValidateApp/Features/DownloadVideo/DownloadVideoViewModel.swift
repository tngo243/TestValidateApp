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
        if UserDefaults.standard.isVideoDownloaded(remoteURL: url) ||
            listVideoDownloadingItem.contains(where: { $0.link == url }) {
            print("Video is already downloaded or in progress.")
            return
        }
        
        let name = "Video-\(Int(Date().timeIntervalSince1970 * 1000))"

        // Add new downloadTask to the list
        let newDownloadItem = DownloadTableCellModel(videoName: name, link: url, status: .downloading)
        listVideoDownloadingItem.append(newDownloadItem)
        delegate?.downloadVideoViewModelUpdateListItem(self)
        
        // Download video and save it
        videoDownloadManager?.downloadVideo(url: url, title: name) { result in
            switch result {
            case .success(let location):
                self.updateDownloadItemStatus(url: url, status: .completed)
                self.delegate?.downloadVideoViewModelUpdateListItem(self)
                if let bookmark = try? location.bookmarkData() {
                    let thumbnail = Helper.generateThumbnail(for: location)
                    print("-->> anhne", thumbnail != nil)
                    UserDefaults.standard.saveDownloadedVideo(remoteURL: url, localURLbookmark: bookmark, name: name, thumbnail: thumbnail)
                }
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
            .sink { [weak self] (url, percentage) in
                guard let self else { return }
                print("Download progress: \(percentage)%")
                self.updateDownloadItemStatus(url: url, percentage: percentage)
                self.delegate?.downloadVideoViewModelUpdateListItem(self)
            }.store(in: &self.disposeBag)
    }
}

// MARK: - Helper Methods
private extension DownloadVideoViewModel {
    func updateDownloadItemStatus(url: String, status: DownloadStatus = .downloading, percentage: Int = 0) {
        let model = self.listVideoDownloadingItem.first { $0.link == url }
        model?.status = status
        model?.progress = percentage
        
        self.delegate?.downloadVideoViewModelUpdateListItem(self)
    }
}
