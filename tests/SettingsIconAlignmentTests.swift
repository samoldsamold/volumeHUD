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

func assertAtLeast(_ actual: Int, _ minimum: Int, _ message: String) throws {
    if actual < minimum {
        throw TestFailure(description: "\(message): expected at least \(minimum), got \(actual)")
    }
}

func countOccurrences(of needle: String, in haystack: String) -> Int {
    haystack.components(separatedBy: needle).count - 1
}

func readSource(_ path: String) throws -> String {
    try String(contentsOfFile: path, encoding: .utf8)
}

func run(_ name: String, _ test: () throws -> Void) rethrows {
    try test()
    print("PASS: \(name)")
}

@main
struct SettingsIconAlignmentTests {
    static func main() {
        do {
            let aboutViewSource = try readSource("volumeHUD/AboutView.swift")

            try run("settings icons use a shared centered helper") {
                try assertContains(
                    aboutViewSource,
                    "private struct SettingIcon: View",
                    "shared setting icon helper",
                )
                try assertContains(
                    aboutViewSource,
                    ".frame(width: slotWidth, height: slotHeight, alignment: .center)",
                    "centered icon slot",
                )
                try assertAtLeast(
                    countOccurrences(of: "SettingIcon(", in: aboutViewSource),
                    5,
                    "setting icon helper call sites",
                )
            }

            try run("legacy leading icon frames are removed") {
                try assertNotContains(
                    aboutViewSource,
                    ".frame(width: 14, alignment: .leading)",
                    "legacy leading icon frame",
                )
            }

            try run("subtitle rows reserve the same icon slot") {
                try assertAtLeast(
                    countOccurrences(of: ".frame(width: settingIconSlotWidth)", in: aboutViewSource),
                    4,
                    "subtitle icon-slot spacers",
                )
                try assertContains(
                    aboutViewSource,
                    "HStack(spacing: settingIconTextSpacing)",
                    "shared icon text spacing",
                )
            }

            try run("default button uses icon slot alignment constants") {
                try assertContains(
                    aboutViewSource,
                    ".padding(.leading, settingPadding + settingIconSlotWidth + settingIconTextSpacing)",
                    "default button text-column alignment",
                )
            }

            print("All SettingsIconAlignment tests passed.")
        } catch {
            print("FAIL: \(error)")
            exit(1)
        }
    }
}
