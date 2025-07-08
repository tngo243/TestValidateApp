//
//  DownloadingVideoViewController.swift
//  TestValidateApp
//
//  Created by Thien Tung on 2/7/25.
//

import UIKit
import AVKit

class DownloadingVideoViewController: UIViewController {

    @IBOutlet weak var typeTextField: UITextField!
    @IBOutlet weak var tableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = "Tải Video"
        configTableView()
        setupDownloadManager()
    }
    
    private func configTableView() {
        tableView.dataSource = self
        tableView.delegate = self
        tableView.register(UINib(nibName: "DownloadVideoTableViewCell", bundle: nil), forCellReuseIdentifier: "VideoTableCell")
    }
    
    private func setupDownloadManager() {
        DownloadManager.shared.onProgressUpdate = { [weak self] urlVideo, progress in
            if let index = DownloadManager.shared.getVideosDownloading().firstIndex(where: { $0.url == urlVideo }) {
                if let cell = self?.tableView.cellForRow(at: IndexPath(row: index, section: 0)) as? DownloadVideoTableViewCell {
                    cell.setProgress(progress)
                }
            }
        }
        
        DownloadManager.shared.onDownloadComplete = { [weak self] video in
            self?.tableView.reloadData()
        }
        
        DownloadManager.shared.onDownloadError = { [weak self] video, error in
            guard let self = self else { return }
            DispatchQueue.main.async {
                if error.localizedDescription ==  "Mất kết nối internet" {
                    self.showAlert(message: error.localizedDescription,
                                   actionName: "Thử lại") {
                        DownloadManager.shared.resumeDownloads()
                    }
                } else {
                    self.showAlert(message: "Lỗi tải xuống: \(error.localizedDescription)")
                    self.tableView.reloadData()
                }
            }
        }
    }

    @IBAction func actionDownload(_ sender: UIButton) {
        guard let urlString = typeTextField.text,
                let url = URL(string: urlString), url.scheme != nil else {
            showAlert(message: "URL không hợp lệ")
            return
        }
        DownloadManager.shared.downloadVideo(from: url)
        tableView.reloadData()
        typeTextField.text = ""
    }
}

// MARK: - UITableViewDelegate
extension DownloadingVideoViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        showAlert(message: "Chờ tới khi tải xong để xem video.")
    }
}

// MARK: - UITableViewDataSource
extension DownloadingVideoViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return DownloadManager.shared.getVideosDownloading().count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "VideoTableCell", for: indexPath) as! DownloadVideoTableViewCell
        let video = DownloadManager.shared.getVideosDownloading()[indexPath.row]
        cell.configure(with: video) { [weak self] in
            DownloadManager.shared.cancelDownload(for: video.url)
            self?.tableView.reloadData()
        }
        return cell
    }
    
}
