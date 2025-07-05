//
//  WatchingAVideoViewController.swift
//  TestValidateApp
//
//  Created Thien Nguyen on 3/7/25.
//

import UIKit

@objc final class WatchingAVideoViewController: UIViewController {
  private let output: any WatchingAVideoViewOutput
  
  // MARK: - UI Elements
  private lazy var mainStackView: UIStackView = {
    let stackView = UIStackView()
    stackView.axis = .vertical
    stackView.distribution = .fill
    stackView.alignment = .fill
    stackView.spacing = 16
    stackView.translatesAutoresizingMaskIntoConstraints = false
    return stackView
  }()
  
  private lazy var textField: UITextField = {
    let textField = UITextField()
    textField.placeholder = "Enter Video URL..."
    textField.text = kHLSUrl as String
    textField.borderStyle = .roundedRect
    textField.backgroundColor = .white
    textField.textColor = .black
    textField.font = UIFont.systemFont(ofSize: 16)
    textField.translatesAutoresizingMaskIntoConstraints = false
    return textField
  }()
  
  private lazy var label: UILabel = {
    let label = UILabel()
    label.text = "Download process"
    label.textColor = .black
    label.font = UIFont.systemFont(ofSize: 16)
    label.textAlignment = .left
    label.numberOfLines = 0
    label.translatesAutoresizingMaskIntoConstraints = false
    return label
  }()
  
  private lazy var buttonStackView: UIStackView = {
    let stackView = UIStackView()
    stackView.axis = .horizontal
    stackView.distribution = .fillEqually
    stackView.alignment = .fill
    stackView.spacing = 12
    stackView.translatesAutoresizingMaskIntoConstraints = false
    return stackView
  }()
  
  private lazy var downloadButton: UIButton = {
    let button = UIButton(type: .system)
    button.setTitle("Download", for: .normal)
    button.setTitleColor(.white, for: .normal)
    button.backgroundColor = .systemBlue
    button.titleLabel?.font = UIFont.systemFont(ofSize: 16, weight: .medium)
    button.layer.cornerRadius = 8
    button.translatesAutoresizingMaskIntoConstraints = false
    return button
  }()
  
  
  private lazy var playButton: UIButton = {
    let button = UIButton(type: .system)
    button.setTitle("Play", for: .normal)
    button.setTitleColor(.white, for: .normal)
    button.backgroundColor = .systemGreen
    button.titleLabel?.font = UIFont.systemFont(ofSize: 16, weight: .medium)
    button.layer.cornerRadius = 8
    button.translatesAutoresizingMaskIntoConstraints = false
    return button
  }()
  
  private lazy var tableView: UITableView = {
    let tableView = UITableView()
    tableView.backgroundColor = .black.withAlphaComponent(0.2)
    tableView.estimatedRowHeight = 75.0
    tableView.rowHeight = UITableView.automaticDimension
    tableView.translatesAutoresizingMaskIntoConstraints = false
    return tableView
  }()
  
  init() {
    let interactor = WatchingAVideoInteractor()
    let presenter = WatchingAVideoPresenter(interactor: interactor)
    self.output = presenter
    super.init(nibName: nil, bundle: nil)
    presenter.view = self
    let router = WatchingAVideoRouter(viewController: self)
    presenter.router = router
  }
  
  @available(*, unavailable)
  required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }
  
  override func viewDidLoad() {
    super.viewDidLoad()
    setupUI()
    setupActions()
    setupNotification()
    Task {
      await output.viewIsReady()
    }
  }
  
  // MARK: - UI Setup
  private func setupUI() {
    view.backgroundColor = .systemBackground
    title = "Watching a video"
    
    // Add main stack view to view
    view.addSubview(mainStackView)
    
    // Add text field and label to stack view
    mainStackView.addArrangedSubview(textField)
    mainStackView.addArrangedSubview(label)
    
    // Add button stack view to main stack view
    mainStackView.addArrangedSubview(buttonStackView)
    
    // Add buttons to button stack view
    buttonStackView.addArrangedSubview(downloadButton)
    buttonStackView.addArrangedSubview(playButton)
    
    // Add table view to main stack view
    mainStackView.addArrangedSubview(tableView)

    // Set hugging/compression priorities
    textField.setContentHuggingPriority(.required, for: .vertical)
    label.setContentHuggingPriority(.required, for: .vertical)
    buttonStackView.setContentHuggingPriority(.required, for: .vertical)
    tableView.setContentHuggingPriority(.defaultLow, for: .vertical)
    tableView.setContentCompressionResistancePriority(.defaultLow, for: .vertical)
    
    // Setup constraints
    NSLayoutConstraint.activate([
      // Main stack view constraints - full screen
      mainStackView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 20),
      mainStackView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
      mainStackView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
      mainStackView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -20),
      
      // Text field height
      textField.heightAnchor.constraint(equalToConstant: 44),
      
      // Button stack view constraints
      buttonStackView.heightAnchor.constraint(equalToConstant: 44)
    ])
  }
  
  private func setupActions() {
    downloadButton.addAction(
      UIAction { [weak self, unowned output] _ in
        Task {
          guard let videoUrl = self?.textField.text, !videoUrl.isEmpty else {
            return
          }
          await output.downloadBtnTapped(videoUrl: videoUrl)
        }
      },
      for: .touchUpInside)
    

    
    playButton.addAction(
      UIAction { [weak self, unowned output] _ in
        Task {
          guard let videoUrl = self?.textField.text, !videoUrl.isEmpty else {
            return
          }
          await output.playBtnTapped(videoUrl: videoUrl)
        }
      },
      for: .touchUpInside)
  }
  
  private func setupNotification() {
    NotificationCenter.default.addObserver(
      self,
      selector: #selector(handleAssetDownloadProgress(_:)),
      name: Notification.Name.AssetDownloadProgress,
      object: nil
    )
    NotificationCenter.default.addObserver(
      self,
      selector: #selector(handleAssetDownloadStateChanged(_:)),
      name: Notification.Name.AssetDownloadStateChanged,
      object: nil
    )
  }
  
  @objc func handleAssetDownloadProgress(_ notification: NSNotification) {
    DispatchQueue.main.async {
          if let percent = notification.userInfo?[Asset.Keys.percentDownloaded] as? Double {
            self.label.text = "Downloading: \(String(format: "%.2f", percent * 100.0))%"
          }
      }
  }
  

  @objc func handleAssetDownloadStateChanged(_ notification: NSNotification) {
    if let name = notification.userInfo?[Asset.Keys.name] as? String,
       let name = notification.userInfo?[Asset.Keys.downloadState] as? String {
      
      
    }
  }


}

extension WatchingAVideoViewController: WatchingAVideoViewInput {
  func updateVideoItem(_ state: VideoItemState) {
    
  }
  
}
