import CoreGraphics
import Foundation

struct TestFailure: Error, CustomStringConvertible {
    let description: String
}

func assertEqual<T: Equatable>(_ actual: T, _ expected: T, _ message: String) throws {
    if actual != expected {
        throw TestFailure(description: "\(message): expected \(expected), got \(actual)")
    }
}

func assertEqual(_ actual: CGFloat, _ expected: CGFloat, _ message: String, tolerance: CGFloat = 0.0001) throws {
    if abs(actual - expected) > tolerance {
        throw TestFailure(description: "\(message): expected \(expected), got \(actual)")
    }
}

func run(_ name: String, _ test: () throws -> Void) rethrows {
    try test()
    print("PASS: \(name)")
}

@main
struct HUDGlassStyleTests {
    static func main() {
        do {
            try run("glass style uses SwiftUI Liquid Glass renderer when enabled") {
                try assertEqual(
                    HUDGlassStyle.renderMode(glassEffectEnabled: true),
                    HUDGlassStyle.RenderMode.swiftUILiquidGlass,
                    "enabled glass renderer",
                )
                try assertEqual(
                    HUDGlassStyle.renderMode(glassEffectEnabled: false),
                    HUDGlassStyle.RenderMode.classicMaterial,
                    "disabled glass renderer",
                )
            }

            try run("glass corner radius scales with HUD size") {
                try assertEqual(HUDGlassStyle.cornerRadius(forHUDSize: 200), 16, "default corner radius")
                try assertEqual(HUDGlassStyle.cornerRadius(forHUDSize: 400), 32, "scaled corner radius")
            }

            print("All HUDGlassStyle tests passed.")
        } catch {
            print("FAIL: \(error)")
            exit(1)
        }
    }
}
