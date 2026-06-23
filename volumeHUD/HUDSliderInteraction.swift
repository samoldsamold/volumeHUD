//
//  HUDSliderInteraction.swift
//  by Danny Stewart (2025)
//  MIT License
//  https://github.com/dannystewart/volumeHUD
//

import Foundation

enum HUDSliderInteraction {
    enum AdjustmentDirection {
        case increment
        case decrement
    }

    static let defaultStep: Double = 0.01

    static func value(
        forLocation xLocation: Double,
        trackWidth: Double,
        range: ClosedRange<Double>,
    ) -> Double {
        guard trackWidth > 0 else {
            return range.lowerBound
        }

        let ratio = min(max(xLocation / trackWidth, 0), 1)
        return range.lowerBound + ratio * (range.upperBound - range.lowerBound)
    }

    static func adjustedValue(
        _ value: Double,
        direction: AdjustmentDirection,
        range: ClosedRange<Double>,
        step: Double = defaultStep,
    ) -> Double {
        let delta: Double = direction == .increment ? step : -step
        return min(max(value + delta, range.lowerBound), range.upperBound)
    }
}
