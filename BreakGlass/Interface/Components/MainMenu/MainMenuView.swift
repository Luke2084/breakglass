//
//  MainMenuView.swift
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

class MainMenuView: UIStackView {
    let titleLabel = GlyphixTextLabel().then {
        $0.isBlurEffectEnabled = true
        $0.countsDown = true
        $0.font = .rounded(ofTextStyle: .largeTitle, weight: .bold)
        $0.textColor = .label
        $0.numberOfLines = 0
    }

    let optionStack = UIStackView().then {
        $0.axis = .horizontal
        $0.alignment = .center
        $0.distribution = .equalSpacing
        $0.spacing = 16
        $0.alpha = 0
    }

    let newGameButton = NewGameButton()
    var muteButton = MuteButton() // break and place a new one

    init() {
        super.init(frame: .zero)

        axis = .vertical
        alignment = .leading
        distribution = .equalSpacing
        spacing = 64

        optionStack.addArrangedSubview(newGameButton)
        optionStack.addArrangedSubview(muteButton)

        var muteButtonRemoval: (() -> Void)!
        muteButtonRemoval = { [weak self] in
            guard let self else { return }
            UIView.animate(springDuration: 0.5) {
                self.optionStack.layoutIfNeeded()
                self.layoutIfNeeded()
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                self.muteButton.removeFromSuperview()
                let newButton = MuteButton()
                newButton.onRemoval = muteButtonRemoval
                defer { self.muteButton = newButton }
                newButton.layoutIfNeeded()
                UIView.animate(springDuration: 0.5) {
                    self.optionStack.addArrangedSubview(newButton)
                    self.layoutIfNeeded()
                }
            }
        }
        muteButton.onRemoval = muteButtonRemoval

        attachWiggleEffect()

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            self.animateBegin()
        }
    }

    @available(*, unavailable)
    required init(coder _: NSCoder) {
        fatalError()
    }

    private func animateBegin() {
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.25) {
            self.addArrangedSubview(self.titleLabel)
            self.titleLabel.snp.makeConstraints { make in
                make.left.right.equalToSuperview()
            }
            UIView.animate(springDuration: 0.5) {
                self.titleLabel.text = String(localized: "Let's Break Glass 🎉")
                self.layoutIfNeeded()
            }
        }

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            self.addArrangedSubview(self.optionStack)
            self.optionStack.snp.makeConstraints { make in
                make.left.equalToSuperview()
            }
            UIView.animate(springDuration: 0.5) {
                self.optionStack.alpha = 1
                self.layoutIfNeeded()
            }
        }
    }
}
