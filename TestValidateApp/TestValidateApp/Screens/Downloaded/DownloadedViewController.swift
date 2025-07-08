//
//  DownloadedViewController.swift
//  TestValidateApp
//
//  Created by Thien Tung on 2/7/25.
//

import UIKit
import AVKit

class DownloadedViewController: UIViewController {
    
    @IBOutlet weak var tableView: UITableView!
    
    private var arrFiles: [URL] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = "Video Đã Tải"
        configTableView()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        loadVideosOffline()
    }
    
    private func loadVideosOffline() {
        let fileManager = FileManager.default
        let documentsURL = fileManager.getDocumentsDirectory()
        
        do {
            arrFiles = try fileManager.contentsOfDirectory(at: documentsURL, includingPropertiesForKeys: nil)
            tableView.reloadData()
        } catch {
            showAlert(message: error.localizedDescription)
        }
    }
    
    private func configTableView() {
        tableView.dataSource = self
        tableView.delegate = self
        tableView.register(UINib(nibName: "DownloadedTableViewCell", bundle: nil), forCellReuseIdentifier: "DownloadedTableViewCell")
    }
    
}
// MARK: - UITableViewDelegate
extension DownloadedViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let player = AVPlayer(url: arrFiles[indexPath.row])
        let playerVC = AVPlayerViewController()
        playerVC.player = player
        present(playerVC, animated: true) {
            player.play()
        }
    }
}
// MARK: - UITableViewDataSource
extension DownloadedViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return arrFiles.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "DownloadedTableViewCell", for: indexPath) as! DownloadedTableViewCell
        cell.bindData(arrFiles[indexPath.row])
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        100
    }
    
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let deleteAction = UIContextualAction(style: .destructive, title: "Delete") { [weak self] (_, _, completionHandler) in
            guard let self = self else {
                completionHandler(false)
                return }
            do {
                let fileURL = arrFiles[indexPath.row]
                if FileManager.default.fileExists(atPath: fileURL.path) {
                    try FileManager.default.removeItem(at: fileURL)
                }
                self.arrFiles.remove(at: indexPath.row)
                tableView.deleteRows(at: [indexPath], with: .automatic)
                completionHandler(true)
            } catch {
                showAlert(message: error.localizedDescription)
                completionHandler(false)
            }
        }
        
        let UISwipeActionsConfiguration = UISwipeActionsConfiguration(actions: [deleteAction])
        return UISwipeActionsConfiguration
    }
}
