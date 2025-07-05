//
//  Cell.swift
//  TestValidatedApp
//
//  Created by Luong Manh on 3/7/25.
//

import UIKit

class VideosSavedCell: UITableViewCell {
    lazy var uiImageView: UIImageView = {
        let uiImageView = UIImageView()
        uiImageView.translatesAutoresizingMaskIntoConstraints = false
        uiImageView.contentMode = .scaleAspectFill
        return uiImageView
    }()
    
    lazy var playImageView: UIImageView = {
        let uiImageView = UIImageView()
        uiImageView.image = .playLogo
        uiImageView.translatesAutoresizingMaskIntoConstraints = false
        uiImageView.contentMode = .scaleAspectFill
        return uiImageView
    }()
    
    lazy var videoNameLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = .systemFont(ofSize: 14, weight: .medium)
        label.numberOfLines = 0
        return label
    }()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupViews()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setupViews() {
        contentView.addSubViews([
            uiImageView,
            videoNameLabel,
            playImageView
        ])
        
        videoNameLabel
            .leading(uiImageView.trailingAnchor, constant: 12)
            .trailing(contentView.trailingAnchor, constant: -12)
            .top(contentView.topAnchor, constant: 4)
            .bottom(contentView.bottomAnchor, constant: 4)
        
        uiImageView
            .centerY(contentView.centerYAnchor)
            .leading(contentView.leadingAnchor, constant: 16)
            .top(contentView.topAnchor, constant: 16)
            .bottom(contentView.bottomAnchor, constant: -16)
        
        playImageView
            .centerY(uiImageView.centerYAnchor)
            .centerX(uiImageView.centerXAnchor)
            .size(height: 45, width: 45)
    }
    
    override func layoutSubviews() {
        uiImageView.layer.masksToBounds = true
        uiImageView.layer.cornerRadius = 8
    }
    
    func configDataForCell(_ model: VideoModel) {
        videoNameLabel.text = String(model.name.dropLast(4))
        
        var imageData: Data?
        
        let url = FileManager.default.urls(for: .documentDirectory,
                                           in: .userDomainMask)[0].appendingPathComponent(model.thumbnailPath)
        
        DispatchQueue.main.async {
            do {
                imageData = try Data(contentsOf: url)
            } catch {
                print("Error cells", error.localizedDescription)
            }
            guard let dataOfImage = imageData else { return }
            guard let image = UIImage(data: dataOfImage) else { return }
            
            self.uiImageView.image = image
        }
    }
}
