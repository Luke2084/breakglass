//
//  MuteButton.swift
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

class MuteButton: UIView {
    let title = GlyphixTextLabel().then {
        $0.isBlurEffectEnabled = true
        $0.countsDown = true
        $0.font = .rounded(ofTextStyle: .body, weight: .bold)
        $0.textColor = .label
        $0.numberOfLines = 0
    }

    var onRemoval: (() -> Void) = {}

    init() {
        super.init(frame: .zero)

        let button = BreakGlassButtonView {
            MarginView(title)
        }
        addSubview(button)
        button.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }

        button.onBreak = {
            print("[*] toggle mute status")
            BackgroundMusic.shared.isMuted.toggle()
            self.updateMuteTitle()
        }

        button.onRemoval = { [weak self] in
            self?.onRemoval()
        }

        updateMuteTitle()
    }

    @available(*, unavailable)
    required init?(coder _: NSCoder) {
        fatalError()
    }

    func updateMuteTitle() {
        title.text = BackgroundMusic.shared.isMuted ? "🔊" : "🔇"
    }
}
