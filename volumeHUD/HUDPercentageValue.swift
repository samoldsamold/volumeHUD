//
//  HUDPercentageValue.swift
//  by Danny Stewart (2025)
//  MIT License
//  https://github.com/dannystewart/volumeHUD
//

import Foundation

enum HUDPercentageValue {
    static func displayedPercent(for unitValue: Double) -> Double {
        (unitValue * 100).rounded()
    }

    static func unitValue(fromDisplayedPercent displayedPercent: Double, range: ClosedRange<Double>) -> Double {
        let unitValue = displayedPercent.rounded() / 100
        return min(max(unitValue, range.lowerBound), range.upperBound)
    }
}
