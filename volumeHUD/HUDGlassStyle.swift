//
//  HUDGlassStyle.swift
//  by Danny Stewart (2025)
//  MIT License
//  https://github.com/dannystewart/volumeHUD
//

import CoreGraphics

enum HUDGlassStyle {
    enum RenderMode {
        case swiftUILiquidGlass
        case classicMaterial
    }

    static let baselineHUDSize: CGFloat = 200
    static let baselineCornerRadius: CGFloat = 16

    static func renderMode(glassEffectEnabled: Bool) -> RenderMode {
        glassEffectEnabled ? .swiftUILiquidGlass : .classicMaterial
    }

    static func cornerRadius(forHUDSize hudSize: CGFloat) -> CGFloat {
        baselineCornerRadius * hudSize / baselineHUDSize
    }
}
