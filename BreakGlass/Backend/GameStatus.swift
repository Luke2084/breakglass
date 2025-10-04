//
//  GameStatus.swift
//  BreakGlass
//
//  Created by qaq on 4/10/2025.
//

import Combine
import Foundation

private let highScoreStorageKey = "wiki.qaq.high.score"

@MainActor
class GameStatus {
    static let shared = GameStatus()

    enum Event {
        case newGame
        case gameOver(Details)
        case scoreUpdate(Details)
    }

    struct Details: Equatable, Codable {
        var beginTime: Date = .now
        var score: Int = 0
        var combo: Int = 0
        var maxCombo: Int = 0
        var maxLives: Int = 3
        var lives: Int = 3
        var isHighScore: Bool = false
        var gameStarted: Bool = false
        var gameOver: Bool = false
    }

    var highScore: Details = .init() {
        didSet {
            UserDefaults.standard.set(
                try? JSONEncoder().encode(highScore),
                forKey: highScoreStorageKey
            )
        }
    }

    private let eventsSubject = PassthroughSubject<Event, Never>()
    private var cancellables: Set<AnyCancellable> = []
    private var scoreDetails: Details = .init() {
        didSet {
            guard oldValue != scoreDetails else { return }
            send(.scoreUpdate(scoreDetails))
        }
    }

    let eventsPublisher: AnyPublisher<Event, Never>

    private init() {
        if let data = UserDefaults.standard.data(forKey: highScoreStorageKey),
           let savedHighScore = try? JSONDecoder().decode(Details.self, from: data)
        {
            highScore = savedHighScore
        }

        eventsPublisher = eventsSubject
            .receive(on: DispatchQueue.main) // must delay once
            .eraseToAnyPublisher()

        eventsPublisher
            .filter {
                if case .newGame = $0 { return true }
                return false
            }
            .sink { [weak self] _ in
                self?.scoreDetails = .init()
            }
            .store(in: &cancellables)

        eventsPublisher
            .filter {
                if case .gameOver = $0 { return true }
                return false
            }
            .sink { [weak self] _ in
                guard let self else { return }
                if scoreDetails.isHighScore {
                    highScore = scoreDetails
                }
            }
            .store(in: &cancellables)
    }

    func send(_ event: Event) {
        eventsSubject.send(event)
    }

    func requestGameReadyItems() {
        scoreDetails.beginTime = .now
        // when InGameView loads complete, send score details for the first time
        send(.scoreUpdate(scoreDetails)) // just make sure :)
    }
}

extension GameStatus {
    func hit() {
        scoreDetails.score += 1
        scoreDetails.combo += 1
        scoreDetails.maxCombo = max(scoreDetails.maxCombo, scoreDetails.combo)
    }

    func breakCombo() {
        scoreDetails.combo = 0
    }

    func miss() {
        breakCombo()
        scoreDetails.lives = max(0, scoreDetails.lives - 1)

        SoundEffect.shared.playLowBattery()

        if scoreDetails.lives <= 0 {
            scoreDetails.gameOver = true
            let isHighScore = scoreDetails.score > highScore.score
            scoreDetails.isHighScore = isHighScore
            send(.gameOver(scoreDetails))
        }
    }

    var currentDetails: Details {
        scoreDetails
    }

    func forceGameOver() {
        guard !scoreDetails.gameOver else { return }

        scoreDetails.gameOver = true
        let isHighScore = scoreDetails.score > highScore.score
        scoreDetails.isHighScore = isHighScore
        send(.gameOver(scoreDetails))
    }

    func markGameStarted() {
        scoreDetails.gameStarted = true
    }
}
