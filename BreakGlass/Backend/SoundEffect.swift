//
//  SoundEffect.swift
//  BreakGlass
//
//  Created by qaq on 4/10/2025.
//

import AVFoundation
import Foundation
import QuartzCore

private let glassBreakItemPrefix = "glass-break-"
private let glassBreakItemRange: ClosedRange<Int> = 1 ... 5
private let tapSound = "tap"
private let lowBatterySound = "low-battery"
private let gameOverSound = "game-over"

class SoundEffect {
    static let shared = SoundEffect()

    private var glassBreakDatas: [Data] = []
    private var tapData: Data?
    private var lowBatteryData: Data?
    private var gameOverData: Data?
    private var lastGlassBreakTime: CFTimeInterval?
    private var lastTapTime: CFTimeInterval?

    private init() {
        for i in glassBreakItemRange {
            let filename = "\(glassBreakItemPrefix)\(i)"
            if let data = loadSoundData(filename: filename) {
                glassBreakDatas.append(data)
            }
        }

        tapData = loadSoundData(filename: tapSound)
        lowBatteryData = loadSoundData(filename: lowBatterySound)
        gameOverData = loadSoundData(filename: gameOverSound)
    }

    private func loadSoundData(filename: String) -> Data? {
        if let url = Bundle.main.url(
            forResource: filename,
            withExtension: "mp3",
            subdirectory: "Sounds"
        ),
            let data = try? Data(contentsOf: url)
        {
            return data
        } else {
            assertionFailure("Failed to load sound: \(filename)")
            return nil
        }
    }

    private func playSound(data: Data?) {
        guard let data, let player = try? AVAudioPlayer(data: data) else { return }
        player.play()
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
            _ = player
        }
    }

    private func canPlay(lastTime: inout CFTimeInterval?, minInterval: CFTimeInterval) -> Bool {
        let now = CACurrentMediaTime()
        if let last = lastTime, now - last < minInterval { return false }
        lastTime = now
        return true
    }

    func playGlassBreak() {
        guard canPlay(lastTime: &lastGlassBreakTime, minInterval: 0.05) else { return }
        guard !glassBreakDatas.isEmpty else { return }
        let randomIndex = Int.random(in: 0 ..< glassBreakDatas.count)
        playSound(data: glassBreakDatas[randomIndex])
    }

    func playTap() {
        guard canPlay(lastTime: &lastTapTime, minInterval: 0.05) else { return }
        playSound(data: tapData)
    }

    func playLowBattery() {
        playSound(data: lowBatteryData)
    }

    func playGameOver() {
        playSound(data: gameOverData)
    }
}
