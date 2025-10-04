//
//  BreakGlassButtonView.swift
//  BreakGlass
//
//  Created by qaq on 4/10/2025.
//

import Foundation
import SnapKit
import UIEffectKit
import UIKit

class BreakGlassButtonView: UIView {
    let liquidContainer = LiquidContainer.make()

    private(set) var breakingTextures: [UIImage] = BrokenGlassTexture.shared.generateEffectSequence()
    private var currentTextureIndex: Int = 0 {
        didSet { drawContainer.currentTextureIndex = currentTextureIndex }
    }

    private var isResolvingBreak = false

    private let drawContainer = BreakGlassTextureDrawingView()

    var onTap: () -> Void = {}
    var onBreak: (() -> Void) = {}
    var onRemoval: (() -> Void) = {}

    init(_ buildContent: () -> UIView? = { nil }) {
        super.init(frame: .zero)

        isUserInteractionEnabled = true

        addSubview(liquidContainer)
        liquidContainer.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }

        if let content = buildContent() {
            liquidContainer.contentView.addSubview(content)
            content.snp.makeConstraints { make in
                make.edges.equalToSuperview()
            }
        }

        drawContainer.backgroundColor = .clear
        liquidContainer.contentView.addSubview(drawContainer)
        drawContainer.snp.makeConstraints { make in
            make.edges.equalToSuperview()
        }

        drawContainer.textures = breakingTextures

        let tapGesture = UITapGestureRecognizer(
            target: self,
            action: #selector(handleTap)
        )
        addGestureRecognizer(tapGesture)
    }

    @available(*, unavailable)
    required init?(coder _: NSCoder) {
        fatalError()
    }

    override func layoutSubviews() {
        super.layoutSubviews()
        liquidContainer.layer.cornerRadius = min(
            liquidContainer.frame.width,
            liquidContainer.frame.height
        ) / 2
    }

    @objc func handleTap() {
        guard !isResolvingBreak else { return }

        SoundEffect.shared.playGlassBreak()
        let haptic = UIImpactFeedbackGenerator(style: .rigid)
        haptic.impactOccurred()
        onTap()

        let breakCount = breakingTextures.count

        if breakCount == 0 {
            triggerBreak()
            return
        }

        currentTextureIndex = min(currentTextureIndex + 1, breakCount)
        if currentTextureIndex >= breakCount {
            triggerBreak()
        } else {
            drawContainer.setNeedsDisplay()
        }
    }

    func triggerBreak() {
        guard !isResolvingBreak else { return }
        isResolvingBreak = true

        currentTextureIndex = breakingTextures.count
        drawContainer.setNeedsDisplay()
        removeFromSuperviewWithBreakGlassTransition(fractureCount: 80)
        onBreak()

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            self.breakingTextures.removeAll()
        }
    }

    override func removeFromSuperview() {
        super.removeFromSuperview()
        onRemoval()
    }
}

private enum LiquidContainer {
    static func make() -> UIVisualEffectView {
        let glassEffect = UIGlassEffect()
        glassEffect.isInteractive = true
        let effectView = UIVisualEffectView(effect: glassEffect)
        effectView.clipsToBounds = true
        return effectView
    }
}

private final class BreakGlassTextureDrawingView: UIView {
    var textures: [UIImage] = [] {
        didSet { setNeedsDisplay() }
    }

    var currentTextureIndex: Int = 0 {
        didSet { setNeedsDisplay() }
    }

    override func draw(_ rect: CGRect) {
        super.draw(rect)

        guard rect.width > 0, rect.height > 0 else { return }
        guard let context = UIGraphicsGetCurrentContext() else { return }

        context.setBlendMode(.plusLighter)

        let upperBound = min(currentTextureIndex, textures.count)
        guard upperBound > 0 else { return }

        for index in 0 ..< upperBound {
            let texture = textures[index]
            let textureSize = texture.size
            guard textureSize.width > 0, textureSize.height > 0 else { continue }

            let scaleX = rect.width / textureSize.width
            let scaleY = rect.height / textureSize.height
            let scale = max(scaleX, scaleY)

            let scaledSize = CGSize(
                width: textureSize.width * scale,
                height: textureSize.height * scale
            )

            let drawRect = CGRect(
                x: rect.midX - scaledSize.width / 2,
                y: rect.midY - scaledSize.height / 2,
                width: scaledSize.width,
                height: scaledSize.height
            )

            texture.draw(in: drawRect)
        }
    }
}
