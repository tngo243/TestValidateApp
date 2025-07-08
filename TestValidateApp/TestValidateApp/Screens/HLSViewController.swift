//
//  HLSViewController.swift
//  TestValidateApp
//
//  Created by Thien Tung on 7/7/25.
//

import UIKit
import Foundation
import AVKit
import AVFoundation

class HLSViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {

    private let statusLabel = UILabel()
    private let downloadButton = UIButton(type: .system)
    private let cancelButton = UIButton(type: .system)
    private let progressView = UIProgressView(progressViewStyle: .default)
    private let fileTableView = UITableView()
    
    // Properties
    private let masterM3U8URL = "https://demo.unified-streaming.com/k8s/features/stable/video/tears-of-steel/tears-of-steel.ism/.m3u8"
    private let outputDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!.appendingPathComponent("hls_download")
    private var videoPaths: [String] = []
    private var urlSession: URLSession!
    private var downloadTasks: [URLSessionDataTask] = []
    private var totalSegments: Int = 0
    private var downloadedSegments: Int = 0
    
    private let videoPathsKey = "savedVideoPaths"
    
    private let clearOutputDirectoryBeforeDownload = false
    
    struct HLSVariant {
        let bandwidth: Int
        let resolution: String?
        let url: String
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupURLSession()
        loadSavedVideoPaths()
    }
    
    private func setupUI() {
        view.backgroundColor = .white
        
        statusLabel.text = "Nhấn nút để tải video HLS"
        statusLabel.numberOfLines = 0
        statusLabel.textAlignment = .center
        statusLabel.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(statusLabel)
        
        downloadButton.setTitle("Tải Video", for: .normal)
        downloadButton.addTarget(self, action: #selector(startDownload), for: .touchUpInside)
        downloadButton.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(downloadButton)
        
        cancelButton.setTitle("Hủy", for: .normal)
        cancelButton.addTarget(self, action: #selector(cancelDownload), for: .touchUpInside)
        cancelButton.isEnabled = false
        cancelButton.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(cancelButton)
        
        progressView.progress = 0.0
        progressView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(progressView)
        
        fileTableView.dataSource = self
        fileTableView.delegate = self
        fileTableView.register(UITableViewCell.self, forCellReuseIdentifier: "FileCell")
        fileTableView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(fileTableView)
        
        NSLayoutConstraint.activate([
            statusLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 20),
            statusLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            statusLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            
            downloadButton.centerXAnchor.constraint(equalTo: view.centerXAnchor, constant: -50),
            downloadButton.topAnchor.constraint(equalTo: statusLabel.bottomAnchor, constant: 20),
            
            cancelButton.centerXAnchor.constraint(equalTo: view.centerXAnchor, constant: 50),
            cancelButton.topAnchor.constraint(equalTo: statusLabel.bottomAnchor, constant: 20),
            
            progressView.topAnchor.constraint(equalTo: downloadButton.bottomAnchor, constant: 20),
            progressView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            progressView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            
            fileTableView.topAnchor.constraint(equalTo: progressView.bottomAnchor, constant: 20),
            fileTableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            fileTableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            fileTableView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor)
        ])
    }
    
    private func setupURLSession() {
        let configuration = URLSessionConfiguration.default
        urlSession = URLSession(configuration: configuration)
    }
    
    private func loadSavedVideoPaths() {
        let fileManager = FileManager.default
        if let savedPaths = UserDefaults.standard.stringArray(forKey: videoPathsKey) {
            // Filter paths to ensure files still exist
            videoPaths = savedPaths.filter { fileManager.fileExists(atPath: $0) }
            fileTableView.reloadData()
        }
    }
    
    private func saveVideoPaths() {
        UserDefaults.standard.set(videoPaths, forKey: videoPathsKey)
    }
    
    private func createOutputDirectory() throws {
        let fileManager = FileManager.default
        if clearOutputDirectoryBeforeDownload && fileManager.fileExists(atPath: outputDirectory.path) {
            try fileManager.removeItem(at: outputDirectory)
        }
        if !fileManager.fileExists(atPath: outputDirectory.path) {
            try fileManager.createDirectory(at: outputDirectory, withIntermediateDirectories: true, attributes: nil)
        }
    }
    
