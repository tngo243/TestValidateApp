//
//  HNVideoPlayer+Loading.swift
//  TestValidateApp
//
//  Created by Nguyen Hai Nam on 9/7/25.
//

import UIKit
import AVFoundation

extension HNVideoPlayer {
    func setup(url: URL) {
        guard isViewLoaded else { return }

        if self.playbackState == .playing {
            self.pause()
        }

        self.setupPlayerItem(nil)

        let asset = AVURLAsset(url: url, options: .none)
        self.setupAsset(asset)
    }

    func setupAsset(_ asset: AVAsset, loadableKeys: [String] = ["tracks", "playable", "duration"]) {
        guard isViewLoaded else { return }

        if self.playbackState == .playing {
            self.pause()
        }

        self._asset = asset

        self._asset?.loadValuesAsynchronously(forKeys: loadableKeys, completionHandler: { () -> Void in
            guard let asset = self._asset else {
                return
            }
            
            for key in loadableKeys {
                var error: NSError? = nil
                let status = asset.statusOfValue(forKey: key, error: &error)
                if status == .failed {
                    self.playbackState = .failed
                    return
                }
            }

            if !asset.isPlayable {
                self.playbackState = .failed
                return
            }

            let playerItem = AVPlayerItem(asset:asset)
            self.setupPlayerItem(playerItem)
        })
    }

    func setupPlayerItem(_ playerItem: AVPlayerItem?) {
        if let currentPlayerItem = self.playerItem {
            NotificationCenter.default.removeObserver(self, name: .AVPlayerItemDidPlayToEndTime, object: currentPlayerItem)
            NotificationCenter.default.removeObserver(self, name: .AVPlayerItemFailedToPlayToEndTime, object: currentPlayerItem)
        }

        self.playerItem = playerItem

        if let updatedPlayerItem = self.playerItem {
        }

        self.avplayer.replaceCurrentItem(with: self.playerItem)
    }
}
