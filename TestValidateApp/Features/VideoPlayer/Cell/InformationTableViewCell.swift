//
//  InformationTableViewCell.swift
//  TestValidateApp
//
//  Created by Nguyen Nam on 11/7/25.
//

import UIKit

class InformationTableViewCell: UITableViewCell {

    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var subtitleLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func configure(with model: VideoData) {
        titleLabel.text = model.name
        subtitleLabel.text = model.remoteURL
    }
    
}
