//
//  HNFont.swift
//  TestValidateApp
//
//  Created by Nguyen Hai Nam on 10/7/25.
//

public enum HNFont {
    case captionRegular
    case captionEmphasized
    case helpTextRegular
    case helpTextEmphasized
    case subheadlineRegular
    case subheadlineEmphasized
    case subheadlineLink
    case bodyRegular
    case bodyEmphasized
    case bodyLink
    case headlineRegular
    case headlineEmphasized
    case title3Regular
    case title3Emphasized
    case title2Regular
    case title2Emphasized
    case title1Regular
    case title1Emphasized
    case largeTitleRegular
    case largeTitleEmphasized
}

public extension HNFont {
    var font: UIFont {
        switch self {
        case .captionRegular:
            return UIFont.systemFont(ofSize: 10, weight: .regular)
        case .captionEmphasized:
            return UIFont.systemFont(ofSize: 10, weight: .semibold)
        case .helpTextRegular:
            return UIFont.systemFont(ofSize: 12, weight: .regular)
        case .helpTextEmphasized:
            return UIFont.systemFont(ofSize: 12, weight: .semibold)
        case .subheadlineRegular:
            return UIFont.systemFont(ofSize: 14, weight: .regular)
        case .subheadlineEmphasized:
            return UIFont.systemFont(ofSize: 14, weight: .semibold)
        case .subheadlineLink:
            return UIFont.systemFont(ofSize: 14, weight: .regular)
        case .bodyRegular:
            return UIFont.systemFont(ofSize: 16, weight: .regular)
        case .bodyEmphasized:
            return UIFont.systemFont(ofSize: 16, weight: .semibold)
        case .bodyLink:
            return UIFont.systemFont(ofSize: 16, weight: .regular)
        case .headlineRegular:
            return UIFont.systemFont(ofSize: 18, weight: .regular)
        case .headlineEmphasized:
            return UIFont.systemFont(ofSize: 18, weight: .semibold)
        case .title3Regular:
            return UIFont.systemFont(ofSize: 20, weight: .regular)
        case .title3Emphasized:
            return UIFont.systemFont(ofSize: 20, weight: .semibold)
        case .title2Regular:
            return UIFont.systemFont(ofSize: 24, weight: .regular)
        case .title2Emphasized:
            return UIFont.systemFont(ofSize: 24, weight: .bold)
        case .title1Regular:
            return UIFont.systemFont(ofSize: 28, weight: .regular)
        case .title1Emphasized:
            return UIFont.systemFont(ofSize: 28, weight: .bold)
        case .largeTitleRegular:
            return UIFont.systemFont(ofSize: 32, weight: .regular)
        case .largeTitleEmphasized:
            return UIFont.systemFont(ofSize: 32, weight: .bold)
        }
    }
}
