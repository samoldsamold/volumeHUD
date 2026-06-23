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

func slice(_ source: String, from start: String, to end: String) throws -> String {
    guard let startRange = source.range(of: start) else {
        throw TestFailure(description: "missing start marker \(start)")
    }
    guard let endRange = source[startRange.upperBound...].range(of: end) else {
        throw TestFailure(description: "missing end marker \(end)")
    }
    return String(source[startRange.upperBound ..< endRange.lowerBound])
}

func readSource(_ path: String) throws -> String {
    try String(contentsOfFile: path, encoding: .utf8)
}

func run(_ name: String, _ test: () throws -> Void) rethrows {
    try test()
    print("PASS: \(name)")
}

@main
struct HUDViewSurfaceTests {
    static func main() {
        do {
            let hudViewSource = try readSource("volumeHUD/HUDView.swift")
            let aboutViewSource = try readSource("volumeHUD/AboutView.swift")
            let glassStyleSource = try readSource("volumeHUD/HUDGlassStyle.swift")

            try run("enabled glass branch uses shaped SwiftUI Liquid Glass") {
                let glassBranch = try slice(
                    hudViewSource,
                    from: "case .swiftUILiquidGlass:",
                    to: "case .classicMaterial:",
                )
                try assertContains(glassBranch, "ZStack", "glass branch layers")
                try assertContains(glassBranch, "glassSurface", "glass branch background surface")
                try assertContains(glassBranch, "hudContent", "glass branch foreground content")
                try assertNotContains(
                    glassBranch,
                    "hudContent\n                .frame(width: hudSize, height: hudSize)\n                .glassEffect(",
                    "glass effect directly on content",
                )
                try assertContains(hudViewSource, "private var glassSurface: some View", "glass surface helper")
                let hudShapeSource = try slice(
                    hudViewSource,
                    from: "private var hudShape: RoundedRectangle",
                    to: "private var glassSurface: some View",
                )
                let glassSurfaceSource = try slice(
                    hudViewSource,
                    from: "private var glassSurface: some View",
                    to: "private var hudContent:",
                )
                try assertContains(
                    hudShapeSource,
                    "RoundedRectangle(cornerRadius: cornerRadius, style: .continuous)",
                    "shared HUD shape",
                )
                try assertContains(glassSurfaceSource, ".glassEffect(", "glass surface effect")
                try assertContains(glassSurfaceSource, ".regular", "glass surface effect style")
                try assertContains(glassSurfaceSource, "in: hudShape", "glass surface shape")
                try assertNotContains(glassBranch, ".overlay", "glass branch overlay")
                try assertNotContains(glassBranch, ".shadow", "glass branch shadow")
                try assertNotContains(glassBranch, "HUDGlassBackground", "glass branch legacy bridge")
            }

            try run("classic material branch keeps regular material fallback") {
                let classicBranch = try slice(
                    hudViewSource,
                    from: "case .classicMaterial:",
                    to: "private var hudShape:",
                )
                try assertContains(classicBranch, ".background", "classic branch background")
                try assertContains(classicBranch, ".fill(.regularMaterial)", "classic branch material")
                try assertContains(classicBranch, ".clipShape", "classic branch clipping")
                try assertNotContains(classicBranch, ".glassEffect(", "classic branch glass effect")
                try assertNotContains(classicBranch, "HUDGlassBackground", "classic branch legacy bridge")
            }

            try run("glass style exposes no unused custom chrome policy") {
                try assertNotContains(glassStyleSource, "SurfaceConfiguration", "dead chrome policy")
                try assertNotContains(glassStyleSource, "scrimOpacity", "dead scrim policy")
                try assertNotContains(glassStyleSource, "borderOpacity", "dead border policy")
                try assertNotContains(glassStyleSource, "shadowOpacity", "dead shadow policy")
            }

            try run("HUD icon and bars use shared visual style tokens") {
                let iconSource = try slice(
                    hudViewSource,
                    from: "Image(systemName: iconName)",
                    to: "// SF Symbols has misalignment",
                )
                let mutedSource = try slice(
                    hudViewSource,
                    from: "if hudType == .volume, isMuted {",
                    to: "} else {",
                )
                let filledSource = try slice(
                    hudViewSource,
                    from: "if value >= barEnd {",
                    to: "} else if value > barStart {",
                )
                let partialSource = try slice(
                    hudViewSource,
                    from: "ZStack(alignment: .leading) {",
                    to: ".frame(width: barWidth, height: barHeight)\n            } else {",
                )
                let emptySource = try slice(
                    hudViewSource,
                    from: "// Empty bar",
                    to: "        }\n    }\n}",
                )

                try assertContains(
                    iconSource,
                    "HUDVisualStyle.iconOpacity",
                    "icon foreground token",
                )
                try assertContains(
                    filledSource,
                    "HUDVisualStyle.filledBarOpacity",
                    "filled bar foreground token",
                )
                try assertContains(
                    partialSource,
                    "HUDVisualStyle.filledBarOpacity",
                    "partial foreground token",
                )
                try assertContains(
                    partialSource,
                    "HUDVisualStyle.inactiveBarOpacity",
                    "partial background token",
                )
                try assertContains(
                    emptySource,
                    "HUDVisualStyle.inactiveBarOpacity",
                    "empty bar foreground token",
                )
                try assertContains(
                    mutedSource,
                    "HUDVisualStyle.mutedBarOpacity",
                    "muted bar foreground token",
                )
                try assertNotContains(
                    hudViewSource,
                    ".primary.opacity(0.7)",
                    "legacy low-contrast filled opacity",
                )
                try assertNotContains(
                    hudViewSource,
                    ".primary.opacity(0.2)",
                    "legacy low-contrast inactive opacity",
                )
            }

            try run("settings sliders use clean custom track without native tick marks") {
                let sliderSettingSource = try slice(
                    aboutViewSource,
                    from: "private struct HUDSliderSetting: View",
                    to: "#Preview",
                )
                try assertContains(sliderSettingSource, "CleanHUDSlider(", "custom slider")
                try assertContains(sliderSettingSource, "title: title", "slider accessibility title")
                try assertContains(sliderSettingSource, "private struct CleanHUDSlider", "custom slider type")
                try assertNotContains(sliderSettingSource, "\n                Slider(value:", "native slider")
                try assertContains(sliderSettingSource, "DragGesture", "drag interaction")
                try assertContains(sliderSettingSource, ".accessibilityLabel(title)", "accessibility label")
                try assertContains(sliderSettingSource, ".focusable()", "keyboard focus")
                try assertContains(sliderSettingSource, ".onKeyPress(.leftArrow)", "left arrow handling")
                try assertContains(sliderSettingSource, ".onKeyPress(.rightArrow)", "right arrow handling")
                try assertContains(sliderSettingSource, "HUDSliderInteraction.value", "testable location mapping")
                try assertContains(sliderSettingSource, "HUDSliderInteraction.adjustedValue", "testable keyboard adjustment")
            }

            try run("settings page exposes original defaults reset") {
                try assertContains(aboutViewSource, "Set to Default", "reset button label")
                try assertContains(
                    aboutViewSource,
                    "resetHUDAppearanceToOriginalDefaults()",
                    "reset action",
                )
                try assertContains(
                    aboutViewSource,
                    "HUDPreferences.originalAuthorDefaultSize",
                    "reset size default",
                )
                try assertContains(
                    aboutViewSource,
                    "HUDPreferences.originalAuthorVerticalPosition",
                    "reset vertical position",
                )
                try assertContains(
                    aboutViewSource,
                    "HUDPreferences.originalAuthorDefaultOpacity",
                    "reset opacity default",
                )
                try assertContains(
                    aboutViewSource,
                    "HUDPreferences.originalAuthorDefaultGlassEffectEnabled",
                    "reset glass default",
                )
                try assertContains(
                    aboutViewSource,
                    "HUDPreferences.originalAuthorVolumeHUDFollowsMouse",
                    "reset display default",
                )
                try assertContains(aboutViewSource, "showHUDPreview()", "reset preview")
            }

            print("All HUDViewSurface tests passed.")
        } catch {
            print("FAIL: \(error)")
            exit(1)
        }
    }
}
