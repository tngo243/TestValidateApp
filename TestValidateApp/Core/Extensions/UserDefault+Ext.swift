//
//  UserDefault+Ext.swift
//  TestValidateApp
//
//  Created by Nguyen Nam on 10/7/25.
//
import Foundation

// MARK: - Video Info Model
struct VideoInfo: Codable {
    let localURLbookmark: Data
    let name: String
    let thumbnailData: Data?
    
    init(localURLbookmark: Data, name: String, thumbnail: UIImage? = nil) {
        self.localURLbookmark = localURLbookmark
        self.name = name
        self.thumbnailData = thumbnail?.jpegData(compressionQuality: 0.8)
    }
    
    // Computed property để lấy UIImage từ thumbnailData
    var thumbnail: UIImage? {
        guard let thumbnailData = thumbnailData else { return nil }
        return UIImage(data: thumbnailData)
    }
}

// MARK: - UserDefaults Extension for URL Mapping
extension UserDefaults {
    
    // MARK: - Constants
    private struct Keys {
        static let downloadedVideosKey = "downloaded_videos_mapping"
    }
    
    // MARK: - Save URL Mapping
    /// Lưu mapping giữa remote URL, local URL bookmark, tên file và thumbnail
    /// - Parameters:
    ///   - remoteURL: URL gốc (ví dụ: "http://samplevideo.rst/.m3u8")
    ///   - localURLbookmark: Bookmark data của local file đã download
    ///   - name: Tên file do user truyền vào
    ///   - thumbnail: UIImage thumbnail (optional)
    func saveDownloadedVideo(remoteURL: String, localURLbookmark: Data, name: String, thumbnail: UIImage? = nil) {
        var mappings = getDownloadedVideosMappings()
        let videoInfo = VideoInfo(localURLbookmark: localURLbookmark, name: name, thumbnail: thumbnail)
        
        if let data = try? JSONEncoder().encode(videoInfo) {
            mappings[remoteURL] = data
        }
        
        set(mappings, forKey: Keys.downloadedVideosKey)
        synchronize()
    }
    
    // MARK: - Get Local URL
    /// Lấy local URL từ remote URL bằng cách resolve bookmark
    /// - Parameter remoteURL: URL gốc
    /// - Returns: Local URL nếu có và resolve thành công, nil nếu chưa download hoặc resolve fail
    func getLocalURL(for remoteURL: String) -> URL? {
        guard let videoInfo = getVideoInfo(for: remoteURL) else { return nil }
        
        var bookmarkDataIsStale = false
        let localURL = try? URL(resolvingBookmarkData: videoInfo.localURLbookmark, bookmarkDataIsStale: &bookmarkDataIsStale)
        
        if bookmarkDataIsStale {
            fatalError("Bookmark data is stale!")
        }
        
        guard let url = localURL else {
            print("Failed to resolve bookmark data")
            return nil
        }
        
        return url
    }
    
    // MARK: - Get Video Name
    /// Lấy tên video từ remote URL
    /// - Parameter remoteURL: URL gốc
    /// - Returns: Tên video nếu có, nil nếu chưa download
    func getVideoName(for remoteURL: String) -> String? {
        return getVideoInfo(for: remoteURL)?.name
    }
    
    // MARK: - Get Video Thumbnail
    /// Lấy thumbnail video từ remote URL
    /// - Parameter remoteURL: URL gốc
    /// - Returns: UIImage thumbnail nếu có, nil nếu chưa download hoặc không có thumbnail
    func getVideoThumbnail(for remoteURL: String) -> UIImage? {
        return getVideoInfo(for: remoteURL)?.thumbnail
    }
    
    // MARK: - Get Video Info
    /// Lấy thông tin video (local URL bookmark + name + thumbnail) từ remote URL
    /// - Parameter remoteURL: URL gốc
    /// - Returns: VideoInfo nếu có, nil nếu chưa download
    func getVideoInfo(for remoteURL: String) -> VideoInfo? {
        let mappings = getDownloadedVideosMappings()
        guard let data = mappings[remoteURL],
              let videoInfo = try? JSONDecoder().decode(VideoInfo.self, from: data) else {
            return nil
        }
        return videoInfo
    }
    
