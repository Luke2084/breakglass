//
//  BackgroundMusic.swift
//  BreakGlass
//
//  Created by qaq on 4/10/2025.
//

import AVFoundation
import Foundation

private let mutedKey = "BackgroundMusic.isMuted"

class BackgroundMusic {
    static let shared = BackgroundMusic()

    private var audioPlayer: AVAudioPlayer?
    private var isPlaying = false

    var isMuted: Bool {
        didSet {
            UserDefaults.standard.set(isMuted, forKey: mutedKey)
            if isMuted {
                pause()
            } else {
                play()
            }
        }
    }

    private init() {
        isMuted = UserDefaults.standard.bool(forKey: mutedKey)
        setupAudioSession()
        loadBackgroundMusic()
    }

    private func setupAudioSession() {
        do {
            try AVAudioSession.sharedInstance().setCategory(.playback, mode: .default, options: [.mixWithOthers])
            try AVAudioSession.sharedInstance().setActive(true)
        } catch {
            assertionFailure(error.localizedDescription)
        }
    }

    private func loadBackgroundMusic() {
        guard let url = Bundle.main.url(
            forResource: "background",
            withExtension: "mp3",
            subdirectory: "Sounds"
        ) else {
            assertionFailure()
            return
        }

        do {
            audioPlayer = try AVAudioPlayer(contentsOf: url)
            audioPlayer?.numberOfLoops = -1 // Loop indefinitely
            audioPlayer?.prepareToPlay()
        } catch {
            assertionFailure(error.localizedDescription)
        }
    }

    func play() {
        print("[*] background music calling:", #function)
        guard let player = audioPlayer, !isPlaying else { return }
        guard !isMuted else { return }
        player.play()
        isPlaying = true
    }

    func pause() {
        print("[*] background music calling:", #function)
        guard let player = audioPlayer, isPlaying else { return }
        player.pause()
        isPlaying = false
    }

    func stop() {
        print("[*] background music calling:", #function)
        guard let player = audioPlayer else { return }
        player.stop()
        player.currentTime = 0
        isPlaying = false
    }

    func handleAppDidBecomeActive() {
        play()
    }

    func handleAppDidEnterBackground() {
        pause()
    }

    func handleAppWillResignActive() {
        pause()
    }
}
