import Foundation

struct TestFailure: Error, CustomStringConvertible {
    let description: String
}

func assertContains(_ haystack: String, _ needle: String, _ message: String) throws {
    if !haystack.contains(needle) {
        throw TestFailure(description: "\(message): missing \(needle)")
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

            try run("About view preserves original and fork attribution text") {
                try assertContains(
                    aboutViewSource,
                    #"Text("by Danny Stewart")"#,
                    "original author attribution",
                )
                try assertContains(
                    aboutViewSource,
                    #"Text("modified by Zhou Yongyu")"#,
                    "fork modification attribution",
                )
            }

            try run("About attribution appears before version label") {
                guard let originalRange = aboutViewSource.range(of: #"Text("by Danny Stewart")"#) else {
                    throw TestFailure(description: "missing original attribution range")
                }
                guard let modifiedRange = aboutViewSource.range(of: #"Text("modified by Zhou Yongyu")"#) else {
                    throw TestFailure(description: "missing modification attribution range")
                }
                guard let versionRange = aboutViewSource.range(of: "Text(aboutVersionLabelText)") else {
                    throw TestFailure(description: "missing version label range")
                }

                try assertLessThan(
                    originalRange.lowerBound,
                    modifiedRange.lowerBound,
                    "modification attribution should follow original author",
                )
                try assertLessThan(
                    modifiedRange.lowerBound,
                    versionRange.lowerBound,
                    "modification attribution should appear before version label",
                )
            }

            try run("About attribution uses muted author styling") {
                guard let originalRange = aboutViewSource.range(of: #"Text("by Danny Stewart")"#) else {
                    throw TestFailure(description: "missing original attribution range")
                }
                guard let versionRange = aboutViewSource.range(of: "Text(aboutVersionLabelText)") else {
                    throw TestFailure(description: "missing version label range")
                }

                let attributionBlock = String(aboutViewSource[originalRange.lowerBound ..< versionRange.lowerBound])
                let fontCount = countOccurrences(of: ".font(.system(size: 12))", in: attributionBlock)
                let secondaryCount = countOccurrences(of: ".foregroundStyle(.secondary)", in: attributionBlock)

                if fontCount < 2 {
                    throw TestFailure(description: "expected both attribution lines to use 12 pt font")
                }
                if secondaryCount < 2 {
                    throw TestFailure(description: "expected both attribution lines to use secondary foreground style")
                }
            }

            print("All AboutAttribution tests passed.")
        } catch {
            print("FAIL: \(error)")
            exit(1)
        }
    }
}
