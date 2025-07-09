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
    
    weak var delegate: CustomTabBarViewDelegate?
    private var selectedIndex = 0
    
    // init with xib
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        backgroundView.clipsToBounds = true
        backgroundView.layer.cornerRadius = 16
        backgroundView.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
    }

    
    private func updateSelection(selectedIndex: Int) {
        self.selectedIndex = selectedIndex
        
//        for (index, view) in stackView.arrangedSubviews.enumerated() {
//            if let button = view as? UIButton {
//                button.tintColor = index == selectedIndex ? .systemBlue : .systemGray
//            }
//        }
    }
}
