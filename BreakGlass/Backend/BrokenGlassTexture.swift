//
//  BrokenGlassTexture.swift
//  BreakGlass
//
//  Created by qaq on 4/10/2025.
//

import Foundation
import UIKit

private let textureNames = [
    "shattered-glass-texture",
    "broken-glass-texture-with-hole-shape",
]

private nonisolated let rgbColorSpace = CGColorSpaceCreateDeviceRGB()

@MainActor
class BrokenGlassTexture {
    static let shared = BrokenGlassTexture()

    private let processedTextures: [UIImage]

    private init() {
        let sourceTextures: [UIImage] = textureNames.compactMap {
            UIImage(named: $0)
        }
        assert(sourceTextures.count == textureNames.count)

        print("[*] \(sourceTextures.count) broken glass textures loaded")

        let processDate = Date()
        processedTextures = Self.processTextures(sourceTextures)
        let processInterval = Date().timeIntervalSince(processDate)
        print("[*] \(processedTextures.count) textures processed in \(processInterval) seconds.")
    }

    func generateEffectSequence() -> [UIImage] {
        var ans: [UIImage] = []
        for _ in 2 ... 5 {
            let index = Int.random(in: 0 ..< processedTextures.count)
            ans.append(processedTextures[index])
        }
        return ans
    }
}

nonisolated extension BrokenGlassTexture {
    private static func cutRandomRect(from image: UIImage, size: CGSize) -> UIImage? {
        let imageSize = image.size
        guard imageSize.width >= size.width, imageSize.height >= size.height else { return nil }
        let maxX = imageSize.width - size.width
        let maxY = imageSize.height - size.height
        let x = CGFloat.random(in: 0 ... maxX)
        let y = CGFloat.random(in: 0 ... maxY)
        let rect = CGRect(x: x, y: y, width: size.width, height: size.height)
        guard let cgImage = image.cgImage?.cropping(to: rect) else { return nil }
        return UIImage(cgImage: cgImage)
    }

    private static func rotate(image: UIImage, by angle: CGFloat) -> UIImage {
        let normalizedAngle = angle.truncatingRemainder(dividingBy: 360)
        if abs(normalizedAngle) <= 0.001 { return image }

        let radians = normalizedAngle * .pi / 180.0
        let rotatedSize = CGRect(origin: .zero, size: image.size)
            .applying(CGAffineTransform(rotationAngle: radians))
            .integral
            .size

        let format = UIGraphicsImageRendererFormat()
        format.scale = image.scale
        format.opaque = false

        let renderer = UIGraphicsImageRenderer(size: rotatedSize, format: format)
        return renderer.image { rendererContext in
            let context = rendererContext.cgContext
            context.translateBy(x: rotatedSize.width / 2, y: rotatedSize.height / 2)
            context.rotate(by: radians)
            let drawRect = CGRect(
                x: -image.size.width / 2,
                y: -image.size.height / 2,
                width: image.size.width,
                height: image.size.height
            )
            image.draw(in: drawRect)
        }
    }

    private static func image(_ image: UIImage, applyingAlpha alpha: CGFloat) -> UIImage {
        let format = UIGraphicsImageRendererFormat()
        format.scale = image.scale
        format.opaque = false

        let renderer = UIGraphicsImageRenderer(size: image.size, format: format)
        return renderer.image { _ in
            image.draw(at: .zero, blendMode: .normal, alpha: alpha)
        }
    }

    private static func resized(_ image: UIImage, to size: CGSize) -> UIImage {
        guard image.size != size else { return image }

        let rendererFormat = UIGraphicsImageRendererFormat()
        rendererFormat.scale = image.scale
        rendererFormat.opaque = false

        let renderer = UIGraphicsImageRenderer(size: size, format: rendererFormat)
        return renderer.image { _ in
            image.draw(in: CGRect(origin: .zero, size: size))
        }
    }

    static func processTextures(_ textures: [UIImage]) -> [UIImage] {
        guard !textures.isEmpty else { return [] }

        let requiredTextures = 128
        var processed: [UIImage] = []
        processed.reserveCapacity(requiredTextures)

        let baseCount = requiredTextures / textures.count
        let remainder = requiredTextures % textures.count

        let group = DispatchGroup()
        let groupAccess = NSLock()

        for (index, texture) in textures.enumerated() {
            let targetCount = baseCount + (index < remainder ? 1 : 0)
            guard targetCount > 0 else { continue }

            group.enter()
            DispatchQueue.global(qos: .userInitiated).async {
                defer { group.leave() }

                autoreleasepool {
                    var threadItems: [UIImage] = []
                    threadItems.reserveCapacity(targetCount)

                    for _ in 0 ..< targetCount {
                        let cut = cutRandomRect(from: texture, size: CGSize(width: 256, height: 256))
                        let baseImage = cut ?? resized(texture, to: CGSize(width: 256, height: 256))
                        let alpha = CGFloat.random(in: 0.5 ... 0.9)
                        let alphaApplied = image(baseImage, applyingAlpha: alpha)
                        threadItems.append(alphaApplied)
                    }

                    groupAccess.lock()
                    processed.append(contentsOf: threadItems)
                    groupAccess.unlock()
                }
            }
        }

        group.wait()

        return processed
    }
}
