//
//  DownloadTableViewCell.swift
//  TestValidateApp
//
//  Created by Nguyen Nam on 10/7/25.
//

import UIKit

@objc class DownloadTableViewCell: UITableViewCell {

    @IBOutlet weak var borderView: UIView!
    @IBOutlet weak var indicator: UIActivityIndicatorView!
    @IBOutlet weak var checkMarkIcon: UIImageView!
    @IBOutlet weak var downloadingLabel: UILabel!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var subtitleLabel: UILabel!
    @IBOutlet weak var cancelButton: UIButton!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        cancelButton.tintColor = .red
        borderView.layer.cornerRadius = 16
        borderView.layer.borderWidth = 2
        borderView.layer.borderColor = HNColor.Border.default.cgColor
        
        titleLabel.font = HNFont.bodyEmphasized.font
        subtitleLabel.font = HNFont.subheadlineRegular.font
        downloadingLabel.font = HNFont.helpTextEmphasized.font
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    @objc func setUpCell(cellModel: DownloadTableCellModel) {
        titleLabel.text = cellModel.videoName
        subtitleLabel.text = cellModel.link
        
        switch cellModel.status {
        case .downloading:
            checkMarkIcon.isHidden = true
            indicator.isHidden = false
            indicator.startAnimating()
            downloadingLabel.text = "\(cellModel.progress)%"
            downloadingLabel.textColor = HNColor.Text.information
        case .completed:
            checkMarkIcon.isHidden = false
            indicator.isHidden = true
            
            checkMarkIcon.image = UIImage(systemName: "checkmark.circle.fill")
            checkMarkIcon.tintColor = .green
            downloadingLabel.text = "Done"
            downloadingLabel.textColor = .green
            cancelButton.isHidden = true
        case .failed:
            checkMarkIcon.isHidden = false
            indicator.isHidden = true
            
            checkMarkIcon.image = UIImage(systemName: "xmark.circle.fill")
            checkMarkIcon.tintColor = .red
        case .cancelled:
            checkMarkIcon.isHidden = false
            indicator.isHidden = true
            
            checkMarkIcon.image = UIImage(systemName: "xmark.circle.fill")
            checkMarkIcon.tintColor = .red
        }
    }
    
}
