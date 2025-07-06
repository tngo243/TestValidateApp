//
//  VideoItemTableViewCell.swift
//  TestValidateApp
//
//  Created by Thien Nguyen on 4/7/25.
//

import UIKit

final class VideoItemTableViewCell: UITableViewCell {
  
  private var currentVideoItemId: String?
  // MARK: - Callback
  var onCancelTapped: ((String) -> Void)?
  
  // MARK: - UI Elements
  private lazy var containerView: UIView = {
    let view = UIView()
    view.backgroundColor = .systemGray6
    view.layer.cornerRadius = 8
    view.translatesAutoresizingMaskIntoConstraints = false
    return view
  }()
  
  private lazy var nameLabel: UILabel = {
    let label = UILabel()
    label.textColor = .label
    label.font = UIFont.systemFont(ofSize: 16, weight: .medium)
    label.numberOfLines = 1
    label.translatesAutoresizingMaskIntoConstraints = false
    return label
  }()
  
  private lazy var urlLabel: UILabel = {
    let label = UILabel()
    label.textColor = .secondaryLabel
    label.font = UIFont.systemFont(ofSize: 12)
    label.numberOfLines = 1
    label.translatesAutoresizingMaskIntoConstraints = false
    return label
  }()
  
  private lazy var progressLabel: UILabel = {
    let label = UILabel()
    label.textColor = .systemBlue
    label.font = UIFont.systemFont(ofSize: 12)
    label.numberOfLines = 1
    label.translatesAutoresizingMaskIntoConstraints = false
    return label
  }()
  
  private lazy var cancelButton: UIButton = {
    let button = UIButton(type: .system)
    button.setTitle("Cancel", for: .normal)
    button.setTitleColor(.white, for: .normal)
    button.backgroundColor = .systemRed
    button.titleLabel?.font = UIFont.systemFont(ofSize: 12, weight: .medium)
    button.layer.cornerRadius = 4
    button.translatesAutoresizingMaskIntoConstraints = false
    return button
  }()
  
  // MARK: - Initialization
  override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
    super.init(style: style, reuseIdentifier: reuseIdentifier)
    setupUI()
    setupActions()
  }
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  // MARK: - UI Setup
  private func setupUI() {
    backgroundColor = .clear
    selectionStyle = .none
    
    contentView.addSubview(containerView)
    containerView.addSubview(nameLabel)
    containerView.addSubview(urlLabel)
    containerView.addSubview(progressLabel)
    containerView.addSubview(cancelButton)
    
    NSLayoutConstraint.activate([
      // Container view
      containerView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 4),
      containerView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 8),
      containerView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -8),
      containerView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -4),
      
      // Name label
      nameLabel.topAnchor.constraint(equalTo: containerView.topAnchor, constant: 8),
      nameLabel.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 12),
      nameLabel.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -12),
      
      // URL label
      urlLabel.topAnchor.constraint(equalTo: nameLabel.bottomAnchor, constant: 4),
      urlLabel.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 12),
      urlLabel.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -12),
      
      // Progress label
      progressLabel.topAnchor.constraint(equalTo: urlLabel.bottomAnchor, constant: 8),
      progressLabel.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 12),
      progressLabel.trailingAnchor.constraint(equalTo: cancelButton.leadingAnchor, constant: -8),
      
      // Cancel button
      cancelButton.topAnchor.constraint(equalTo: urlLabel.bottomAnchor, constant: 8),
      cancelButton.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -12),
      cancelButton.widthAnchor.constraint(equalToConstant: 60),
      cancelButton.heightAnchor.constraint(equalToConstant: 24),
      cancelButton.bottomAnchor.constraint(equalTo: containerView.bottomAnchor, constant: -8)
    ])
  }
  
  private func setupActions() {
    cancelButton.addTarget(self, action: #selector(cancelButtonTapped), for: .touchUpInside)
  }
  
  @objc private func cancelButtonTapped() {
    guard let currentVideoItemId = currentVideoItemId else {return}
    onCancelTapped?(currentVideoItemId)
  }
  
  // MARK: - Configuration
  func configure(with videoItem: VideoItem) {
    currentVideoItemId = videoItem.id
    nameLabel.text = videoItem.name
    urlLabel.text = videoItem.url
    
    switch videoItem.state {
    case .downloading:
      progressLabel.text = "Downloading: \(String(format: "%.0f", videoItem.progress * 100.0))%"
      progressLabel.isHidden = false
      cancelButton.isHidden = false
    case .completed:
      progressLabel.text = "Completed"
      progressLabel.isHidden = false
      cancelButton.isHidden = true
    case .cancelled:
      progressLabel.text = "Cancelled"
      progressLabel.isHidden = false
      cancelButton.isHidden = true
    }
  }
} 
