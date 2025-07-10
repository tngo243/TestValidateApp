//
//  HNColor.swift
//  TestValidateApp
//
//  Created by Nguyen Hai Nam on 10/7/25.
//

import UIKit

public enum HNColor {
    case neutral(Neutral)

    case brand(Brand)
    case gray(Gray)
    case orange(Orange)
    case yellow(Yellow)
    case red(Red)
    case green(Green)
    case blue(Blue)

    public enum Brand: Int  {
        case p50 = 0xE0F4F5
        case p100 = 0xC1EAEB
        case p200 = 0x91DADB
        case p300 = 0x60C9CB
        case p400 = 0x30B9BB
        case p500 = 0x00A9AC
        case p600 = 0x008789
        case p700 = 0x006567
        case p800 = 0x004344
        case p900 = 0x002122
    }

    public enum Gray: Int {
        case p50 = 0xF2F2F2
        case p100 = 0xDCDCDC
        case p200 = 0xC1C1C1
        case p300 = 0xA5A5A5
        case p400 = 0x8A8A8A
        case p500 = 0x6F6F6F
        case p600 = 0x585858
        case p700 = 0x424242
        case p800 = 0x2C2C2C
        case p900 = 0x161616
    }

    public enum Neutral {
        case black(Black)
        case white(White)

        public enum Black: CGFloat {
            case p100 = 1
            case p90 = 0.9
            case p80 = 0.8
            case p70 = 0.7
            case p60 = 0.6
            case p50 = 0.5
            case p40 = 0.4
            case p30 = 0.3
            case p20 = 0.2
            case p10 = 0.1
        }

        public enum White: CGFloat {
            case p100 = 1
            case p90 = 0.9
            case p80 = 0.8
            case p70 = 0.7
            case p60 = 0.6
            case p50 = 0.5
            case p40 = 0.4
            case p30 = 0.3
            case p20 = 0.2
            case p10 = 0.1
        }
    }

    public enum Orange: Int {
        case p50 = 0xFFF2E8
        case p100 = 0xFFE6D2
        case p200 = 0xFFCDA5
        case p300 = 0xFFB478
        case p400 = 0xFF9B4B
        case p500 = 0xFF821E
        case p600 = 0xCC6818
        case p700 = 0x994E12
        case p800 = 0x66340C
        case p900 = 0x321905
    }

    public enum Yellow: Int {
        case p50 = 0xFFFCF2
        case p100 = 0xFFF1C1
        case p200 = 0xFFE691
        case p300 = 0xFFDC60
        case p400 = 0xFFD130
        case p500 = 0xFFC700
        case p600 = 0xCC9F00
        case p700 = 0x997700
        case p800 = 0x664F00
        case p900 = 0x322700
    }

    public enum Red: Int {
        case p50 = 0xFCE6EA
        case p100 = 0xFACED6
        case p200 = 0xF59DAD
        case p300 = 0xF06C84
        case p400 = 0xEB3B5B
        case p500 = 0xE60A32
        case p600 = 0xB80828
        case p700 = 0x8A061E
        case p800 = 0x5C0414
        case p900 = 0x2D0109
    }

    public enum Green: Int {
        case p50 = 0xE5F8EB
        case p100 = 0xCCF1D8
        case p200 = 0x99E4B1
        case p300 = 0x66D68A
        case p400 = 0x33C963
        case p500 = 0x00BC3C
        case p600 = 0x009630
        case p700 = 0x007024
        case p800 = 0x004B18
        case p900 = 0x00250B
    }

    public enum Blue: Int {
        case p50 = 0xEAF0FF
        case p100 = 0xD5E1FF
        case p200 = 0xABC3FF
        case p300 = 0x82A6FF
        case p400 = 0x5888FF
        case p500 = 0x2F6BFF
        case p600 = 0x2555CC
        case p700 = 0x1C4099
        case p800 = 0x122A66
        case p900 = 0x091532
    }
}

// MARK: - Initializers
public extension HNColor {
    var color: UIColor {
        switch self {
        case .brand(let brand): .init(rgb: brand.rawValue)
        case .gray(let gray): .init(rgb: gray.rawValue)
        case .orange(let orange): .init(rgb: orange.rawValue)
        case .yellow(let yellow): .init(rgb: yellow.rawValue)
        case .red(let red): .init(rgb: red.rawValue)
        case .green(let green): .init(rgb: green.rawValue)
        case .blue(let blue): .init(rgb: blue.rawValue)
        case .neutral(let neutral): neutral.color
        }
    }
}

public extension HNColor.Neutral {
    var color: UIColor {
        switch self {
        case .black(let black):
                .black.withAlphaComponent(black.rawValue)
        case .white(let white):
                .white.withAlphaComponent(white.rawValue)
        }
    }
}

public extension HNColor {
    struct Text {
        public static let `default`   = HNColor.gray(.p900).color
        public static let subtle      = HNColor.gray(.p600).color
        public static let subtlest    = HNColor.gray(.p400).color
        public static let disabled    = HNColor.gray(.p200).color
        public static let inverse     = HNColor.neutral(.white(.p100)).color
        public static let brand       = HNColor.brand(.p600).color
        public static let danger      = HNColor.red(.p500).color
        public static let warning     = HNColor.orange(.p500).color
        public static let success     = HNColor.green(.p500).color
        public static let information = HNColor.blue(.p500).color
    }
    
    struct Icon {
        public static let onBackground = HNColor.gray(.p900).color
        public static let `default`    = HNColor.gray(.p500).color
        public static let subtle       = HNColor.gray(.p400).color
        public static let disabled     = HNColor.gray(.p200).color
        public static let inverse      = HNColor.neutral(.white(.p100)).color
        public static let brand        = HNColor.brand(.p600).color
        public static let danger       = HNColor.red(.p500).color
        public static let warning      = HNColor.orange(.p500).color
        public static let success      = HNColor.green(.p500).color
        public static let information  = HNColor.blue(.p500).color
    }
    
    struct Background {
        public static let disabled = HNColor.gray(.p100).color
        public static let `default` = HNColor.neutral(.white(.p100)).color
        public static let view = HNColor.gray(.p50).color
        public static let backdrop = HNColor.neutral(.black(.p60)).color
        
        public struct Brand {
            public static let `default` = HNColor.brand(.p50).color
            public static let pressed = HNColor.brand(.p100).color
            public static let boldDefault = HNColor.brand(.p600).color
            public static let boldPressed = HNColor.brand(.p700).color
        }
    }
    
    struct Border {
        public static let `default`    = HNColor.gray(.p100).color
        public static let disabled     = HNColor.gray(.p200).color
        public static let brand        = HNColor.brand(.p600).color
        public static let danger       = HNColor.red(.p500).color
        public static let warning      = HNColor.orange(.p500).color
        public static let success      = HNColor.green(.p500).color
        public static let information  = HNColor.blue(.p500).color
    }
}
        
