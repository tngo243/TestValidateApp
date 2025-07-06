//
//  WatchingAVideoViewController.swift
//  TestValidateApp
//
//  Created Thien Nguyen on 3/7/25.
//

import UIKit

@objc final class WatchingAVideoViewController: UIViewController {
  private let output: any WatchingAVideoViewOutput
  private var videoItems: [VideoItem] = []
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
//    textField.text = kHLSUrl as String
    textField.borderStyle = .roundedRect
    textField.backgroundColor = .white
    textField.textColor = .black
    textField.font = UIFont.systemFont(ofSize: 16)
    textField.translatesAutoresizingMaskIntoConstraints = false
    return textField
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
    tableView.register(VideoItemTableViewCell.self, forCellReuseIdentifier: "VideoItemCell")
    tableView.register(UITableViewCell.self, forCellReuseIdentifier: "DefaultCell")
    tableView.delegate = self
    tableView.dataSource = self
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
  }
  
  // MARK: - UI Setup
  private func setupUI() {
    view.backgroundColor = .systemBackground
    title = "Watching a video"
    // Add main stack view to view
    view.addSubview(mainStackView)
    // Add text field and label to stack view
    mainStackView.addArrangedSubview(textField)
    // Add button stack view to main stack view
    mainStackView.addArrangedSubview(buttonStackView)
    // Add buttons to button stack view
    buttonStackView.addArrangedSubview(downloadButton)
    buttonStackView.addArrangedSubview(playButton)
    // Add table view to main stack view
    mainStackView.addArrangedSubview(tableView)
    // Set hugging/compression priorities
    textField.setContentHuggingPriority(.required, for: .vertical)
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
        let tfText = self?.textField.text
        Task {
          guard let videoUrl = tfText?.trimmingCharacters(in: .whitespacesAndNewlines) else {
            return
          }
          await output.downloadBtnTapped(videoUrl: videoUrl)
        }
      },
      for: .touchUpInside)
    playButton.addAction(
      UIAction { [weak self, unowned output] _ in
        let tfText = self?.textField.text
        Task {
          guard let videoUrl = tfText?.trimmingCharacters(in: .whitespacesAndNewlines) else {
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
    NotificationCenter.default.addObserver(
      self,
      selector: #selector(handleAssetPersistenceManagerDidRestoreState(_:)),
      name: Notification.Name.AssetPersistenceManagerDidRestoreState,
      object: nil
    )
    NotificationCenter.default.addObserver(
      self,
      selector: #selector(handleError(_:)),
      name: .errorOccurred,
      object: nil
    )
  }
  
  @objc func handleAssetDownloadProgress(_ notification: NSNotification) {
    DispatchQueue.main.async {
      if let id = notification.userInfo?[Asset.Keys.id] as? String,
         let rowIndex = self.videoItems.firstIndex(where: { $0.id == id }),
         let percent = notification.userInfo?[Asset.Keys.percentDownloaded] as? Double {
        self.videoItems[rowIndex].progress = percent
        self.tableView.reloadRows(at: [IndexPath(row: rowIndex, section: 0)], with: .automatic)
      }
    }
  }

  @objc func handleAssetDownloadStateChanged(_ notification: NSNotification) {
    if let id = notification.userInfo?[Asset.Keys.id] as? String,
       let rowIndex = self.videoItems.firstIndex(where: { $0.id == id }),
       let stateRawValue = notification.userInfo?[Asset.Keys.downloadState] as? Int,
       let state = Asset.DownloadState.init(rawValue: stateRawValue) {
      self.videoItems[rowIndex].state = .init(from: state)
      self.tableView.reloadRows(at: [IndexPath(row: rowIndex, section: 0)], with: .automatic)
    }
  }
  
  @objc func handleAssetPersistenceManagerDidRestoreState(_ notification: NSNotification) {
    Task {
      await output.didRestoreState()
    }
  }
  
  @objc private func handleError(_ notification: NSNotification) {
    guard let error = notification.userInfo?[ErrorNotification.errorKey] as? Error else { return }
    let message: String
    if let tvaError = error as? TVAError {
      message = tvaError.errorDescription ?? "An unknown error occurred"
    } else {
      message = error.localizedDescription
    }
    Task { @MainActor [weak self]  in
      await self?.popupAlert(
        title: "Error",
        message: message,
        actionTitles: ["OK"],
        actions: [{ _ in }]
      )
    }
  }
}

// MARK: - UITableViewDataSource & UITableViewDelegate
extension WatchingAVideoViewController: UITableViewDataSource, UITableViewDelegate {
  func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return videoItems.count
  }
  
  func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    guard let cell = tableView.dequeueReusableCell(withIdentifier: "VideoItemCell", for: indexPath) as? VideoItemTableViewCell else {
      return UITableViewCell()
    }
    let videoItem = videoItems[indexPath.row]
    cell.configure(with: videoItem)
    cell.onCancelTapped = { [unowned self] videoId in
      Task {
        await self.output.cancelDownloadTapped(videoId: videoId)
      }
    }
    return cell
  }
  
  func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    tableView.deselectRow(at: indexPath, animated: true)
    let videoItem = videoItems[indexPath.row]
    guard videoItem.state == .completed else { return }
    Task {
      await output.videoItemSelected(videoName: videoItem.name)
    }
  }
}

extension WatchingAVideoViewController: WatchingAVideoViewInput {
  func updateVideoItems(_ items: [VideoItem]) {
    videoItems = items
    tableView.reloadData()
  }
  
  func addVideoItem(_ item: VideoItem) {
    videoItems.append(item)
    let indexPath = IndexPath(row: videoItems.count - 1, section: 0)
    tableView.insertRows(at: [indexPath], with: .automatic)
  }
  
  func updateVideoItem(_ item: VideoItem) {
    if let index = videoItems.firstIndex(where: { $0.id == item.id }) {
      videoItems[index] = item
      let indexPath = IndexPath(row: index, section: 0)
      tableView.reloadRows(at: [indexPath], with: .none)
    }
  }
}
