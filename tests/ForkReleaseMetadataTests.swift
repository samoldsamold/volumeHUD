import Foundation

struct TestFailure: Error, CustomStringConvertible {
    let message: String

    var description: String {
        message
    }
}

func assertContains(_ haystack: String, _ needle: String, _ message: String) throws {
    if !haystack.contains(needle) {
        throw TestFailure(message: "\(message): missing \(needle)")
    }
}

func assertDoesNotContain(_ haystack: String, _ needle: String, _ message: String) throws {
    if haystack.contains(needle) {
        throw TestFailure(message: "\(message): found \(needle)")
    }
}

func assertEqual(_ lhs: Int, _ rhs: Int, _ message: String) throws {
    if lhs != rhs {
        throw TestFailure(message: "\(message): expected \(rhs), got \(lhs)")
    }
}

func readFile(_ relativePath: String) throws -> String {
    let url = URL(fileURLWithPath: FileManager.default.currentDirectoryPath)
        .appendingPathComponent(relativePath)
    return try String(contentsOf: url, encoding: .utf8)
}

func marketingVersionValues(in project: String) -> [String] {
    let pattern = #"MARKETING_VERSION = ([^;]+);"#
    let regex = try! NSRegularExpression(pattern: pattern)
    let range = NSRange(project.startIndex ..< project.endIndex, in: project)

    return regex.matches(in: project, range: range).compactMap { match in
        guard let versionRange = Range(match.range(at: 1), in: project) else {
            return nil
        }
        return String(project[versionRange])
    }
}

@main
struct ForkReleaseMetadataTests {
    static func main() {
        do {
            let aboutView = try readFile("volumeHUD/AboutView.swift")
            let project = try readFile("volumeHUD.xcodeproj/project.pbxproj")
            let changelog = try readFile("CHANGELOG.md")
            let changeSummary = try readFile("docs/CHANGE_SUMMARY.md")

            try assertContains(
                aboutView,
                #"private let githubOwner = "samoldsamold""#,
                "update check uses the fork owner",
            )
            try assertContains(
                aboutView,
                #"private let githubRepo = "volumeHUD""#,
                "update check uses the fork repository",
            )
            try assertDoesNotContain(
                aboutView,
                #"private let githubOwner = "dannystewart""#,
                "update check no longer targets the original owner",
            )
            print("PASS: update check targets samoldsamold/volumeHUD")

            let versions = marketingVersionValues(in: project)
            try assertEqual(versions.count, 4, "project contains the expected marketing version entries")
            for version in versions {
                if version != "3.4.0" {
                    throw TestFailure(message: "all marketing versions are 3.4.0: found \(version)")
                }
            }
            try assertDoesNotContain(project, "MARKETING_VERSION = 3.3.2;", "old marketing version removed")
            print("PASS: all marketing versions are 3.4.0")

            try assertContains(changelog, "## [3.4.0] (2026-06-23)", "changelog has fork release section")
            try assertContains(
                changelog,
                "[3.4.0]: https://github.com/samoldsamold/volumeHUD/compare/v3.3.1...v3.4.0",
                "changelog has fork compare link",
            )
            print("PASS: changelog records the 3.4.0 fork release")

            try assertContains(
                changeSummary,
                "Fork release target: `samoldsamold/volumeHUD`",
                "change summary records fork release target",
            )
            try assertContains(
                changeSummary,
                "Recommended release tag: `v3.4.0`",
                "change summary records recommended release tag",
            )
            print("PASS: change summary records fork release target and tag")

            print("All ForkReleaseMetadata tests passed.")
        } catch {
            print("FAIL: \(error)")
            exit(1)
        }
    }
}
