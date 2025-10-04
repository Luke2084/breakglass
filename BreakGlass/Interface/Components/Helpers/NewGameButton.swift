//
//  NewGameButton.swift
//  BreakGlass
//
//  Created by qaq on 4/10/2025.
//

import Foundation
import GlyphixTextFx
import SnapKit
import SpringInterpolation
import SwifterSwift
import UIKit

class NewGameButton: UIView {
    let title = GlyphixTextLabel().then {
        $0.isBlurEffectEnabled = true
        $0.countsDown = true
        $0.font = .rounded(ofTextStyle: .body, weight: .bold)
        $0.textColor = .label
        $0.numberOfLines = 0
    }

    init() {
        super.init(frame: .zero)

        let button = BreakGlassButtonView {
            MarginView(title)
        }
        addSubview(button)
        button.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            self.title.text = String(localized: "👉 Start New Game")
        }

        button.onBreak = {
            print("[*] staring a new game!")
            GameStatus.shared.send(.newGame)
        }

        button.onRemoval = { [weak self] in
            UIView.animate(springDuration: 0.5) {
                self?.superview?.layoutIfNeeded()
            }
        }
    }

    @available(*, unavailable)
    required init?(coder _: NSCoder) {
        fatalError()
    }
}
