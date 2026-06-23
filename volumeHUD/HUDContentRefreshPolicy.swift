//
//  HUDContentRefreshPolicy.swift
//  by Danny Stewart (2025)
//  MIT License
//  https://github.com/dannystewart/volumeHUD
//

import CoreGraphics
import Foundation

enum HUDContentKind {
    case volume
    case brightness
}

struct HUDContentSnapshot: Equatable {
    let kind: HUDContentKind
    let windowSideLength: CGFloat
    let glassEffectEnabled: Bool
    let value: Float
    let isMuted: Bool
}

enum HUDContentRefreshPolicy {
    static let windowSideLengthTolerance: CGFloat = 0.5
    static let valueTolerance: Float = 0.0005

    static func shouldRefresh(previous: HUDContentSnapshot?, current: HUDContentSnapshot) -> Bool {
        guard let previous else {
            return true
        }

        if previous.kind != current.kind {
            return true
        }

        if abs(previous.windowSideLength - current.windowSideLength) > windowSideLengthTolerance {
            return true
        }

        if previous.glassEffectEnabled != current.glassEffectEnabled {
            return true
        }

        if abs(previous.value - current.value) > valueTolerance {
            return true
        }

        if current.kind == .volume, previous.isMuted != current.isMuted {
            return true
        }

        return false
    }
}
