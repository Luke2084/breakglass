//
//  Ext+UIView.swift
//  BreakGlass
//
//  Created by qaq on 4/10/2025.
//

import UIEffectKit
import UIKit

public extension UIView {
    func removeFromSuperviewWithBreakGlassTransition(fractureCount: Int = 96) {
        guard superview != nil else {
            removeFromSuperview()
            return
        }

        let didStart = BreakGlassTransition.perform(
            on: self,
            fractureCount: fractureCount,
            onFirstFrame: { [weak self] in
                DispatchQueue.main.async { self?.removeFromSuperview() }
            },
            completion: nil
        )

        if didStart {
            SoundEffect.shared.playGlassBreak()
        } else {
            removeFromSuperview()
        }
    }
}

public extension UIView {
    func attachWiggleEffect(
        angleInDegrees: CGFloat = 2.5,
        translation: CGFloat = 3,
        duration: CFTimeInterval = 1.6
    ) {
        let animationKey = "wiggle"
        guard layer.animation(forKey: animationKey) == nil else {
            return
        }

        let angle = angleInDegrees * .pi / 180
        let frameCount = 121
        let phaseStep = (Double.pi * 2) / Double(frameCount - 1)
        let phases = Array(stride(from: 0.0, through: Double.pi * 2, by: phaseStep))

        let rotation = CAKeyframeAnimation(keyPath: "transform.rotation")
        rotation.values = phases.map { CGFloat(sin($0)) * angle }
        rotation.keyTimes = phases.enumerated().map { NSNumber(value: Double($0.offset) / Double(frameCount - 1)) }
        rotation.calculationMode = .linear
        rotation.isAdditive = true

        let horizontal = CAKeyframeAnimation(keyPath: "transform.translation.x")
        horizontal.values = phases.map { CGFloat(sin($0 + .pi / 2)) * translation }
        horizontal.keyTimes = rotation.keyTimes
        horizontal.calculationMode = .linear
        horizontal.isAdditive = true

        let group = CAAnimationGroup()
        group.animations = [rotation, horizontal]
        group.duration = duration
        group.repeatCount = .infinity
        group.isRemovedOnCompletion = false

        layer.add(group, forKey: animationKey)
    }
}
