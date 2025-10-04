//
//  Ext+Fonts.swift
//  TrollNFC
//
//  Created by 秋星桥 on 6/5/25.
//

import UIKit

extension UIFont {
    static let title: UIFont = .preferredFont(forTextStyle: .title3)
    static let body: UIFont = .preferredFont(forTextStyle: .body)
    static let headline: UIFont = .preferredFont(forTextStyle: .headline)
    static let footnote: UIFont = .preferredFont(forTextStyle: .footnote)
}

extension UIFont {
    class func rounded(ofSize size: CGFloat, weight: UIFont.Weight) -> UIFont {
        let systemFont = UIFont.systemFont(ofSize: size, weight: weight)
        let font: UIFont = if let descriptor = systemFont.fontDescriptor.withDesign(.rounded) {
            UIFont(descriptor: descriptor, size: size)
        } else {
            systemFont
        }
        return font
    }

    class func rounded(ofTextStyle textStyle: TextStyle, weight: UIFont.Weight) -> UIFont {
        let systemFont = UIFont.preferredFont(forTextStyle: textStyle).withWeight(weight)
        let font: UIFont = if let descriptor = systemFont.fontDescriptor.withDesign(.rounded) {
            UIFont(descriptor: descriptor, size: systemFont.pointSize)
        } else {
            systemFont
        }
        return font
    }

    var semibold: UIFont {
        withWeight(.semibold)
    }

    var medium: UIFont {
        withWeight(.medium)
    }

    func withWeight(_ weight: UIFont.Weight) -> UIFont {
        let newDescriptor = fontDescriptor.addingAttributes([.traits: [UIFontDescriptor.TraitKey.weight: weight]])
        return UIFont(descriptor: newDescriptor, size: pointSize)
    }
}
