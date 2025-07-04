//
//  DownloadedVideoTableViewCell.swift
//  TestValidateApp
//
//  Created by Linh Phan on 2/7/25.
//

import UIKit

@objc class DownloadedVideoTableViewCell: UITableViewCell {
    
    @IBOutlet weak var imgThumb: UIImageView!
    @IBOutlet weak var lblTitleVideo: UILabel!
    @IBOutlet weak var progressView: UIProgressView!
    @IBOutlet weak var btnCancelDownload: UIButton!
    @IBAction func btnCancelDownloadAction(_ sender: UIButton) {
        self.ifCancel()
    }
    
    // MARK: Variables
    var ifCancel:()->() = {}
    // MARK: Functions
    
    func config(with item: DownloadItem) {
        self.lblTitleVideo.text = item.urlString
        if let thumbnailData = item.thumbnailData {
            self.imgThumb.image = UIImage(data: thumbnailData)
        }
        
        if item.isCompleted {
            self.btnCancelDownload.isHidden = true
            self.progressView.isHidden = true
            self.progressView.setProgress(1.0, animated: false)
        } else {
            self.btnCancelDownload.isHidden = false
            self.progressView.isHidden = false
            self.progressView.setProgress(Float(item.progress), animated: true)
        }
    }

    func updateProgress(_ progress: Double, completed: Bool) {
        self.btnCancelDownload.isHidden = false
        self.progressView.isHidden = false
        self.progressView.setProgress(Float(progress), animated: true)
        
        if completed {
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                self.progressView.isHidden = true
                self.btnCancelDownload.isHidden = true
            }
        }
    }


    
    // MARK: Life circle & overrides
    
    override func prepareForReuse() {
        super.prepareForReuse()
        self.progressView.progress = 0
        self.progressView.isHidden = false
        self.lblTitleVideo.text = nil
    }

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
