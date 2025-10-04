//
//  MarginView.swift
//  BreakGlass
//
//  Created by qaq on 4/10/2025.
//

import SnapKit
import UIKit

private let defaultMargin = UIEdgeInsets(top: 16, left: 16, bottom: 16, right: 16)

class MarginView: UIView {
    init(_ content: UIView, inset: (inout UIEdgeInsets) -> Void = { _ in }) {
        super.init(frame: .zero)
        addSubview(content)
        var margin = defaultMargin
        inset(&margin)
        content.snp.makeConstraints { make in
            make.edges.equalToSuperview().inset(margin).priority(.low)
            make.center.equalToSuperview().priority(.high)
        }
    }

    @available(*, unavailable)
    required init?(coder _: NSCoder) {
        fatalError()
    }
}
