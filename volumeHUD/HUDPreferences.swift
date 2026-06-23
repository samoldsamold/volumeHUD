//
//  HUDPreferences.swift
//  by Danny Stewart (2025)
//  MIT License
//  https://github.com/dannystewart/volumeHUD
//

import CoreGraphics
import Foundation

enum HUDPreferences {
    static let sizeKey = "hudSize"
    static let verticalPositionKey = "hudVerticalPosition"
    static let opacityKey = "hudOpacity"
    static let glassEffectEnabledKey = "hudGlassEffectEnabled"

    static let defaultSize = 0.3
    static let defaultVerticalPosition = 0.5
    static let defaultOpacity = 1.0
    static let defaultGlassEffectEnabled = true
    static let minimumSize = 0.2
    static let maximumSize = 1.0
    static let minimumOpacity = 0.2
    static let defaultWindowSideLength: CGFloat = 200
    static let originalAuthorDefaultSize = defaultSize
    static let originalAuthorDefaultOpacity = defaultOpacity
    static let originalAuthorDefaultGlassEffectEnabled = false
    static let originalAuthorVolumeHUDFollowsMouse = true

    private static let originalAuthorWindowOriginRatio: CGFloat = 0.17

    static func storedSize(defaults: UserDefaults = .standard) -> Double {
        guard defaults.object(forKey: sizeKey) != nil else {
            return defaultSize
        }

        return clampedSize(defaults.double(forKey: sizeKey))
    }

    static func storedVerticalPosition(defaults: UserDefaults = .standard) -> Double {
        guard defaults.object(forKey: verticalPositionKey) != nil else {
            return defaultVerticalPosition
        }

        return clampedVerticalPosition(defaults.double(forKey: verticalPositionKey))
    }

    static func storedOpacity(defaults: UserDefaults = .standard) -> Double {
        guard defaults.object(forKey: opacityKey) != nil else {
            return defaultOpacity
        }

        return clampedOpacity(defaults.double(forKey: opacityKey))
    }

    static func storedGlassEffectEnabled(defaults: UserDefaults = .standard) -> Bool {
        guard defaults.object(forKey: glassEffectEnabledKey) != nil else {
            return defaultGlassEffectEnabled
        }

        return defaults.bool(forKey: glassEffectEnabledKey)
    }

    static func clampedSize(_ value: Double) -> Double {
        min(max(value, minimumSize), maximumSize)
    }

    static func clampedVerticalPosition(_ value: Double) -> Double {
        min(max(value, 0.0), 1.0)
    }

    static func clampedOpacity(_ value: Double) -> Double {
        min(max(value, minimumOpacity), 1.0)
    }

    static func originalAuthorVerticalPosition(
        screenHeight: CGFloat,
        windowHeight: CGFloat,
    ) -> Double {
        guard screenHeight > 0 else {
            return defaultVerticalPosition
        }

        let centerY = screenHeight * originalAuthorWindowOriginRatio + windowHeight / 2
        return clampedVerticalPosition(Double(centerY / screenHeight))
    }

    static func windowSize(size: Double) -> CGSize {
        let sideLength = windowSideLength(size: size)
        return CGSize(width: sideLength, height: sideLength)
    }

    static func windowSideLength(size: Double) -> CGFloat {
        defaultWindowSideLength * CGFloat(clampedSize(size) / defaultSize)
    }

    static func windowRect(
        screenFrame: CGRect,
        windowSize: CGSize,
        verticalPosition: Double,
    ) -> CGRect {
        CGRect(
            x: screenFrame.origin.x + (screenFrame.width - windowSize.width) / 2,
            y: windowOriginY(
                screenOriginY: screenFrame.origin.y,
                screenHeight: screenFrame.height,
                windowHeight: windowSize.height,
                verticalPosition: verticalPosition,
            ),
            width: windowSize.width,
            height: windowSize.height,
        )
    }

    static func windowOriginY(
        screenOriginY: CGFloat,
        screenHeight: CGFloat,
        windowHeight: CGFloat,
        verticalPosition: Double,
    ) -> CGFloat {
        let clampedPosition = CGFloat(clampedVerticalPosition(verticalPosition))
        let rawOriginY = screenOriginY + screenHeight * clampedPosition - windowHeight / 2
        let minimumOriginY = screenOriginY
        let maximumOriginY = screenOriginY + max(0, screenHeight - windowHeight)

        return min(max(rawOriginY, minimumOriginY), maximumOriginY)
    }
}
