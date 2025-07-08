//
//  DownloadedTableViewCell.swift
//  TestValidateApp
//
//  Created by Thien Tung on 2/7/25.
//

import UIKit

class DownloadedTableViewCell: UITableViewCell {

    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var thumbImageView: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var createdDateLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        containerView.layer.cornerRadius = 12
        containerView.layer.borderWidth = 1
        containerView.layer.borderColor = UIColor.systemGray6.cgColor
        thumbImageView.layer.cornerRadius = 10
    }
    
    func bindData(_ url: URL) {
        nameLabel.text = url.lastPathComponent
        thumbImageView.image = Commons.shared.generateThumbnail(for: url)
        createdDateLabel.text = Commons.shared.getFormattedCreationDate(from: url)
    }
    
}
