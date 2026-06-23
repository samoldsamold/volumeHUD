import CoreGraphics
import Foundation

struct TestFailure: Error, CustomStringConvertible {
    let description: String
}

func assertEqual(_ actual: Double, _ expected: Double, _ message: String, tolerance: Double = 0.0001) throws {
    if abs(actual - expected) > tolerance {
        throw TestFailure(description: "\(message): expected \(expected), got \(actual)")
    }
}

func assertEqual(_ actual: CGFloat, _ expected: CGFloat, _ message: String, tolerance: CGFloat = 0.0001) throws {
    if abs(actual - expected) > tolerance {
        throw TestFailure(description: "\(message): expected \(expected), got \(actual)")
    }
}

func assertEqual(_ actual: Bool, _ expected: Bool, _ message: String) throws {
    if actual != expected {
        throw TestFailure(description: "\(message): expected \(expected), got \(actual)")
    }
}

func run(_ name: String, _ test: () throws -> Void) rethrows {
    try test()
    print("PASS: \(name)")
}

func makeDefaults() -> UserDefaults {
    let suiteName = "volumeHUD.HUDPreferencesTests.\(UUID().uuidString)"
    guard let defaults = UserDefaults(suiteName: suiteName) else {
        fatalError("Could not create test UserDefaults suite")
    }
    defaults.removePersistentDomain(forName: suiteName)
    return defaults
}

@main
struct HUDPreferencesTests {
    static func main() {
        do {
            try run("default vertical position is centered") {
                try assertEqual(HUDPreferences.defaultVerticalPosition, 0.5, "default vertical position")
                let rect = HUDPreferences.windowRect(
                    screenFrame: CGRect(x: 0, y: 0, width: 1440, height: 900),
                    windowSize: CGSize(width: 200, height: 200),
                    verticalPosition: HUDPreferences.defaultVerticalPosition,
                )
                try assertEqual(rect.origin.x, 620, "centered x origin")
                try assertEqual(rect.origin.y, 350, "centered y origin")
            }

            try run("vertical position clamps to visible screen bounds") {
                let lowRect = HUDPreferences.windowRect(
                    screenFrame: CGRect(x: 10, y: 20, width: 1440, height: 900),
                    windowSize: CGSize(width: 200, height: 200),
                    verticalPosition: -0.5,
                )
                try assertEqual(lowRect.origin.y, 20, "low y is clamped to screen bottom")

                let highRect = HUDPreferences.windowRect(
                    screenFrame: CGRect(x: 10, y: 20, width: 1440, height: 900),
                    windowSize: CGSize(width: 200, height: 200),
                    verticalPosition: 1.5,
                )
                try assertEqual(highRect.origin.y, 720, "high y is clamped to screen top")
            }

            try run("default opacity is fully opaque") {
                try assertEqual(HUDPreferences.defaultOpacity, 1.0, "default opacity")
            }

            try run("default HUD size keeps current 200 px window at 30 percent") {
                try assertEqual(HUDPreferences.defaultSize, 0.3, "default size")
                try assertEqual(HUDPreferences.windowSideLength(size: HUDPreferences.defaultSize), 200, "default side length")
            }

            try run("original author defaults restore lower HUD placement") {
                try assertEqual(HUDPreferences.originalAuthorDefaultSize, 0.3, "original default size")
                try assertEqual(HUDPreferences.originalAuthorDefaultOpacity, 1.0, "original default opacity")
                try assertEqual(HUDPreferences.originalAuthorDefaultGlassEffectEnabled, false, "original glass effect")
                try assertEqual(HUDPreferences.originalAuthorVolumeHUDFollowsMouse, true, "original follows mouse")

                let verticalPosition = HUDPreferences.originalAuthorVerticalPosition(
                    screenHeight: 900,
                    windowHeight: 200,
                )
                try assertEqual(verticalPosition, 253.0 / 900.0, "original vertical center")

                let rect = HUDPreferences.windowRect(
                    screenFrame: CGRect(x: 0, y: 0, width: 1440, height: 900),
                    windowSize: CGSize(width: 200, height: 200),
                    verticalPosition: verticalPosition,
                )
                try assertEqual(rect.origin.y, 153, "original y origin")
            }

            try run("HUD size scales relative to current 30 percent baseline") {
                try assertEqual(HUDPreferences.windowSideLength(size: 0.6), 400, "60 percent side length")
            }

            try run("HUD size clamps to supported range") {
                try assertEqual(HUDPreferences.clampedSize(-0.1), 0.2, "below minimum size")
                try assertEqual(HUDPreferences.clampedSize(1.5), 1.0, "above maximum size")
            }

            try run("opacity clamps to supported range") {
                try assertEqual(HUDPreferences.clampedOpacity(-0.2), 0.2, "below minimum opacity")
                try assertEqual(HUDPreferences.clampedOpacity(0.1), 0.2, "minimum opacity")
                try assertEqual(HUDPreferences.clampedOpacity(0.55), 0.55, "middle opacity")
                try assertEqual(HUDPreferences.clampedOpacity(1.4), 1.0, "above maximum opacity")
            }

            try run("stored preferences return defaults when unset") {
                let defaults = makeDefaults()
                try assertEqual(HUDPreferences.storedSize(defaults: defaults), 0.3, "stored default size")
                try assertEqual(HUDPreferences.storedVerticalPosition(defaults: defaults), 0.5, "stored default vertical position")
                try assertEqual(HUDPreferences.storedOpacity(defaults: defaults), 1.0, "stored default opacity")
                try assertEqual(HUDPreferences.storedGlassEffectEnabled(defaults: defaults), true, "stored default glass effect")
            }

            try run("stored preferences clamp persisted values") {
                let defaults = makeDefaults()
                defaults.set(1.5, forKey: HUDPreferences.sizeKey)
                defaults.set(-0.5, forKey: HUDPreferences.verticalPositionKey)
                defaults.set(0.05, forKey: HUDPreferences.opacityKey)

                try assertEqual(HUDPreferences.storedSize(defaults: defaults), 1.0, "stored size clamps high")
                try assertEqual(HUDPreferences.storedVerticalPosition(defaults: defaults), 0.0, "stored vertical position clamps low")
                try assertEqual(HUDPreferences.storedOpacity(defaults: defaults), 0.2, "stored opacity clamps low")
            }

            try run("stored glass effect honors explicit false") {
                let defaults = makeDefaults()
                defaults.set(false, forKey: HUDPreferences.glassEffectEnabledKey)

                try assertEqual(HUDPreferences.storedGlassEffectEnabled(defaults: defaults), false, "stored glass effect false")
            }

            print("All HUDPreferences tests passed.")
        } catch {
            print("FAIL: \(error)")
            exit(1)
        }
    }
}
