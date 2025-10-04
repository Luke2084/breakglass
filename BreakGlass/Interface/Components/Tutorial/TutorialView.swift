//
//  TutorialView.swift
//  BreakGlass
//
//  Created by qaq on 4/10/2025.
//

import Foundation
import GlyphixTextFx
import SnapKit
import UIKit

private enum Status: Int {
    case hello
    case youShouldTap
    case keepIt
    case wow
}

private extension Status {
    var text: String {
        switch self {
        case .hello: String(localized: "So you dont like Liquid Glass?")
        case .youShouldTap: String(localized: "Alright, tap the glass to break it. 💥")
        case .keepIt: String(localized: "It's breaking...!")
        case .wow: String(localized: "WoW! 🎉")
        }
    }
}

class TutorialView: UIView {
    var onComplete: (() -> Void) = {}

    private var showLiquidButton: Bool = false {
        didSet {
            guard oldValue != showLiquidButton else { return }
            UIView.animate(springDuration: 0.5) {
                mainButton.snp.remakeConstraints { make in
                    make.center.equalToSuperview()
                    make.width.height.equalTo(self.showLiquidButton ? 128 : 0)
                }
                self.layoutIfNeeded()
            }
        }
    }

    private var status: Status = .hello {
        didSet {
            label.text = status.text
            showLiquidButton = status.rawValue >= Status.youShouldTap.rawValue
        }
    }

    let mainButton = BreakGlassButtonView()

    let tapToContinueLabel = GlyphixTextLabel().then {
        $0.isBlurEffectEnabled = true
        $0.countsDown = true
        $0.font = .rounded(ofTextStyle: .footnote, weight: .medium)
        $0.textColor = .secondaryLabel
        $0.text = ""
    }

    let label = GlyphixTextLabel().then {
        $0.isBlurEffectEnabled = true
        $0.countsDown = true
        $0.font = .rounded(ofTextStyle: .body, weight: .bold)
        $0.textColor = .label
        $0.numberOfLines = 0
    }

    init() {
        super.init(frame: .zero)

        mainButton.attachWiggleEffect()
        addSubview(mainButton)
        mainButton.snp.makeConstraints { make in
            make.center.equalToSuperview()
            make.width.equalTo(0)
            make.height.equalTo(0)
        }

        addSubview(label)
        label.snp.makeConstraints { make in
            make.left.right.equalToSuperview()
            make.top.equalTo(mainButton.snp.bottom).offset(32)
            make.centerY.equalToSuperview().priority(.low) // after glass removed
        }

        addSubview(tapToContinueLabel)
        tapToContinueLabel.snp.makeConstraints { make in
            make.left.right.equalToSuperview()
            make.top.equalTo(label.snp.bottom).offset(8)
        }

        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(handleTap))
        addGestureRecognizer(tapGesture)

        var mainButtonTapped = 0
        mainButton.onTap = { [weak self] in
            guard let self else { return }
            defer { mainButtonTapped += 1 }
            if status == .youShouldTap, mainButtonTapped > 0 {
                status = .keepIt
            }
        }

        mainButton.onRemoval = { [weak self] in
            guard let self else { return }
            UIView.animate(springDuration: 0.5) {
                self.layoutIfNeeded()
            }
        }

        mainButton.onBreak = { [weak self] in
            guard let self else { return }
            UIView.animate(springDuration: 0.5) {
                self.status = .wow
                self.layoutIfNeeded()
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                self.onComplete()
            }
        }

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            self.label.text = self.status.text
        }

        DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
            guard self.status == .hello else { return }
            self.tapToContinueLabel.text = String(localized: "Tap to continue 👆")
        }
    }

    @available(*, unavailable)
    required init?(coder _: NSCoder) {
        fatalError()
    }

    @objc private func tikNextIfPossible() {
        guard let next = Status(rawValue: status.rawValue + 1) else { return }
        status = next
    }

    @objc private func handleTap() {
        SoundEffect.shared.playTap()
        tapToContinueLabel.text = ""
        guard [.hello].contains(status) else { return }
        tikNextIfPossible()
    }
}
