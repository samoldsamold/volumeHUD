import Foundation

struct TestFailure: Error, CustomStringConvertible {
    let description: String
}

func assertEqual(_ actual: Double, _ expected: Double, _ message: String, tolerance: Double = 0.0001) throws {
    if abs(actual - expected) > tolerance {
        throw TestFailure(description: "\(message): expected \(expected), got \(actual)")
    }
}

func run(_ name: String, _ test: () throws -> Void) rethrows {
    try test()
    print("PASS: \(name)")
}

@main
struct HUDPercentageValueTests {
    static func main() {
        do {
            try run("displayed percent rounds unit values") {
                try assertEqual(HUDPercentageValue.displayedPercent(for: 0.3), 30, "30 percent display")
                try assertEqual(HUDPercentageValue.displayedPercent(for: 0.555), 56, "rounded percent display")
            }

            try run("numeric percent input converts to unit values") {
                try assertEqual(
                    HUDPercentageValue.unitValue(fromDisplayedPercent: 30, range: 0.2 ... 1.0),
                    0.3,
                    "30 percent unit value",
                )
                try assertEqual(
                    HUDPercentageValue.unitValue(fromDisplayedPercent: 75, range: 0.0 ... 1.0),
                    0.75,
                    "75 percent unit value",
                )
            }

            try run("numeric percent input clamps to supported range") {
                try assertEqual(
                    HUDPercentageValue.unitValue(fromDisplayedPercent: 5, range: 0.2 ... 1.0),
                    0.2,
                    "below range percent clamps high enough",
                )
                try assertEqual(
                    HUDPercentageValue.unitValue(fromDisplayedPercent: 150, range: 0.2 ... 1.0),
                    1.0,
                    "above range percent clamps low enough",
                )
            }

            try run("fractional percent input rounds before storing") {
                try assertEqual(
                    HUDPercentageValue.unitValue(fromDisplayedPercent: 30.7, range: 0.2 ... 1.0),
                    0.31,
                    "fractional percent rounds to whole percent before storing",
                )
            }

            print("All HUDPercentageValue tests passed.")
        } catch {
            print("FAIL: \(error)")
            exit(1)
        }
    }
}
