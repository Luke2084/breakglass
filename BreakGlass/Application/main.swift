//
//  main.swift
//  BreakGlass
//
//  Created by qaq on 4/10/2025.
//

import UIKit

@_exported import SnapKit
@_exported import SwifterSwift
@_exported import Then

MainActor.assumeIsolated {
    _ = BrokenGlassTexture.shared
    _ = GameStatus.shared
    _ = BackgroundMusic.shared
    _ = SoundEffect.shared
}

_ = UIApplicationMain(
    CommandLine.argc,
    CommandLine.unsafeArgv,
    nil,
    NSStringFromClass(AppDelegate.self)
)
