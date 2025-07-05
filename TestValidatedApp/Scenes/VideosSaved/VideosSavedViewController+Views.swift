//
//  VideosSavedViewController.swift
//  TestValidatedApp
//
//  Created by Luong Manh on 3/7/25.
//

import UIKit

extension VideosSavedViewController: UITableViewDelegate, UITableViewDataSource {
    func setupViews() {
        view.addSubViews([
            tableView
        ])
    }
    
    func setupContrainsts() {
        tableView.fillContainer(in: view)
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return videosSaved.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell: VideosSavedCell = tableView.dequeueReuseableCell(for: indexPath)
        cell.configDataForCell(videosSaved[indexPath.row])
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 120
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let service = ObjectiveServices()
        
        let fileName = videosSaved[indexPath.row].name
        
        if service.checkExitsVideo(fileName) {
            let fileURL = FileManager.default.urls(for: .documentDirectory,
                                                   in: .userDomainMask)[0].appendingPathComponent(fileName)
            playVideo(videoURL: fileURL)
        } else {
            // Handle error when no videos founded
        }
    }
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }

    func tableView(_ tableView: UITableView,
                   commit editingStyle: UITableViewCell.EditingStyle,
                   forRowAt indexPath: IndexPath) {
        if (editingStyle == .delete) {
            viewModel.deleteVideo(videosSaved[indexPath.row])
            videosSaved.remove(at: indexPath.row)
            tableView.reloadData()
        }
    }
}
