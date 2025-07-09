//
//  HNVideoPlayer.swift
//  TestValidateApp
//
//  Created by Nguyen Hai Nam on 9/7/25.
//

import UIKit
import AVFoundation

open class HNVideoPlayer: UIViewController {
    public enum PlaybackState {
        case stopped
        case playing
        case paused
        case failed
    }
    
    // MARK: - Properties
    var playbackState: PlaybackState = .stopped
    
    lazy var avplayer: AVPlayer = {
        let avplayer = AVPlayer()
        avplayer.actionAtItemEnd = .pause
        return avplayer
    }()
    var playerItem: AVPlayerItem?
    
    // config sources
    open var url: URL? {
        didSet {
            if let url = self.url {
                setup(url: url)
            }
        }
    }
    open var asset: AVAsset? {
        get { return _asset }
        set { _ = newValue.map { setupAsset($0) } }
    }

    internal var _asset: AVAsset? {
        didSet {
            if let _ = self._asset {
                self.setupPlayerItem(nil)
            }
        }
    }

    private var playerView: HNPlayerView = HNPlayerView(frame: .zero)
    
    // MARK: -  Lifecycle of the VideoPlayer
    public convenience init() {
        self.init(nibName: nil, bundle: nil)
    }
    
    public override init(nibName: String?, bundle: Bundle?) {
        super.init(nibName: nibName, bundle: bundle)
    }
    
    public required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    deinit {
        self.avplayer.pause()
        self.setupPlayerItem(nil)
//
//        self.removePlayerObservers()
//
//        self.removeApplicationObservers()
//
//        self.removePlayerLayerObservers()
//
//        self._playerView.player = nil
    }

    // MARK: -  Lifecycle of the View
    open override func loadView() {
        super.loadView()
        self.playerView.frame = self.view.bounds
        self.view = self.playerView
    }

    open override func viewDidLoad() {
        super.viewDidLoad()
        self.playerView.player = self.avplayer

        if let url = self.url {
            setup(url: url)
        } else if let asset = self.asset {
            setupAsset(asset)
        }

//        self.addPlayerLayerObservers()
//        self.addPlayerObservers()
//        self.addApplicationObservers()
    }

    open override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        if self.playbackState == .playing {
            self.pause()
        }
    }
}
