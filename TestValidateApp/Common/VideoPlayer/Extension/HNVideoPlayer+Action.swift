//
//  HNPlayerView+Action.swift
//  TestValidateApp
//
//  Created by Nguyen Hai Nam on 9/7/25.
//

import UIKit
import AVFoundation

extension HNVideoPlayer {
    func playFromBeginning() {
        self.avplayer.seek(to: CMTime.zero)
        self.playFromCurrentTime()
    }

    func playFromCurrentTime() {
        self.play()
    }

    private func play() {
        self.playbackState = .playing
        self.avplayer.play()
    }

    func pause() {
        if self.playbackState != .playing {
            return
        }
        self.avplayer.pause()
        self.playbackState = .paused
    }

    func stop() {
        if self.playbackState == .stopped {
            return
        }

        self.avplayer.pause()
        self.playbackState = .stopped
    }

    func seek(to time: CMTime, completionHandler: ((Bool) -> Swift.Void)? = nil) {
        if let playerItem = self.playerItem {
            return playerItem.seek(to: time, completionHandler: completionHandler)
        }
    }
}