    private func parseMasterM3U8(content: String, baseURL: String) -> [HLSVariant] {
        var variants: [HLSVariant] = []
        let lines = content.components(separatedBy: .newlines)
        var currentBandwidth: Int?
        var currentResolution: String?
        
        for line in lines {
            if line.contains("#EXT-X-STREAM-INF") {
                let attributes = line.components(separatedBy: ",")
                for attr in attributes {
                    if attr.contains("BANDWIDTH=") {
                        if let bandwidthStr = attr.split(separator: "=").last {
                            currentBandwidth = Int(bandwidthStr)
                        }
                    }
                    if attr.contains("RESOLUTION=") {
                        currentResolution = attr.split(separator: "=").last?.description
                    }
                }
            } else if !line.hasPrefix("#") && !line.isEmpty && currentBandwidth != nil {
                let variantURL = line.hasPrefix("http") ? line : baseURL + "/" + line
                let variant = HLSVariant(bandwidth: currentBandwidth!, resolution: currentResolution, url: variantURL)
                variants.append(variant)
                currentBandwidth = nil
                currentResolution = nil
            }
        }
        return variants
    }
    
    private func parseMediaM3U8(content: String, baseURL: String) -> [String] {
        var segments: [String] = []
        let lines = content.components(separatedBy: .newlines)
        
        for line in lines {
            if !line.hasPrefix("#") && !line.isEmpty {
                let segmentURL = line.hasPrefix("http") ? line : baseURL + "/" + line
                segments.append(segmentURL)
            }
        }
        return segments
    }
    
    private func downloadSegments(_ segmentURLs: [String], to directory: URL, prefix: String) async throws -> [String] {
        var localPaths: [String] = []
        totalSegments = segmentURLs.count
        downloadedSegments = 0
        downloadTasks.removeAll()
        
        for (index, segmentURL) in segmentURLs.enumerated() {
            guard let url = URL(string: segmentURL) else {
                print("Lỗi: URL không hợp lệ cho đoạn \(index): \(segmentURL)")
                continue
            }
            let destinationURL = directory.appendingPathComponent("\(prefix)_\(index).ts")
            let localPath = destinationURL.path
            
            if FileManager.default.fileExists(atPath: localPath) {
                localPaths.append(localPath)
                downloadedSegments += 1
                
                let progress = Float(downloadedSegments) / Float(totalSegments)
                let percentage = Int(progress * 100)
                await MainActor.run {
                    progressView.setProgress(progress, animated: true)
                    statusLabel.text = "Đang tải: \(percentage)%"
                }
                continue
            }

            do {
                try FileManager.default.createDirectory(at: directory, withIntermediateDirectories: true, attributes: nil)
            } catch {
                print("Lỗi: Không thể tạo thư mục đích \(directory.path): \(error.localizedDescription)")
                continue
            }

            let task = urlSession.dataTask(with: url)
            downloadTasks.append(task)
            task.resume()
            
            do {
                let (data, _) = try await urlSession.data(from: url)

                do {
                    try data.write(to: destinationURL)
                    localPaths.append(localPath)
                    downloadedSegments += 1
                    
                    let progress = Float(downloadedSegments) / Float(totalSegments)
                    let percentage = Int(progress * 100)
                    await MainActor.run {
                        progressView.setProgress(progress, animated: true)
                        statusLabel.text = "Đang tải: \(percentage)%"
                    }
                } catch {
                    print("Lỗi ghi file đoạn \(index) vào \(localPath): \(error.localizedDescription)")
                }
            } catch {
                if error is URLError && (error as NSError).code == URLError.cancelled.rawValue {
                    throw error // Propagate cancellation error
                }
                print("Lỗi tải đoạn \(index) từ \(segmentURL): \(error.localizedDescription)")
            }
        }
        
        downloadTasks.removeAll()
        return localPaths
    }
    
