import CoreGraphics
import Foundation

struct TestFailure: Error, CustomStringConvertible {
    let description: String
}

func assertEqual(_ actual: CGFloat, _ expected: CGFloat, _ message: String, tolerance: CGFloat = 0.0001) throws {
    if abs(actual - expected) > tolerance {
        throw TestFailure(description: "\(message): expected \(expected), got \(actual)")
    }
}

func assertGreaterThan(_ actual: CGFloat, _ minimum: CGFloat, _ message: String) throws {
    if actual <= minimum {
        throw TestFailure(description: "\(message): expected > \(minimum), got \(actual)")
    }
}

func assertLessThan(_ actual: CGFloat, _ maximum: CGFloat, _ message: String) throws {
    if actual >= maximum {
        throw TestFailure(description: "\(message): expected < \(maximum), got \(actual)")
    }
}

func run(_ name: String, _ test: () throws -> Void) rethrows {
    try test()
    print("PASS: \(name)")
}

@main
struct HUDVisualStyleTests {
    static func main() {
        do {
            try run("filled bars match icon foreground strength") {
                try assertEqual(
                    HUDVisualStyle.filledBarOpacity,
                    HUDVisualStyle.iconOpacity,
                    "filled bar opacity",
                )
                try assertGreaterThan(HUDVisualStyle.iconOpacity, 0.7, "icon contrast")
                try assertLessThan(HUDVisualStyle.iconOpacity, 0.9, "icon restraint")
            }

            try run("inactive bars are visible but secondary") {
                try assertGreaterThan(HUDVisualStyle.inactiveBarOpacity, 0.2, "inactive contrast")
                try assertLessThan(
                    HUDVisualStyle.inactiveBarOpacity,
                    HUDVisualStyle.filledBarOpacity,
                    "inactive hierarchy",
                )
                try assertEqual(
                    HUDVisualStyle.mutedBarOpacity,
                    HUDVisualStyle.inactiveBarOpacity,
                    "muted bar opacity",
                )
            }

            print("All HUDVisualStyle tests passed.")
        } catch {
            print("FAIL: \(error)")
            exit(1)
        }
    }
}
