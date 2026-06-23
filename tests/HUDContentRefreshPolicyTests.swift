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

func run(_ name: String, _ test: () throws -> Void) rethrows {
    try test()
    print("PASS: \(name)")
}

@main
struct HUDContentRefreshPolicyTests {
    static func main() {
        do {
            let base = HUDContentSnapshot(
                kind: .volume,
                windowSideLength: 200,
                glassEffectEnabled: true,
                value: 0.7,
                isMuted: false,
            )

            try run("missing previous snapshot refreshes content") {
                try assertEqual(
                    HUDContentRefreshPolicy.shouldRefresh(previous: nil, current: base),
                    true,
                    "missing previous snapshot",
                )
            }

            try run("unchanged snapshot avoids rebuild") {
                try assertEqual(
                    HUDContentRefreshPolicy.shouldRefresh(previous: base, current: base),
                    false,
                    "unchanged snapshot",
                )
            }

            try run("glass toggle refreshes content") {
                let current = HUDContentSnapshot(
                    kind: .volume,
                    windowSideLength: 200,
                    glassEffectEnabled: false,
                    value: 0.7,
                    isMuted: false,
                )
                try assertEqual(
                    HUDContentRefreshPolicy.shouldRefresh(previous: base, current: current),
                    true,
                    "glass toggle refresh",
                )
            }

            try run("window size tolerance avoids insignificant rebuilds") {
                let current = HUDContentSnapshot(
                    kind: .volume,
                    windowSideLength: 200.5,
                    glassEffectEnabled: true,
                    value: 0.7,
                    isMuted: false,
                )
                try assertEqual(
                    HUDContentRefreshPolicy.shouldRefresh(previous: base, current: current),
                    false,
                    "window size tolerance",
                )
            }

            try run("window size changes refresh content") {
                let current = HUDContentSnapshot(
                    kind: .volume,
                    windowSideLength: 200.6,
                    glassEffectEnabled: true,
                    value: 0.7,
                    isMuted: false,
                )
                try assertEqual(
                    HUDContentRefreshPolicy.shouldRefresh(previous: base, current: current),
                    true,
                    "window size refresh",
                )
            }

            try run("volume muted state refreshes content") {
                let current = HUDContentSnapshot(
                    kind: .volume,
                    windowSideLength: 200,
                    glassEffectEnabled: true,
                    value: 0.7,
                    isMuted: true,
                )
                try assertEqual(
                    HUDContentRefreshPolicy.shouldRefresh(previous: base, current: current),
                    true,
                    "volume muted refresh",
                )
            }

            try run("brightness ignores muted state") {
                let previous = HUDContentSnapshot(
                    kind: .brightness,
                    windowSideLength: 200,
                    glassEffectEnabled: true,
                    value: 0.7,
                    isMuted: false,
                )
                let current = HUDContentSnapshot(
                    kind: .brightness,
                    windowSideLength: 200,
                    glassEffectEnabled: true,
                    value: 0.7,
                    isMuted: true,
                )
                try assertEqual(
                    HUDContentRefreshPolicy.shouldRefresh(previous: previous, current: current),
                    false,
                    "brightness muted refresh",
                )
            }

            print("All HUDContentRefreshPolicy tests passed.")
        } catch {
            print("FAIL: \(error)")
            exit(1)
        }
    }
}
