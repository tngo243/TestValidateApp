//
//  HNPlayerView.swift
//  TestValidateApp
//
//  Created by Nguyen Hai Nam on 9/7/25.
//

import UIKit
import AVFoundation

public class HNPlayerView: UIView {

    // MARK: - overrides

    public override class var layerClass: AnyClass {
        get {
            return AVPlayerLayer.self
        }
    }

    // MARK: - internal properties

    internal var playerLayer: AVPlayerLayer {
        get {
            return self.layer as! AVPlayerLayer
        }
    }

    internal var player: AVPlayer? {
        get {
            return self.playerLayer.player
        }
        set {
            self.playerLayer.player = newValue
            self.playerLayer.isHidden = (self.playerLayer.player == nil)
        }
    }

    // MARK: - public properties

    public var playerBackgroundColor: UIColor? {
        get {
            if let cgColor = self.playerLayer.backgroundColor {
                return UIColor(cgColor: cgColor)
            }
            return nil
        }
        set {
            self.playerLayer.backgroundColor = newValue?.cgColor
        }
    }

    public var playerFillMode: AVLayerVideoGravity {
        get {
            return self.playerLayer.videoGravity
        }
        set {
            self.playerLayer.videoGravity = newValue
        }
    }

    public var isReadyForDisplay: Bool {
        get {
            return self.playerLayer.isReadyForDisplay
        }
    }

    // MARK: - object lifecycle

    public override init(frame: CGRect) {
        super.init(frame: frame)
        self.playerLayer.isHidden = true
        self.playerFillMode = .resizeAspect
    }

    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        self.playerLayer.isHidden = true
        self.playerFillMode = .resizeAspect
    }

    deinit {
        self.player?.pause()
        self.player = nil
    }
}
