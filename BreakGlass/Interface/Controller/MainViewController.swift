//
//  MainViewController.swift
//  BreakGlass
//
//  Created by qaq on 4/10/2025.
//

import ColorfulX
import Combine
import SnapKit
import UIEffectKit
import UIKit

class MainViewController: UIViewController {
    let backgroundView = AnimatedMulticolorGradientView().then { input in
        let colors: [UIColor] = [
            UIColor(red: 0.5, green: 0.5, blue: 0.5, alpha: 0.5),
            UIColor(red: 0.2, green: 0.2, blue: 0.3, alpha: 0.5),
            UIColor(red: 0.2, green: 0.2, blue: 0.4, alpha: 0.4),
            UIColor(red: 0.2, green: 0.2, blue: 0.5, alpha: 0.3),
            UIColor(red: 0.2, green: 0.2, blue: 0.6, alpha: 0.2),
            .clear,
        ]
        input.setColors(colors, animated: false)
        input.speed = 0.25
        input.noise = 32
        input.alpha = 0.75
    }

    let movingDots: MovingDotsView = .init()

    let footerView = FooterView()
    var mainMenuView: MainMenuView?
    var inGameView: InGameView?
    var gameOverView: GameOverView?

    private var cancellables = Set<AnyCancellable>()

    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = .systemGroupedBackground
        GameStatus.shared.eventsPublisher
            .sink { [weak self] event in
                guard let self else { return }
                processGameEvent(event)
            }
            .store(in: &cancellables)

        view.addSubview(backgroundView)
        backgroundView.snp.makeConstraints { make in
            make.edges.equalToSuperview().inset(-128)
        }
        view.addSubview(movingDots)
        movingDots.snp.makeConstraints { make in
            make.edges.equalToSuperview().inset(-128)
        }

        // initially we go through tutorial every time
        // trust me it's short
        let tutorialView = TutorialView()
        view.addSubview(tutorialView)
        view.addSubview(footerView)
        tutorialView.onComplete = {
            tutorialView.removeFromSuperviewWithBreakGlassTransition()
            self.completeTutorial()
        }

        tutorialView.snp.makeConstraints { make in
            make.width.height.equalTo(300)
            make.center.equalToSuperview()
        }

        footerView.snp.makeConstraints { make in
            make.bottom.equalTo(view.safeAreaLayoutGuide).inset(16)
            make.centerX.equalToSuperview()
        }
    }

    private func completeTutorial() {
        let mainMenuView = MainMenuView()
        defer { self.mainMenuView = mainMenuView }
        view.addSubview(mainMenuView)
        mainMenuView.snp.makeConstraints { make in
            make.left.right.equalTo(view.safeAreaLayoutGuide).inset(32)
            make.center.equalToSuperview()
        }
    }

    private func processGameEvent(_ event: GameStatus.Event) {
        print("[*] received event: \(event)")
        switch event {
        case .newGame:
            defer { self.mainMenuView = nil }
            mainMenuView?.removeFromSuperviewWithBreakGlassTransition()
            beginNewGame()
            UIView.animate(springDuration: 0.5) {
                self.footerView.alpha = 0
            }
        case let .gameOver(details):
            defer { self.inGameView = nil }
            inGameView?.removeFromSuperviewWithBreakGlassTransition()
            presentGameOver(details: details)
            UIView.animate(springDuration: 0.5) {
                self.footerView.alpha = 1
            }
        default: break
        }
    }
}