    private func mergeTSFiles(_ tsPaths: [String], to outputURL: URL) async throws {
        let fileManager = FileManager.default
        let composition = AVMutableComposition()
        
        for path in tsPaths {
            let asset = AVURLAsset(url: URL(fileURLWithPath: path))
            guard let videoTrack = try await asset.loadTracks(withMediaType: .video).first else {
                print("Lỗi: Không tìm thấy video track trong file \(path)")
                continue
            }
            
            let compositionTrack = composition.addMutableTrack(withMediaType: .video, preferredTrackID: kCMPersistentTrackID_Invalid)
            try await compositionTrack?.insertTimeRange(CMTimeRange(start: .zero, duration: asset.load(.duration)), of: videoTrack, at: .zero)
        }
        
        guard let exporter = AVAssetExportSession(asset: composition, presetName: AVAssetExportPresetPassthrough) else {
            throw NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "Không thể tạo AVAssetExportSession"])
        }
        
        exporter.outputURL = outputURL
        exporter.outputFileType = .mp4
        exporter.shouldOptimizeForNetworkUse = true
        
        await exporter.export()
        
        if let error = exporter.error {
            throw error
        }
        
        guard fileManager.fileExists(atPath: outputURL.path) else {
            throw NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "File gộp không được tạo"])
        }
    }
    
    @objc private func startDownload() {
        statusLabel.text = "Đang tải: 0%"
        downloadButton.isEnabled = false
        cancelButton.isEnabled = true
        progressView.progress = 0.0
        videoPaths.removeAll()
        fileTableView.reloadData()
        
        Task {
            do {
                try await downloadHLS()
                saveVideoPaths()
                await MainActor.run {
                    statusLabel.text = """
                    Tải xuống hoàn tất!
                    Các đoạn video đã được lưu tại:
                    \(outputDirectory.path)
                    """
                    downloadButton.isEnabled = true
                    cancelButton.isEnabled = false
                    fileTableView.reloadData()
                }
            } catch {
                await MainActor.run {
                    if (error as NSError).code == URLError.cancelled.rawValue {
                        statusLabel.text = "Đã hủy tải xuống. Nhấn 'Tải Video' để thử lại."
                    } else {
                        statusLabel.text = "Lỗi: \(error.localizedDescription)"
                    }
                    downloadButton.isEnabled = true
                    cancelButton.isEnabled = false
                    progressView.progress = 0.0
                }
            }
        }
    }
    
    @objc private func cancelDownload() {
        downloadTasks.forEach { $0.cancel() }
        downloadTasks.removeAll()
        Task {
            await MainActor.run {
                statusLabel.text = "Đã hủy tải xuống. Nhấn 'Tải Video' để thử lại."
                downloadButton.isEnabled = true
                cancelButton.isEnabled = false
                progressView.progress = 0.0
            }
        }
    }
    
    private func downloadHLS() async throws {
        try createOutputDirectory()
        
        guard let masterURL = URL(string: masterM3U8URL) else {
            throw NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "Invalid master URL"])
        }
        let baseURL = masterURL.deletingLastPathComponent().absoluteString
        let (masterData, _) = try await URLSession.shared.data(from: masterURL)
        guard let masterContent = String(data: masterData, encoding: .utf8) else {
            throw NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "Failed to decode master playlist"])
        }
        
        let variants = parseMasterM3U8(content: masterContent, baseURL: baseURL)
        guard let selectedVariant = variants.filter({ $0.resolution != nil }).sorted(by: { $0.bandwidth > $1.bandwidth }).first else {
            throw NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "No video variants found"])
        }
        
        guard let mediaURL = URL(string: selectedVariant.url) else {
            throw NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "Invalid media URL"])
        }
        let (mediaData, _) = try await URLSession.shared.data(from: mediaURL)
        guard let mediaContent = String(data: mediaData, encoding: .utf8) else {
            throw NSError(domain: "", code: -1, userInfo: [NSLocalizedDescriptionKey: "Failed to decode media playlist"])
        }
        
        let segmentURLs = parseMediaM3U8(content: mediaContent, baseURL: baseURL)
        videoPaths = try await downloadSegments(segmentURLs, to: outputDirectory, prefix: "video")
        
        print(" Tải xuống hoàn tất! Các đoạn video đã được lưu tại: \(outputDirectory.path)")
    }
    
    // MARK: - UITableViewDataSource
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return videoPaths.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "FileCell", for: indexPath)
        let filePath = videoPaths[indexPath.row]
        cell.textLabel?.text = "Video: \(URL(fileURLWithPath: filePath).lastPathComponent)"
        return cell
    }
    
    // MARK: - UITableViewDelegate
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let filePath = videoPaths[indexPath.row]
        
        guard FileManager.default.fileExists(atPath: filePath) else {
            print("Lỗi: File không tồn tại tại \(filePath)")
            statusLabel.text = "Lỗi: File video không tồn tại"
            return
        }
        
        do {
            let attributes = try FileManager.default.attributesOfItem(atPath: filePath)
            if let fileSize = attributes[.size] as? Int64, fileSize == 0 {
                print("Lỗi: File \(filePath) có kích thước 0 bytes")
                statusLabel.text = "Lỗi: File video rỗng"
                return
            }
        } catch {
            print("Lỗi: Không thể lấy thông tin file \(filePath): \(error.localizedDescription)")
            statusLabel.text = "Lỗi: Không thể kiểm tra file video"
            return
        }
        
        let mergedURL = outputDirectory.appendingPathComponent("merged_video.ts")
        Task {
            do {
                try await mergeTSFiles(videoPaths, to: mergedURL)
                await MainActor.run {
                    // Play merged file
                    let player = AVPlayer(url: mergedURL)
                    let playerVC = AVPlayerViewController()
                    playerVC.player = player
                    present(playerVC, animated: true) {
                        player.play()
                    }
                }
            } catch {
                print("Lỗi gộp file .ts: \(error.localizedDescription)")
                await MainActor.run {
                    statusLabel.text = "Lỗi: Không thể phát video do lỗi gộp file"
                }
            }
        }
    }
}
