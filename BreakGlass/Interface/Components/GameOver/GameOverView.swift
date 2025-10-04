//
//  GameOverView.swift
//  BreakGlass
//
//  Created by qaq on 4/10/2025.
//

import GlyphixTextFx
import SnapKit
import SwifterSwift
import UIKit

class GameOverView: UIStackView {
    private let gameOverLabel = GlyphixTextLabel().then {
        $0.isBlurEffectEnabled = true
        $0.countsDown = true
        $0.font = .rounded(ofTextStyle: .title1, weight: .black)
        $0.textColor = .label
        $0.numberOfLines = 0
        $0.text = String(localized: "Game Over")
    }

    private let scoreLabel = GlyphixTextLabel().then {
        $0.isBlurEffectEnabled = true
        $0.countsDown = true
        $0.font = .rounded(ofTextStyle: .largeTitle, weight: .black)
        $0.textColor = .label
        $0.numberOfLines = 0
    }

    private let optionStack = UIStackView().then {
        $0.axis = .horizontal
        $0.alignment = .center
        $0.distribution = .equalSpacing
        $0.spacing = 16
    }

    var muteButton = MuteButton()

    init(details: GameStatus.Details) {
        super.init(frame: .zero)

        axis = .vertical
        alignment = .center
        distribution = .equalSpacing
        spacing = 16

        attachWiggleEffect()

        scoreLabel.text = String(localized: "\(details.score) Point(s)!")

        addArrangedSubview(gameOverLabel)
        addArrangedSubview(scoreLabel)

        addArrangedSubview(NewGameButton())
        addArrangedSubview(optionStack)

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
        optionStack.addArrangedSubview(muteButton)
    }

    @available(*, unavailable)
    required init(coder _: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
