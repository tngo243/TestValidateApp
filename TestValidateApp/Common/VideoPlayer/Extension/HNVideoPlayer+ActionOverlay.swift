//
//  HNVideoPlayer+ActionOverlay.swift
//  TestValidateApp
//
//  Created by Nguyen Nam on 11/7/25.
//

extension HNVideoPlayer: HNVideoPlayerOverlayDelegate {
    func getCurrentPlaybackState() -> PlaybackState {
        return playbackState
    }
    
    func addPlayerOverlay() {
        let overlay = HNVideoPlayerOverlay()
        overlay.delegate = self
        overlay.translatesAutoresizingMaskIntoConstraints = false
        
        view.addSubview(overlay)
        
        NSLayoutConstraint.activate([
            overlay.topAnchor.constraint(equalTo: view.topAnchor),
            overlay.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            overlay.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            overlay.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
        
        overlay.configure(with: avplayer)
    }
    
    func playPauseButtonTapped() {
        switch playbackState {
        case .playing:
            pause()
        case .paused, .stopped:
            playFromCurrentTime()
        case .failed:
            break
        }
    }
}
