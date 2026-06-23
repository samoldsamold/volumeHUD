import Foundation

struct TestFailure: Error, CustomStringConvertible {
    let description: String
}

func assertContains(_ haystack: String, _ needle: String, _ message: String) throws {
    if !haystack.contains(needle) {
        throw TestFailure(description: "\(message): missing \(needle)")
    }
}

func assertNotContains(_ haystack: String, _ needle: String, _ message: String) throws {
    if haystack.contains(needle) {
        throw TestFailure(description: "\(message): unexpected \(needle)")
    }
}

func readSource(_ path: String) throws -> String {
    try String(contentsOfFile: path, encoding: .utf8)
}

func run(_ name: String, _ test: () throws -> Void) rethrows {
    try test()
    print("PASS: \(name)")
}

@main
struct DisplaySelectionCopyTests {
    static func main() {
        do {
            let aboutViewSource = try readSource("volumeHUD/AboutView.swift")
            let preferencesSource = try readSource("volumeHUD/HUDPreferences.swift")

            try run("display selection title describes display behavior") {
                try assertNotContains(
                    aboutViewSource,
                    #"Text("HUD Follows Mouse")"#,
                    "legacy ambiguous display selection title",
                )
                try assertContains(
                    aboutViewSource,
                    #"Text("Use Mouse Display")"#,
                    "clear display selection title",
                )
            }

            try run("display selection subtitles explain enabled and disabled states") {
                try assertContains(
                    aboutViewSource,
                    #"Show HUD on the display with cursor"#,
                    "enabled display selection subtitle",
                )
                try assertContains(
                    aboutViewSource,
                    #"Show HUD on the primary display"#,
                    "disabled display selection subtitle",
                )
                try assertNotContains(
                    aboutViewSource,
                    #"Show on screen with mouse cursor"#,
                    "legacy enabled subtitle",
                )
                try assertNotContains(
                    aboutViewSource,
                    #"Always show on the primary display"#,
                    "legacy disabled subtitle",
                )
            }

            try run("display selection behavior keys remain unchanged") {
                try assertContains(
                    aboutViewSource,
                    #"@AppStorage("volumeHUDFollowsMouse")"#,
                    "existing follows-mouse preference key",
                )
                try assertContains(
                    preferencesSource,
                    "static let originalAuthorVolumeHUDFollowsMouse = true",
                    "original follows-mouse reset default",
                )
            }

            print("All DisplaySelectionCopy tests passed.")
        } catch {
            print("FAIL: \(error)")
            exit(1)
        }
    }
}
