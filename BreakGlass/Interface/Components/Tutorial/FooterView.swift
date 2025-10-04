//
//  FooterView.swift
//  BreakGlass
//
//  Created by qaq on 4/10/2025.
//

import UIKit

class FooterView: UIStackView {
    init() {
        super.init(frame: .zero)
        axis = .horizontal
        alignment = .center
        distribution = .fill
        spacing = 8
        addArrangedSubview(ApplicationVersionView())
        addArrangedSubview(LicenseButtonView())
        alpha = 0.5
    }

    @available(*, unavailable)
    required init(coder _: NSCoder) {
        fatalError()
    }
}
