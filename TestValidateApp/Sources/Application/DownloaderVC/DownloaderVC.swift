//
//  DownloaderVC.swift
//  TestValidateApp
//
//  Created by Linh Phan on 2/7/25.
//

import UIKit
import AVKit
import AVFoundation

@objc class DownloaderVC: UIViewController {

    @IBOutlet weak var tfVideoURL: UITextField!
    @IBOutlet weak var btnDownload: UIButton!
    @IBOutlet weak var tbvListVideo: UITableView!
    @IBAction func btnDownloadAction(_ sender: UIButton) {
        self.downloadTapped()
    }

    // MARK: Variables

    private var downloads: [DownloadItem] = []
    private var lastProgress: [String: Double] = [:]


    // MARK: Functions
    
    private func deleteDownloadedVideo(at indexPath: IndexPath) {
        let item = downloads[indexPath.row]

        if let localURL = item.localFileURL,
           FileManager.default.fileExists(atPath: localURL.path) {
            do {
                try FileManager.default.removeItem(at: localURL)
                self.showAlert(message: "Deleted file success")
            } catch {
                self.showAlert(message: "Error deleting file: \(error)")
            }
        }

        self.downloads.remove(at: indexPath.row)
        self.tbvListVideo.deleteRows(at: [indexPath], with: .automatic)
        Userdefaults.shared.saveDownloads(self.downloads)
    }

    
    func generateThumbnail(from url: URL, at time: CMTime = CMTime(seconds: 1, preferredTimescale: 60)) -> UIImage? {
        let asset = AVAsset(url: url)
        let imageGenerator = AVAssetImageGenerator(asset: asset)
        imageGenerator.appliesPreferredTrackTransform = true

        do {
            let cgImage = try imageGenerator.copyCGImage(at: time, actualTime: nil)
            return UIImage(cgImage: cgImage)
        } catch {
            return nil
        }
    }
    
    private func playVideo(from url: URL) {
        let player = AVPlayer(url: url)
        let playerViewController = AVPlayerViewController()
        playerViewController.player = player
        self.present(playerViewController, animated: true) {
            player.play()
        }
    }


    private func downloadTapped() {
        guard let urlString = self.tfVideoURL.text,
              let url = URL(string: urlString) else { return }

        let newItem = DownloadItem(
            urlString: urlString,
            progress: 0.0,
            isCompleted: false,
            localFileURL: nil,
            thumbnailData: nil
        )
        downloads.append(newItem)

        let indexPath = IndexPath(row: downloads.count - 1, section: 0)
        tbvListVideo.insertRows(at: [indexPath], with: .automatic)

        VideoDownloader.shared.download(
            from: url,
            onProgress: { [weak self] progress in
                guard let self = self else { return }
                guard let index = self.downloads.firstIndex(where: { $0.urlString == urlString }) else { return }

                let previous = self.lastProgress[urlString] ?? 0.0
                if abs(progress - previous) >= 0.01 {
                    self.lastProgress[urlString] = progress
                    self.downloads[index].progress = progress

                    DispatchQueue.main.async {
                        if let cell = self.tbvListVideo.cellForRow(at: IndexPath(row: index, section: 0)) as? DownloadedVideoTableViewCell {
                            cell.updateProgress(progress, completed: false)
                        }
                    }
                }
            },
            onCompletion: { [weak self] localURL in
                guard let self = self,
                      let index = self.downloads.firstIndex(where: { $0.urlString == urlString }) else { return }

                guard let localURL = localURL else {
                    DispatchQueue.main.async {
                        self.showAlert(message: "Download error! Try again")
                    }

                    self.downloads.remove(at: index)
                    let indexPath = IndexPath(row: index, section: 0)
                    DispatchQueue.main.async {
                        self.tbvListVideo.deleteRows(at: [indexPath], with: .automatic)
                    }
                    return
                }

                var item = self.downloads[index]
                item.isCompleted = true
                item.localFileURL = localURL

                if let thumbnail = generateThumbnail(from: localURL) {
                    item.thumbnailData = thumbnail.jpegData(compressionQuality: 0.5)
                } else {
                    self.showAlert(message: "Thumbnail generation failed")
                }

                self.downloads[index] = item
                self.lastProgress.removeValue(forKey: urlString)
                Userdefaults.shared.saveDownloads(self.downloads)

                let indexPath = IndexPath(row: index, section: 0)
                DispatchQueue.main.async {
                    self.tbvListVideo.reloadRows(at: [indexPath], with: .none)
                }
            }

        )

        self.tfVideoURL.text = nil
    }





    func setupTableView() {
        self.tbvListVideo.backgroundColor = .clear
        self.tbvListVideo.rowHeight = UITableView.automaticDimension
        self.tbvListVideo.tableFooterView = UIView()
        self.tbvListVideo.delegate = self
        self.tbvListVideo.dataSource = self
        self.tbvListVideo.register(
            UINib(nibName: "DownloadedVideoTableViewCell", bundle: nil),
            forCellReuseIdentifier: "DownloadedVideoTableViewCell"
        )
    }

    // MARK: Life circle & overrides

    override func viewDidLoad() {
        super.viewDidLoad()
        self.hideKeyboard()
        self.setupTableView()
        self.downloads = Userdefaults.shared.loadDownloads()
        self.tbvListVideo.reloadData()
    }
}
extension DownloaderVC: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int{
        return self.downloads.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "DownloadedVideoTableViewCell", for: indexPath) as! DownloadedVideoTableViewCell
        let item = downloads[indexPath.row]
        cell.selectionStyle = .none
        cell.config(with: item)
        cell.ifCancel = { [weak self] in
            guard let self = self else {return}
            if let url = URL(string: item.urlString) {
                VideoDownloader.shared.cancelDownload(for: url)
            }
            self.downloads.remove(at: indexPath.row)
            self.tbvListVideo.deleteRows(at: [indexPath], with: .automatic)
            Userdefaults.shared.saveDownloads(self.downloads)
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let item = downloads[indexPath.row]
        if let localURL = item.localFileURL {
            playVideo(from: localURL)
        } else if let remoteURL = item.url {
            playVideo(from: remoteURL)
        }
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            deleteDownloadedVideo(at: indexPath)
        }
    }


    func tableView(_ tableView: UITableView,heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 80
    }
}
