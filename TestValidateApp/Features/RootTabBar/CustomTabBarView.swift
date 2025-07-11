//
//  CustomTabBarView.swift
//  TestValidateApp
//
//  Created by Nguyen Nam on 10/7/25.
//

import UIKit

protocol CustomTabBarViewDelegate: AnyObject {
    func tabBarView(_ tabBarView: CustomTabBarView, didSelectTabAt index: Int)
}

class CustomTabBarView: UIView {
    @IBOutlet weak var backgroundView: UIView!
    @IBOutlet weak var leftIcon: UIImageView!
    @IBOutlet weak var leftLabel: UILabel!
    @IBOutlet weak var rightIcon: UIImageView!
    @IBOutlet weak var rightLabel: UILabel!
    
    private var listSelectView: [[UIView]] = [[], []]
    
    weak var delegate: CustomTabBarViewDelegate?
    private var selectedIndex = 0
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        backgroundView.roundCorners(corners: [.layerMinXMinYCorner, .layerMaxXMinYCorner], radius: 16)
        leftLabel.font = HNFont.captionEmphasized.font
        rightLabel.font = HNFont.captionEmphasized.font
        listSelectView[0] = [leftIcon, leftLabel]
        listSelectView[1] = [rightIcon, rightLabel]
        updateSelection(selectedIndex: selectedIndex)
    }
    
    private func updateSelection(selectedIndex: Int) {
        self.selectedIndex = selectedIndex
        
        listSelectView[selectedIndex].forEach { view in
            if let label = view as? UILabel {
                label.textColor = .white
            } else if let imageView = view as? UIImageView {
                imageView.tintColor = .white
            }
        }
        
        listSelectView[1 - selectedIndex].forEach { view in
            if let label = view as? UILabel {
                label.textColor = HNColor.Text.default
            } else if let imageView = view as? UIImageView {
                imageView.tintColor = HNColor.Icon.default
            }
        }
    }
    @IBAction func leftButtonTapped(_ sender: Any) {
        delegate?.tabBarView(self, didSelectTabAt: 0)
        updateSelection(selectedIndex: 0)
    }
    
    @IBAction func rightButtonTapped(_ sender: Any) {
        delegate?.tabBarView(self, didSelectTabAt: 1)
        updateSelection(selectedIndex: 1)
    }
    
}
