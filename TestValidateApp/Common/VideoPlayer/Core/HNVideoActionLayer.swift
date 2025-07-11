//
//  HNVideoActionLayer.swift
//  TestValidateApp
//
//  Created by Nguyen Nam on 11/7/25.
//

import UIKit
import AVFoundation


// MARK: - Delegate Protocol
protocol HNVideoPlayerOverlayDelegate: AnyObject {
    func playPauseButtonTapped()
    func getCurrentPlaybackState() -> HNVideoPlayer.PlaybackState
}

class HNVideoPlayerOverlay: UIView {
    
    // MARK: - Properties
    weak var player: AVPlayer?
    weak var delegate: HNVideoPlayerOverlayDelegate?
    
    private var hideTimer: Timer?
    private var isControlsVisible = true
    private var isDragging = false
    private var timeObserver: Any?
    
    // MARK: - UI Components
    private lazy var playPauseButton: UIButton = {
        let button = UIButton(type: .system)
        button.setImage(UIImage(systemName: "pause.fill"), for: .normal)
        button.tintColor = .white
        button.backgroundColor = UIColor.black.withAlphaComponent(0.5)
        button.layer.cornerRadius = 25
        button.translatesAutoresizingMaskIntoConstraints = false
        button.addTarget(self, action: #selector(playPauseButtonTapped), for: .touchUpInside)
        return button
    }()
    
    private lazy var seekSlider: UISlider = {
        let slider = UISlider()
        slider.minimumValue = 0
        slider.maximumValue = 1
        slider.value = 0
        slider.minimumTrackTintColor = .systemBlue
        slider.maximumTrackTintColor = UIColor.white.withAlphaComponent(0.5)
        slider.thumbTintColor = .white
        slider.translatesAutoresizingMaskIntoConstraints = false
        slider.addTarget(self, action: #selector(seekSliderValueChanged), for: .valueChanged)
        slider.addTarget(self, action: #selector(seekSliderTouchDown), for: .touchDown)
        slider.addTarget(self, action: #selector(seekSliderTouchUp), for: [.touchUpInside, .touchUpOutside])
        return slider
    }()
    
    private lazy var currentTimeLabel: UILabel = {
        let label = UILabel()
        label.text = "00:00"
        label.textColor = .white
        label.font = UIFont.systemFont(ofSize: 12)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private lazy var totalTimeLabel: UILabel = {
        let label = UILabel()
        label.text = "00:00"
        label.textColor = .white
        label.font = UIFont.systemFont(ofSize: 12)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private lazy var controlsContainerView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor.black.withAlphaComponent(0.3)
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private lazy var bottomControlsView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor.black.withAlphaComponent(0.5)
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    // MARK: - Initialization
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
        setupGestures()
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        setupUI()
        setupGestures()
    }
    
    deinit {
        removeTimeObserver()
        hideTimer?.invalidate()
    }
    
    // MARK: - Setup
    private func setupUI() {
        backgroundColor = UIColor.clear
        
        // Add container view
        addSubview(controlsContainerView)
        
        // Add play/pause button (center)
        controlsContainerView.addSubview(playPauseButton)
        
        // Add bottom controls
        controlsContainerView.addSubview(bottomControlsView)
        bottomControlsView.addSubview(currentTimeLabel)
        bottomControlsView.addSubview(seekSlider)
        bottomControlsView.addSubview(totalTimeLabel)
        
        setupConstraints()
    }
    
    private func setupConstraints() {
        // Controls container fills the entire view
        NSLayoutConstraint.activate([
            controlsContainerView.topAnchor.constraint(equalTo: topAnchor),
            controlsContainerView.leadingAnchor.constraint(equalTo: leadingAnchor),
            controlsContainerView.trailingAnchor.constraint(equalTo: trailingAnchor),
            controlsContainerView.bottomAnchor.constraint(equalTo: bottomAnchor)
        ])
        
        // Play/Pause button (center)
        NSLayoutConstraint.activate([
            playPauseButton.centerXAnchor.constraint(equalTo: controlsContainerView.centerXAnchor),
            playPauseButton.centerYAnchor.constraint(equalTo: controlsContainerView.centerYAnchor),
            playPauseButton.widthAnchor.constraint(equalToConstant: 50),
            playPauseButton.heightAnchor.constraint(equalToConstant: 50)
        ])
        
        // Bottom controls
        NSLayoutConstraint.activate([
            bottomControlsView.leadingAnchor.constraint(equalTo: controlsContainerView.leadingAnchor),
            bottomControlsView.trailingAnchor.constraint(equalTo: controlsContainerView.trailingAnchor),
            bottomControlsView.bottomAnchor.constraint(equalTo: controlsContainerView.bottomAnchor),
            bottomControlsView.heightAnchor.constraint(equalToConstant: 60)
        ])
        
        // Time labels and slider
        NSLayoutConstraint.activate([
            currentTimeLabel.leadingAnchor.constraint(equalTo: bottomControlsView.leadingAnchor, constant: 16),
            currentTimeLabel.centerYAnchor.constraint(equalTo: bottomControlsView.centerYAnchor),
            currentTimeLabel.widthAnchor.constraint(equalToConstant: 45),
            
            totalTimeLabel.trailingAnchor.constraint(equalTo: bottomControlsView.trailingAnchor, constant: -16),
            totalTimeLabel.centerYAnchor.constraint(equalTo: bottomControlsView.centerYAnchor),
            totalTimeLabel.widthAnchor.constraint(equalToConstant: 45),
            
            seekSlider.leadingAnchor.constraint(equalTo: currentTimeLabel.trailingAnchor, constant: 16),
            seekSlider.trailingAnchor.constraint(equalTo: totalTimeLabel.leadingAnchor, constant: -16),
            seekSlider.centerYAnchor.constraint(equalTo: bottomControlsView.centerYAnchor)
        ])
    }
    
    private func setupGestures() {
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(viewTapped))
        addGestureRecognizer(tapGesture)
    }
    
    // MARK: - Public Methods
    func configure(with player: AVPlayer) {
        self.player = player
        addTimeObserver()
        updatePlayPauseButton()
        updateDurationLabels()
    }
    
    func updatePlaybackState(_ isPlaying: Bool) {
        playPauseButton.isSelected = isPlaying
    }
    
    // MARK: - Private Methods
    private func addTimeObserver() {
        removeTimeObserver()
        
        guard let player = player else { return }
        
        let timeScale = CMTimeScale(NSEC_PER_SEC)
        let time = CMTime(seconds: 0.1, preferredTimescale: timeScale)
        
        timeObserver = player.addPeriodicTimeObserver(forInterval: time, queue: .main) { [weak self] time in
            self?.updateProgress(time)
        }
    }
    
    private func removeTimeObserver() {
        if let observer = timeObserver {
            player?.removeTimeObserver(observer)
            timeObserver = nil
        }
    }
    
    private func updateProgress(_ time: CMTime) {
        guard !isDragging else { return }
        
        let currentTime = CMTimeGetSeconds(time)
        let duration = player?.currentItem?.duration
        let totalTime = CMTimeGetSeconds(duration ?? CMTime.zero)
        
        if totalTime > 0 {
            seekSlider.value = Float(currentTime / totalTime)
        }
        
        currentTimeLabel.text = timeString(from: currentTime)
        
        if totalTime > 0 {
            totalTimeLabel.text = timeString(from: totalTime)
        }
    }
    
    private func updateDurationLabels() {
        guard let duration = player?.currentItem?.duration else { return }
        let totalTime = CMTimeGetSeconds(duration)
        totalTimeLabel.text = timeString(from: totalTime)
    }
    
    private func updatePlayPauseButton() {
        guard let player = player else { return }
        playPauseButton.isSelected = player.rate > 0
    }
    
    private func timeString(from seconds: Double) -> String {
        guard !seconds.isNaN && !seconds.isInfinite else { return "00:00" }
        
        let totalSeconds = Int(seconds)
        let minutes = totalSeconds / 60
        let remainingSeconds = totalSeconds % 60
        return String(format: "%02d:%02d", minutes, remainingSeconds)
    }
    
    private func showControls() {
        guard !isControlsVisible else { return }
        
        isControlsVisible = true
        UIView.animate(withDuration: 0.3) {
            self.controlsContainerView.alpha = 1.0
        }
        
        scheduleHideControls()
    }
    
    private func hideControls() {
        guard isControlsVisible else { return }
        
        isControlsVisible = false
        UIView.animate(withDuration: 0.3) {
            self.controlsContainerView.alpha = 0.0
        }
        
        hideTimer?.invalidate()
    }
    
    private func scheduleHideControls() {
        hideTimer?.invalidate()
        hideTimer = Timer.scheduledTimer(withTimeInterval: 2.0, repeats: false) { [weak self] _ in
            self?.hideControls()
        }
    }
    
    // MARK: - Actions
    @objc private func playPauseButtonTapped() {
        delegate?.playPauseButtonTapped()
        let icon = delegate?.getCurrentPlaybackState() == .playing ? "pause.fill" : "play.fill"
        playPauseButton.setImage(UIImage(systemName: icon), for: .normal)

        scheduleHideControls()
    }
    
    @objc private func seekSliderValueChanged() {
        guard let player = player,
              let duration = player.currentItem?.duration else { return }
        
        let totalTime = CMTimeGetSeconds(duration)
        let seekTime = totalTime * Double(seekSlider.value)
        let targetTime = CMTime(seconds: seekTime, preferredTimescale: 600)
        
        player.seek(to: targetTime)
        currentTimeLabel.text = timeString(from: seekTime)
    }
    
    @objc private func seekSliderTouchDown() {
        isDragging = true
        hideTimer?.invalidate()
    }
    
    @objc private func seekSliderTouchUp() {
        isDragging = false
        scheduleHideControls()
    }
    
    @objc private func viewTapped() {
        if isControlsVisible {
            hideControls()
        } else {
            showControls()
        }
    }
    
    func resetState() {
        playPauseButton.setImage(UIImage(systemName: "pause.fill"), for: .normal)
    }
}
