//
//  DownloadVideoTableViewCell.swift
//  TestValidateApp
//
//  Created by Thien Tung on 2/7/25.
//

import UIKit

class DownloadVideoTableViewCell: UITableViewCell {

    @IBOutlet weak var nameFileLabel: UILabel!
    @IBOutlet weak var urlDetailLabel: UILabel!
    @IBOutlet weak var progressView: UIProgressView!
    
    private var onCancelAction: (() -> Void)?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
    }

    override func prepareForReuse() {
        super.prepareForReuse()
        onCancelAction = nil
    }
    
    func configure(with video: Video, onCancel: @escaping () -> Void) {
        nameFileLabel.text = video.fileName
        urlDetailLabel.text = video.url.absoluteString
        onCancelAction = onCancel
        progressView.progress = 0
    }
    
    func setProgress(_ progress: Float) {
        progressView.progress = progress
    }
    
    @IBAction func actionCancelDownload(_ sender: UIButton) {
        onCancelAction?()
    }
}
