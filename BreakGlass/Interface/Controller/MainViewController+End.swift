//
//  MainViewController+End.swift
//  BreakGlass
//
//  Created by qaq on 4/10/2025.
//

import ConfettiView
import SnapKit
import UIKit

extension MainViewController {
    func presentGameOver(details: GameStatus.Details) {
        inGameView?.removeFromSuperviewWithBreakGlassTransition()
        inGameView = nil

        SoundEffect.shared.playGameOver()

        if details.isHighScore {
            let confettiView = ConfettiView()
            view.addSubview(confettiView)
            confettiView.snp.makeConstraints { make in
                make.edges.equalToSuperview()
            }
            view.layoutIfNeeded()
            confettiView.emit(
                with: [
                    .shape(.circle, .systemRed.withAlphaComponent(0.5)),
                    .shape(.circle, .systemGreen.withAlphaComponent(0.5)),
                    .shape(.circle, .systemBlue.withAlphaComponent(0.5)),
                ],
                for: 3
            ) { _ in
                confettiView.removeFromSuperview()
            }
        }

        let gameOverView = GameOverView(details: details)
        defer { self.gameOverView = gameOverView }
        view.addSubview(gameOverView)
        gameOverView.snp.makeConstraints { make in
            make.center.equalToSuperview()
            make.left.right.equalTo(view.safeAreaLayoutGuide).inset(32)
        }
    }
}
