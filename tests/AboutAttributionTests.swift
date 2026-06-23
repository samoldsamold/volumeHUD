import Foundation

struct TestFailure: Error, CustomStringConvertible {
    let description: String
}

func assertContains(_ haystack: String, _ needle: String, _ message: String) throws {
    if !haystack.contains(needle) {
        throw TestFailure(description: "\(message): missing \(needle)")
    }
}

func assertDoesNotContain(_ haystack: String, _ needle: String, _ message: String) throws {
    if haystack.contains(needle) {
        throw TestFailure(description: "\(message): found \(needle)")
    }
}

func assertLessThan(_ left: String.Index, _ right: String.Index, _ message: String) throws {
    if left >= right {
        throw TestFailure(description: message)
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
struct AboutAttributionTests {
    static func main() {
        do {
            let aboutViewSource = try readSource("volumeHUD/AboutView.swift")
            let license = try readSource("LICENSE")
            let notice = try readSource("NOTICE")

            try run("About view shows fork maintainer attribution only") {
                try assertContains(
                    aboutViewSource,
                    #"Text("by Zhou Yongyu")"#,
                    "fork maintainer attribution",
                )
                try assertDoesNotContain(
                    aboutViewSource,
                    #"Text("modified by Zhou Yongyu")"#,
                    "old modification attribution",
                )
                try assertDoesNotContain(
                    aboutViewSource,
                    #"Text("by Danny Stewart")"#,
                    "original author should not be shown in About UI",
                )
            }

            try run("About attribution appears before version label") {
                guard let maintainerRange = aboutViewSource.range(of: #"Text("by Zhou Yongyu")"#) else {
                    throw TestFailure(description: "missing maintainer attribution range")
                }
                guard let versionRange = aboutViewSource.range(of: "Text(aboutVersionLabelText)") else {
                    throw TestFailure(description: "missing version label range")
                }

                try assertLessThan(
                    maintainerRange.lowerBound,
                    versionRange.lowerBound,
                    "maintainer attribution should appear before version label",
                )
            }

            try run("About attribution uses muted author styling") {
                guard let maintainerRange = aboutViewSource.range(of: #"Text("by Zhou Yongyu")"#) else {
                    throw TestFailure(description: "missing maintainer attribution range")
                }
                guard let versionRange = aboutViewSource.range(of: "Text(aboutVersionLabelText)") else {
                    throw TestFailure(description: "missing version label range")
                }

                let attributionBlock = String(aboutViewSource[maintainerRange.lowerBound ..< versionRange.lowerBound])
                let fontCount = countOccurrences(of: ".font(.system(size: 12))", in: attributionBlock)
                let secondaryCount = countOccurrences(of: ".foregroundStyle(.secondary)", in: attributionBlock)

                if fontCount < 1 {
                    throw TestFailure(description: "expected maintainer attribution to use 12 pt font")
                }
                if secondaryCount < 1 {
                    throw TestFailure(description: "expected maintainer attribution to use secondary foreground style")
                }
            }

            try run("MIT attribution remains in license and notice") {
                try assertContains(
                    license,
                    "Copyright (c) 2025 Danny Stewart",
                    "original MIT copyright remains in LICENSE",
                )
                try assertContains(
                    notice,
                    "Copyright (c) 2025 Danny Stewart",
                    "original MIT copyright remains in NOTICE",
                )
                try assertContains(
                    notice,
                    "Copyright (c) 2026 ZHOU YONGYU",
                    "fork modification copyright remains in NOTICE",
                )
            }

            print("All AboutAttribution tests passed.")
        } catch {
            print("FAIL: \(error)")
            exit(1)
        }
    }
}
