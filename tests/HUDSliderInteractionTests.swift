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
struct HUDSliderInteractionTests {
    static func main() {
        do {
            try run("track locations map to clamped range values") {
                let range = 0.2 ... 1.0

                try assertEqual(
                    HUDSliderInteraction.value(forLocation: -50, trackWidth: 200, range: range),
                    0.2,
                    "left clamp",
                )
                try assertEqual(
                    HUDSliderInteraction.value(forLocation: 100, trackWidth: 200, range: range),
                    0.6,
                    "midpoint",
                )
                try assertEqual(
                    HUDSliderInteraction.value(forLocation: 250, trackWidth: 200, range: range),
                    1.0,
                    "right clamp",
                )
                try assertEqual(
                    HUDSliderInteraction.value(forLocation: 100, trackWidth: 0, range: range),
                    0.2,
                    "zero width fallback",
                )
            }

            try run("keyboard adjustments step and clamp values") {
                let range = 0.2 ... 1.0

                try assertEqual(
                    HUDSliderInteraction.adjustedValue(0.5, direction: .increment, range: range),
                    0.51,
                    "increment",
                )
                try assertEqual(
                    HUDSliderInteraction.adjustedValue(0.5, direction: .decrement, range: range),
                    0.49,
                    "decrement",
                )
                try assertEqual(
                    HUDSliderInteraction.adjustedValue(1.0, direction: .increment, range: range),
                    1.0,
                    "increment clamp",
                )
                try assertEqual(
                    HUDSliderInteraction.adjustedValue(0.2, direction: .decrement, range: range),
                    0.2,
                    "decrement clamp",
                )
            }

            print("All HUDSliderInteraction tests passed.")
        } catch {
            print("FAIL: \(error)")
            exit(1)
        }
    }
}
