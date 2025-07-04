//
//  Userdefaults.swift
//  TestValidateApp
//
//  Created by Linh Phan on 3/7/25.
//

import Foundation
class Userdefaults: NSObject {
    static let shared = Userdefaults()
    
    private override init() {
        super.init()
    }
    
    private let keyDownloadList = "DownloadItemList"
    
    func saveDownloads(_ items: [DownloadItem]) {
        let encoder = JSONEncoder()
        if let data = try? encoder.encode(items) {
            UserDefaults.standard.set(data, forKey: keyDownloadList)
        }
    }

    func loadDownloads() -> [DownloadItem] {
        guard let data = UserDefaults.standard.data(forKey: keyDownloadList) else { return [] }
        let decoder = JSONDecoder()
        return (try? decoder.decode([DownloadItem].self, from: data)) ?? []
    }
}