    // MARK: - Check if Downloaded
    /// Kiểm tra xem URL đã được download chưa
    /// - Parameter remoteURL: URL gốc
    /// - Returns: true nếu đã download, false nếu chưa
    func isVideoDownloaded(remoteURL: String) -> Bool {
        let mappings = getDownloadedVideosMappings()
        return mappings[remoteURL] != nil
    }
    
    // MARK: - Remove Mapping
    /// Xóa mapping của một URL
    /// - Parameter remoteURL: URL gốc cần xóa
    func removeDownloadedVideo(remoteURL: String) {
        var mappings = getDownloadedVideosMappings()
        mappings.removeValue(forKey: remoteURL)
        
        set(mappings, forKey: Keys.downloadedVideosKey)
        synchronize()
    }
    
    // MARK: - Get All Mappings
    /// Lấy tất cả mappings đã lưu
    /// - Returns: Dictionary chứa tất cả mappings với VideoInfo
    func getAllDownloadedVideosMappings() -> [String: VideoInfo] {
        let mappings = getDownloadedVideosMappings()
        var result: [String: VideoInfo] = [:]
        
        for (remoteURL, data) in mappings {
            if let videoInfo = try? JSONDecoder().decode(VideoInfo.self, from: data) {
                result[remoteURL] = videoInfo
            }
        }
        
        return result
    }
    
    // MARK: - Clear All Mappings
    /// Xóa tất cả mappings
    func clearAllDownloadedVideos() {
        removeObject(forKey: Keys.downloadedVideosKey)
        synchronize()
    }
    
    // MARK: - Get Downloaded Videos Count
    /// Lấy số lượng video đã download
    /// - Returns: Số lượng video đã download
    func getDownloadedVideosCount() -> Int {
        return getDownloadedVideosMappings().count
    }
    
    // MARK: - Private Helper Methods
    private func getDownloadedVideosMappings() -> [String: Data] {
        return dictionary(forKey: Keys.downloadedVideosKey) as? [String: Data] ?? [:]
    }
}

// MARK: - Usage Examples
/*
// Cách sử dụng:

// 1. Lưu mapping sau khi download (bây giờ có thêm name)
let remoteURL = "http://samplevideo.rst/.m3u8"
let localURL = URL(fileURLWithPath: "/path/to/local/video.m3u8")
let videoName = "Sample Video Tutorial"
UserDefaults.standard.saveDownloadedVideo(remoteURL: remoteURL, localURL: localURL, name: videoName)

// 2. Kiểm tra xem đã download chưa
if UserDefaults.standard.isVideoDownloaded(remoteURL: remoteURL) {
    print("Video đã được download")
}

// 3. Lấy local URL
if let localURL = UserDefaults.standard.getLocalURL(for: remoteURL) {
    print("Local URL: \(localURL)")
}

// 4. Lấy tên video
if let videoName = UserDefaults.standard.getVideoName(for: remoteURL) {
    print("Video name: \(videoName)")
}

// 5. Lấy thông tin video đầy đủ
if let videoInfo = UserDefaults.standard.getVideoInfo(for: remoteURL) {
    print("Local URL: \(videoInfo.localURL)")
    print("Name: \(videoInfo.name)")
}

// 6. Lấy tất cả mappings
let allMappings = UserDefaults.standard.getAllDownloadedVideosMappings()
for (remoteURL, videoInfo) in allMappings {
    print("Remote: \(remoteURL)")
    print("Local: \(videoInfo.localURL)")
    print("Name: \(videoInfo.name)")
    print("---")
}

// 7. Xóa một mapping
UserDefaults.standard.removeDownloadedVideo(remoteURL: remoteURL)

// 8. Xóa tất cả mappings
UserDefaults.standard.clearAllDownloadedVideos()

// 9. Lấy số lượng video đã download
let count = UserDefaults.standard.getDownloadedVideosCount()
print("Đã download \(count) video")
*/
