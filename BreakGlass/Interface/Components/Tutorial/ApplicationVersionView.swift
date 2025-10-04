//
//  ApplicationVersionView.swift
//  BreakGlass
//
//  Created by qaq on 4/10/2025.
//

import Foundation
import UIKit

class ApplicationVersionView: UILabel {
    init() {
        super.init(frame: .zero)
        let bundle = Bundle.main
        let version = bundle.object(forInfoDictionaryKey: "CFBundleShortVersionString") as? String ?? "?.?"
        let build = bundle.object(forInfoDictionaryKey: "CFBundleVersion") as? String ?? "?"
        text = "\(version).\(build)"
        font = .rounded(ofTextStyle: .footnote, weight: .semibold)
        textColor = .secondaryLabel
    }

    @available(*, unavailable)
    required init?(coder _: NSCoder) {
        fatalError()
    }
}
