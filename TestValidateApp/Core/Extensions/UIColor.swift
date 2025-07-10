//
//  UIColor.swift
//  TestValidateApp
//
//  Created by Nguyen Hai Nam on 10/7/25.
//

import UIKit

public extension UIColor {
    @objc convenience init(red: Int, green: Int, blue: Int) {
        assert(red >= 0 && red <= 255, "Invalid red component")
        assert(green >= 0 && green <= 255, "Invalid green component")
        assert(blue >= 0 && blue <= 255, "Invalid blue component")
        
        self.init(red: CGFloat(red) / 255.0, green: CGFloat(green) / 255.0, blue: CGFloat(blue) / 255.0, alpha: 1.0)
    }
    
    @objc convenience init(rgb: Int) {
        self.init(
            red: (rgb >> 16) & 0xFF,
            green: (rgb >> 8) & 0xFF,
            blue: rgb & 0xFF
        )
    }
    
    convenience init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int = UInt64()
        Scanner(string: hex).scanHexInt64(&int)
        let alphaColr: UInt64
        let redColr: UInt64
        let greenColr: UInt64
        let blueColr: UInt64
        
        switch hex.count {
        case 3: // RGB (12-bit)
            (alphaColr, redColr, greenColr, blueColr) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6: // RGB (24-bit)
            (alphaColr, redColr, greenColr, blueColr) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8: // ARGB (32-bit)
            (alphaColr, redColr, greenColr, blueColr) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (alphaColr, redColr, greenColr, blueColr) = (255, 0, 0, 0)
        }
        self.init(red: CGFloat(redColr) / 255, green: CGFloat(greenColr) / 255, blue: CGFloat(blueColr) / 255, alpha: CGFloat(alphaColr) / 255)
    }
}
