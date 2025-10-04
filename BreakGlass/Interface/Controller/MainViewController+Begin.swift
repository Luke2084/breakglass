//
//  MainViewController+Begin.swift
//  BreakGlass
//
//  Created by qaq on 4/10/2025.
//

import SnapKit
import UIKit

extension MainViewController {
    func beginNewGame() {
        gameOverView?.removeFromSuperviewWithBreakGlassTransition()
        gameOverView = nil

        let inGameView = InGameView()
        defer { self.inGameView = inGameView }
        view.addSubview(inGameView)
        inGameView.snp.makeConstraints { make in
            make.edges.equalTo(view.safeAreaLayoutGuide)
        }

        GameStatus.shared.markGameStarted()
    }
}
