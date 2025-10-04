//
//  LicenseButtonView.swift
//  BreakGlass
//
//  Created by qaq on 4/10/2025.
//

import Foundation
import UIKit

class LicenseButtonView: UIButton {
    init() {
        super.init(frame: .zero)

        setTitle(String(localized: "Software Licenses  👀"), for: .normal)
        setTitleColor(.secondaryLabel, for: .normal)
        titleLabel?.font = .rounded(ofTextStyle: .footnote, weight: .semibold)

        addTarget(self, action: #selector(openLicensesController), for: .touchUpInside)
    }

    @available(*, unavailable)
    required init?(coder _: NSCoder) {
        fatalError()
    }

    @objc func openLicensesController() {
        let controller = LicenseViewController()
        parentViewController?.present(controller, animated: true)
    }
}
