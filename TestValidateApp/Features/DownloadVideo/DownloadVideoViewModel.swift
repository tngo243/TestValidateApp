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
    private let networkMonitor = NetworkConditionMonitor.shared

    @objc func setVideoDownloadManager(_ videoDownloadManager: VideoDownloadManager) {
        self.videoDownloadManager = videoDownloadManager
    }
}

@objc extension DownloadVideoViewModel: DownloadVideoViewModelInput {
    @objc func getListVideoDownloadingItem() -> [DownloadTableCellModel] {
        return listVideoDownloadingItem
    }
    
    @objc func downloadVideo(url: String) {
        let url = url.trimmingCharacters(in: .whitespacesAndNewlines)
        guard verifyUrl(urlString: url) else {
            DispatchQueue.main.async {
                Helpers.showAlert(title: "Invalid URL", message: "Please check your URL and try again.")
            }
            return
        }
        if !Helpers.isConnectedToNetwork() {
            DispatchQueue.main.async {
                Helpers.showAlert(title: "No Internet Connection", message: "Please check your internet connection and try again.")
            }
            return
        }
        
        if UserDefaults.standard.isVideoDownloaded(remoteURL: url) {
            DispatchQueue.main.async {
                Helpers.showAlert(title: "Video Already Downloaded", message: "This video has already been downloaded.")
            }
            return
        }
        
        if let item = listVideoDownloadingItem.first(where: { $0.link == url }),
           item.status == .downloading || item.status == .completed {
            DispatchQueue.main.async {
                Helpers.showAlert(title: "Video Downloading", message: "This video is already being downloaded.")
            }
            return
        }
        
        let name = "Video-\(Int(Date().timeIntervalSince1970 * 1000))"

        // Add new downloadTask to the list
        let newDownloadItem = DownloadTableCellModel(videoName: name, link: url, status: .downloading)
        listVideoDownloadingItem.append(newDownloadItem)
        delegate?.downloadVideoViewModelUpdateListItem(self)
        
        // Download video and save it
        videoDownloadManager?.downloadVideo(url: url, title: name) { [weak self] result in
            switch result {
            case .success(let location):
                if let bookmark = try? location.bookmarkData() {
                    UserDefaults.standard.saveDownloadedVideo(remoteURL: url, localURLbookmark: bookmark, name: name)
                }
                if let self {
                    self.updateDownloadItemStatus(url: url, status: .completed)
                    self.delegate?.downloadVideoViewModelUpdateListItem(self)
                }
            case .failure(let error):
                self?.updateDownloadItemStatus(url: url, status: .failed, error: error)
                DispatchQueue.main.async {
                    Helpers.showAlert(title: "Download Failed", message: error.localizedDescription)
                }
            }
        }
    }
    
    @objc func viewDidLoad() {
        self.videoDownloadManager?.progressPublisher
            .sink { [weak self] (url, percentage) in
                guard let self else { return }
                self.updateDownloadItemStatus(url: url, percentage: percentage)
                self.delegate?.downloadVideoViewModelUpdateListItem(self)
            }.store(in: &self.disposeBag)
        
        self.videoDownloadManager?.cancelPublisher
            .sink { [weak self] (url) in
                guard let self else { return }
                self.updateDownloadItemStatus(url: url, status: .cancelled)
                self.delegate?.downloadVideoViewModelUpdateListItem(self)
            }.store(in: &self.disposeBag)
        
        self.networkMonitor.onNetworkUnavailable
            .sink { _ in
                self.videoDownloadManager?.cancelAllDownloads()
            }
            .store(in: &disposeBag)

    }
}

// MARK: - Helper Methods
private extension DownloadVideoViewModel {
    func updateDownloadItemStatus(url: String, status: DownloadStatus = .downloading, percentage: Int = 0, error: VideoDownloadManager.DownloadError? = nil) {
        let model = self.listVideoDownloadingItem.first { $0.link == url && $0.status == .downloading }
        model?.status = status
        model?.progress = percentage
        model?.errorMessage = error?.localizedDescription
        
        self.delegate?.downloadVideoViewModelUpdateListItem(self)
    }
    
    func verifyUrl(urlString: String?) -> Bool {
        if let urlString = urlString {
            if let url = URL(string: urlString) {
                return UIApplication.shared.canOpenURL(url as URL)
            }
        }
        return false
    }

}
