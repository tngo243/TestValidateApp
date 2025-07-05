//
//  VideoPlayerManager.swift
//  TestValidateApp
//
//  Created by Thien Nguyen on 4/7/25.
//

import Foundation
import AVFoundation

actor VideoPlayerManager {
    static let shared = VideoPlayerManager()
    
    private init() {}
    
    private var player: AVPlayer?
    
    func setPlayer(with url: URL) {
        player = AVPlayer(url: url)
    }
    
    func play() async {
      await player?.play()
    }
    
    func pause() async {
        await player?.pause()
    }
    
    func stop() async {
        await player?.pause()
        await player?.seek(to: .zero)
    }
    
    func getPlayer() -> AVPlayer? {
        return player
    }
}

