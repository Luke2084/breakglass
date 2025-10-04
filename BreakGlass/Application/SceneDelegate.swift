//
//  SceneDelegate.swift
//  BreakGlass
//
//  Created by qaq on 4/10/2025.
//

import UIKit

class SceneDelegate: UIResponder, UIWindowSceneDelegate {
    var window: UIWindow?

    func scene(_ scene: UIScene, willConnectTo _: UISceneSession, options _: UIScene.ConnectionOptions) {
        guard let _ = (scene as? UIWindowScene) else { return }
    }

    func sceneDidDisconnect(_: UIScene) {}

    func sceneDidBecomeActive(_: UIScene) {
        BackgroundMusic.shared.handleAppDidBecomeActive()
    }

    func sceneWillResignActive(_: UIScene) {
        BackgroundMusic.shared.handleAppWillResignActive()
    }

    func sceneDidEnterBackground(_: UIScene) {
        BackgroundMusic.shared.handleAppDidEnterBackground()

        // Auto-end game when app enters background, but only if game has actually started
        DispatchQueue.main.async {
            let currentDetails = GameStatus.shared.currentDetails
            if currentDetails.gameStarted, !currentDetails.gameOver, currentDetails.lives > 0 {
                GameStatus.shared.forceGameOver()
            }
        }
    }
}
