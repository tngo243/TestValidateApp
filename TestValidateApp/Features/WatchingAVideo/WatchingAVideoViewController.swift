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
  
  private lazy var playerView: UIView = {
    let view = UIView()
    view.backgroundColor = .red
    view.translatesAutoresizingMaskIntoConstraints = false
    return view
  }()

  init() {
    let interactor = WatchingAVideoInteractor()
    let presenter = WatchingAVideoPresenter(interactor: interactor)
    self.output = presenter
    super.init(nibName: nil, bundle: nil)
    presenter.view = self
  }

  @available(*, unavailable)
  required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }

  override func viewDidLoad() {
    super.viewDidLoad()
    setupUI()
    Task {
      await output.viewIsReady()
    }
  }
  
  // MARK: - UI Setup
  private func setupUI() {
    view.backgroundColor = .systemBackground
    
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
    
    // Add player view to main stack view
    mainStackView.addArrangedSubview(playerView)
    
    // Setup constraints
    NSLayoutConstraint.activate([
      // Main stack view constraints - full screen
      mainStackView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 20),
      mainStackView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
      mainStackView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
      mainStackView.bottomAnchor.constraint(lessThanOrEqualTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -20),
      
      // Text field height
      textField.heightAnchor.constraint(equalToConstant: 44),
      
      // Button stack view constraints
      buttonStackView.heightAnchor.constraint(equalToConstant: 44),
      
      // Player view constraints - aspect ratio 2.23:1 (width:height)
      playerView.heightAnchor.constraint(equalTo: playerView.widthAnchor, multiplier: 1.0/2.23),
    ])
  }
}

extension WatchingAVideoViewController: WatchingAVideoViewInput {
}
