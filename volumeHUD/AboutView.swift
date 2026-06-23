//
//  AboutView.swift
//  by Danny Stewart (2025)
//  MIT License
//  https://github.com/dannystewart/volumeHUD
//

import SwiftUI

// MARK: - AboutView

struct AboutView: View {
    @State private var isShowingBuildNumber: Bool = false

    // Settings for app preferences
    #if !SANDBOX
        @AppStorage("brightnessEnabled") private var brightnessEnabled: Bool = false
    #endif // !SANDBOX
    @AppStorage("volumeHUDFollowsMouse") private var volumeHUDFollowsMouse: Bool = true
    @AppStorage(HUDPreferences.sizeKey) private var hudSize: Double = HUDPreferences.defaultSize
    @AppStorage(HUDPreferences.verticalPositionKey) private var hudVerticalPosition: Double = HUDPreferences.defaultVerticalPosition
    @AppStorage(HUDPreferences.opacityKey) private var hudOpacity: Double = HUDPreferences.defaultOpacity
    @AppStorage(HUDPreferences.glassEffectEnabledKey) private var hudGlassEffectEnabled: Bool = HUDPreferences.defaultGlassEffectEnabled

    #if !SANDBOX
        /// State to track if an update is available
        @State private var isUpdateAvailable: Bool = false

        // GitHub repository info
        private let githubOwner = "samoldsamold"
        private let githubRepo = "volumeHUD"
    #endif // !SANDBOX

    /// Login item manager
    @Environment(\.loginItemManager) private var loginItemManager

    let onQuit: () -> Void
    weak var appDelegate: AppDelegate?

    let logger: Logger = .init()

    // Visual alignment
    private let settingIconSlotWidth: CGFloat = 24
    private let settingIconTextSpacing: CGFloat = 10
    private let minSettingColumnWidth: CGFloat = 140
    private let settingPadding: CGFloat = 24 // Higher for less padding
    private let spaceBeforeSubtitle: CGFloat = -3

    /// Get the app version
    private var appVersion: String {
        if let version = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String {
            return version
        }
        return "3.0.0"
    }

    /// Get the app build number
    private var appBuildNumber: String {
        if let buildNumber = Bundle.main.infoDictionary?["CFBundleVersion"] as? String {
            return buildNumber
        }
        return "0"
    }

    private var aboutVersionLabelText: String {
        if isShowingBuildNumber {
            "Build \(appBuildNumber)"
        } else {
            "Version \(appVersion)"
        }
    }

    private var hudSizeBinding: Binding<Double> {
        Binding(
            get: { HUDPreferences.clampedSize(hudSize) },
            set: { newValue in
                hudSize = HUDPreferences.clampedSize(newValue)
                showHUDPreview()
            },
        )
    }

    private var hudVerticalPositionBinding: Binding<Double> {
        Binding(
            get: { HUDPreferences.clampedVerticalPosition(hudVerticalPosition) },
            set: { newValue in
                hudVerticalPosition = HUDPreferences.clampedVerticalPosition(newValue)
                showHUDPreview()
            },
        )
    }

    private var hudOpacityBinding: Binding<Double> {
        Binding(
            get: { HUDPreferences.clampedOpacity(hudOpacity) },
            set: { newValue in
                hudOpacity = HUDPreferences.clampedOpacity(newValue)
                showHUDPreview()
            },
        )
    }

    private var hudGlassEffectEnabledBinding: Binding<Bool> {
        Binding(
            get: { hudGlassEffectEnabled },
            set: { newValue in
                hudGlassEffectEnabled = newValue
                showHUDPreview()
            },
        )
    }

    private func sanitizeHUDSettings() {
        hudSize = HUDPreferences.clampedSize(hudSize)
        hudVerticalPosition = HUDPreferences.clampedVerticalPosition(hudVerticalPosition)
        hudOpacity = HUDPreferences.clampedOpacity(hudOpacity)
    }

    private func resetHUDAppearanceToOriginalDefaults() {
        volumeHUDFollowsMouse = HUDPreferences.originalAuthorVolumeHUDFollowsMouse
        hudSize = HUDPreferences.originalAuthorDefaultSize
        hudOpacity = HUDPreferences.originalAuthorDefaultOpacity
        hudGlassEffectEnabled = HUDPreferences.originalAuthorDefaultGlassEffectEnabled

        let windowSize = HUDPreferences.windowSize(size: HUDPreferences.originalAuthorDefaultSize)
        hudVerticalPosition = HUDPreferences.originalAuthorVerticalPosition(
            screenHeight: resetTargetScreenFrame().height,
            windowHeight: windowSize.height,
        )

        showHUDPreview()
    }

    private func resetTargetScreenFrame() -> CGRect {
        if volumeHUDFollowsMouse, let mouseScreen = screenWithMouse() {
            return mouseScreen.frame
        }

        if let primaryScreen = primaryScreen() {
            return primaryScreen.frame
        }

        return NSScreen.main?.frame ?? NSScreen.screens.first?.frame ?? CGRect(x: 0, y: 0, width: 1440, height: 900)
    }

    private func screenWithMouse() -> NSScreen? {
        let mouseLocation = NSEvent.mouseLocation
        return NSScreen.screens.first { $0.frame.contains(mouseLocation) }
    }

    private func primaryScreen() -> NSScreen? {
        let mainDisplayID = CGMainDisplayID()

        return NSScreen.screens.first { screen in
            guard let screenNumber = screen.deviceDescription[NSDeviceDescriptionKey("NSScreenNumber")] as? NSNumber else {
                return false
            }

            return CGDirectDisplayID(screenNumber.uint32Value) == mainDisplayID
        }
    }

    private func showHUDPreview() {
        appDelegate?.showHUDPreview()
    }

    // MARK: - About View

    var body: some View {
        HStack(alignment: .top, spacing: 20) {
            // MARK: - Left Column (App Info and Quit Button)

            VStack(spacing: 8) {
                if let appIcon = NSImage(named: "volumeHUD") {
                    Image(nsImage: appIcon)
                        .resizable()
                        .frame(width: 80, height: 80)
                }
                Text("volumeHUD")
                    .font(.system(size: 24, weight: .medium))
                Text("by Zhou Yongyu")
                    .font(.system(size: 12))
                    .foregroundStyle(.secondary)

                Button {
                    isShowingBuildNumber.toggle()
                } label: {
                    Text(aboutVersionLabelText)
                }
                .buttonStyle(.plain)
                .font(.system(size: 11))
                .foregroundStyle(.secondary)
                .accessibilityLabel("Version information")
                .accessibilityValue(aboutVersionLabelText)
                .accessibilityHint("Activate to toggle between app version and build number")

                #if !SANDBOX
                    Button(action: openReleasesPage) {
                        Text("Update available!")
                            .font(.system(size: 11))
                            .foregroundStyle(.blue)
                            .underline()
                    }
                    .buttonStyle(.plain)
                    .disabled(!isUpdateAvailable)
                    .opacity(isUpdateAvailable ? 1.0 : 0.0)
                    .padding(.bottom, 16)
                #endif // !SANDBOX

                Spacer(minLength: 0)

                Button(action: onQuit) {
                    Text("Quit volumeHUD")
                        .frame(maxWidth: .infinity)
                }
                .buttonStyle(.borderedProminent)
                .controlSize(.large)
                .keyboardShortcut(.defaultAction)
            }
            .frame(width: 160, alignment: .top)
            .padding(.leading, 16)

            // MARK: - Right Column (Settings)

            VStack(alignment: .leading, spacing: 15) {
                // MARK: - Open at Login Setting

                LoginItemSetting(
                    loginItemManager: loginItemManager,
                    settingIconSlotWidth: settingIconSlotWidth,
                    settingIconTextSpacing: settingIconTextSpacing,
                    minSettingColumnWidth: minSettingColumnWidth,
                    settingPadding: settingPadding,
                    spaceBeforeSubtitle: spaceBeforeSubtitle,
                )

                #if !SANDBOX

                    // MARK: - Brightness HUD Toggle

                    VStack(alignment: .leading, spacing: spaceBeforeSubtitle) {
                        HStack(alignment: .center, spacing: settingIconTextSpacing) {
                            SettingIcon(
                                systemName: "sun.max.fill",
                                color: brightnessEnabled ? .orange : .gray,
                                slotWidth: settingIconSlotWidth,
                            )
                                .animation(.easeInOut(duration: 0.3), value: brightnessEnabled)

                            Text("Brightness HUD")
                                .font(.system(size: 12, weight: .medium))
                                .frame(width: minSettingColumnWidth, alignment: .leading)

                            Spacer()

                            Toggle("", isOn: $brightnessEnabled)
                                .toggleStyle(SwitchToggleStyle(tint: .accentColor))
                                .scaleEffect(0.8)
                                .onChange(of: brightnessEnabled) { oldValue, newValue in
                                    logger.debug("Brightness setting changed from \(oldValue) to \(newValue).")
                                    appDelegate?.startBrightnessMonitoringIfEnabled()
                                }
                        }

                        HStack(spacing: settingIconTextSpacing) {
                            Spacer()
                                .frame(width: settingIconSlotWidth)

                            Text("Experimental, built-in display only")
                                .font(.system(size: 10))
                                .foregroundStyle(.secondary)
                                .opacity(0.8)
                                .frame(maxWidth: .infinity, alignment: .leading)
                        }
                    }
                    .padding(.leading, settingPadding)
                    .animation(.easeInOut(duration: 0.3), value: brightnessEnabled)
                #endif // !SANDBOX

                // MARK: - Display Toggle for HUD Placement

                VStack(alignment: .leading, spacing: spaceBeforeSubtitle) {
                    HStack(alignment: .center, spacing: settingIconTextSpacing) {
                        SettingIcon(
                            systemName: volumeHUDFollowsMouse ? "cursorarrow.click.2" : "laptopcomputer",
                            color: volumeHUDFollowsMouse ? .blue : .gray,
                            slotWidth: settingIconSlotWidth,
                        )
                            .animation(.easeInOut(duration: 0.3), value: volumeHUDFollowsMouse)

                        Text("Use Mouse Display")
                            .font(.system(size: 12, weight: .medium))
                            .frame(width: minSettingColumnWidth, alignment: .leading)

                        Spacer()

                        Toggle("", isOn: $volumeHUDFollowsMouse)
                            .toggleStyle(SwitchToggleStyle(tint: .accentColor))
                            .scaleEffect(0.8)
                            .onChange(of: volumeHUDFollowsMouse) { oldValue, newValue in
                                logger.debug("Volume HUD display setting changed from \(oldValue) to \(newValue).")
                            }
                    }

                    HStack(spacing: settingIconTextSpacing) {
                        Spacer()
                            .frame(width: settingIconSlotWidth)

                        Text(volumeHUDFollowsMouse ? "Show HUD on the display with cursor" : "Show HUD on the primary display")
                            .font(.system(size: 10))
                            .foregroundStyle(.secondary)
                            .opacity(0.8)
                            .frame(maxWidth: .infinity, alignment: .leading)
                    }
                }
                .padding(.leading, settingPadding)
                .animation(.easeInOut(duration: 0.3), value: volumeHUDFollowsMouse)

                // MARK: - HUD Glass Effect Toggle

                VStack(alignment: .leading, spacing: spaceBeforeSubtitle) {
                    HStack(alignment: .center, spacing: settingIconTextSpacing) {
                        SettingIcon(
                            systemName: hudGlassEffectEnabled ? "sparkles.rectangle.stack.fill" : "rectangle",
                            color: hudGlassEffectEnabled ? .teal : .gray,
                            slotWidth: settingIconSlotWidth,
                        )
                            .animation(.easeInOut(duration: 0.3), value: hudGlassEffectEnabled)

                        Text("HUD Glass Effect")
                            .font(.system(size: 12, weight: .medium))
                            .frame(width: minSettingColumnWidth, alignment: .leading)

                        Spacer()

                        Toggle("", isOn: hudGlassEffectEnabledBinding)
                            .toggleStyle(SwitchToggleStyle(tint: .accentColor))
                            .scaleEffect(0.8)
                    }

                    HStack(spacing: settingIconTextSpacing) {
                        Spacer()
                            .frame(width: settingIconSlotWidth)

                        Text(hudGlassEffectEnabled ? "Use native translucent HUD glass" : "Use classic material background")
                            .font(.system(size: 10))
                            .foregroundStyle(.secondary)
                            .opacity(0.8)
                            .frame(maxWidth: .infinity, alignment: .leading)
                    }
                }
                .padding(.leading, settingPadding)
                .animation(.easeInOut(duration: 0.3), value: hudGlassEffectEnabled)

                // MARK: - HUD Size Slider

                HUDSliderSetting(
                    value: hudSizeBinding,
                    range: HUDPreferences.minimumSize ... HUDPreferences.maximumSize,
                    iconName: "arrow.up.left.and.arrow.down.right",
                    iconColor: .indigo,
                    title: "HUD Size",
                    subtitle: "30% matches the original size",
                    settingIconSlotWidth: settingIconSlotWidth,
                    settingIconTextSpacing: settingIconTextSpacing,
                    minSettingColumnWidth: minSettingColumnWidth,
                    settingPadding: settingPadding,
                    spaceBeforeSubtitle: spaceBeforeSubtitle,
                )
                .animation(.easeInOut(duration: 0.3), value: hudSize)

                // MARK: - HUD Height Slider

                HUDSliderSetting(
                    value: hudVerticalPositionBinding,
                    range: 0.0 ... 1.0,
                    iconName: "arrow.up.and.down",
                    iconColor: .cyan,
                    title: "HUD Height",
                    subtitle: "Vertical center on selected screen",
                    settingIconSlotWidth: settingIconSlotWidth,
                    settingIconTextSpacing: settingIconTextSpacing,
                    minSettingColumnWidth: minSettingColumnWidth,
                    settingPadding: settingPadding,
                    spaceBeforeSubtitle: spaceBeforeSubtitle,
                )
                .animation(.easeInOut(duration: 0.3), value: hudVerticalPosition)

                // MARK: - HUD Opacity Slider

                HUDSliderSetting(
                    value: hudOpacityBinding,
                    range: HUDPreferences.minimumOpacity ... 1.0,
                    iconName: "circle.lefthalf.filled",
                    iconColor: .purple,
                    title: "HUD Opacity",
                    subtitle: "Preview updates while adjusting",
                    settingIconSlotWidth: settingIconSlotWidth,
                    settingIconTextSpacing: settingIconTextSpacing,
                    minSettingColumnWidth: minSettingColumnWidth,
                    settingPadding: settingPadding,
                    spaceBeforeSubtitle: spaceBeforeSubtitle,
                )
                .animation(.easeInOut(duration: 0.3), value: hudOpacity)

                Button {
                    resetHUDAppearanceToOriginalDefaults()
                } label: {
                    Text("Set to Default")
                }
                .buttonStyle(.bordered)
                .controlSize(.small)
                .padding(.leading, settingPadding + settingIconSlotWidth + settingIconTextSpacing)
                .accessibilityHint("Restores the original volumeHUD placement and appearance")

                Spacer(minLength: 0)
            }
            .padding(.trailing, 6) // Right side window padding
        }
        .padding(32) // Overall frame padding
        .frame(width: 760, height: 470)
        .onAppear {
            sanitizeHUDSettings()
            #if !SANDBOX
                Task {
                    try? await Task.sleep(nanoseconds: 200_000_000) // 0.2 second delay
                    checkForUpdates()
                }
            #endif // !SANDBOX
        }
    }

    #if !SANDBOX

        // MARK: - Update Check

        private func checkForUpdates() {
            Task {
                do {
                    let latestRelease = try await fetchLatestRelease()

                    // Compare versions
                    if isNewerVersion(latestRelease, than: appVersion) {
                        await MainActor.run {
                            isUpdateAvailable = true
                        }
                    }
                } catch { // Silently fail if the update check fails
                    logger.error("Update check failed: \(error)")
                }
            }
        }

        private func fetchLatestRelease() async throws -> String {
            let urlString = "https://api.github.com/repos/\(githubOwner)/\(githubRepo)/releases/latest"
            guard let url = URL(string: urlString) else {
                throw URLError(.badURL)
            }

            var request = URLRequest(url: url)
            request.setValue("application/vnd.github.v3+json", forHTTPHeaderField: "Accept")

            let (data, response) = try await URLSession.shared.data(for: request)

            guard
                let httpResponse = response as? HTTPURLResponse,
                httpResponse.statusCode == 200 else
            {
                throw URLError(.badServerResponse)
            }

            // Parse JSON response
            guard
                let json = try JSONSerialization.jsonObject(with: data) as? [String: Any],
                let tagName = json["tag_name"] as? String else
            {
                throw URLError(.cannotParseResponse)
            }

            // Remove 'v' prefix
            return tagName.hasPrefix("v") ? String(tagName.dropFirst()) : tagName
        }

        private func isNewerVersion(_ latest: String, than current: String) -> Bool {
            let latestComponents = latest.split(separator: ".").compactMap { Int($0) }
            let currentComponents = current.split(separator: ".").compactMap { Int($0) }

            // Compare version components (major.minor.patch)
            for i in 0 ..< max(latestComponents.count, currentComponents.count) {
                let latestPart = i < latestComponents.count ? latestComponents[i] : 0
                let currentPart = i < currentComponents.count ? currentComponents[i] : 0

                if latestPart > currentPart {
                    return true
                } else if latestPart < currentPart {
                    return false
                }
            }

            return false // Versions are equal
        }

        private func openReleasesPage() {
            let urlString = "https://github.com/\(githubOwner)/\(githubRepo)/releases/latest"
            if let url = URL(string: urlString) {
                NSWorkspace.shared.open(url)
            }
        }
    #endif // !SANDBOX
}

// MARK: - Settings Icon

private struct SettingIcon: View {
    let systemName: String
    let color: Color
    let slotWidth: CGFloat

    private let iconFontSize: CGFloat = 14
    private let slotHeight: CGFloat = 20

    var body: some View {
        Image(systemName: systemName)
            .foregroundStyle(color)
            .font(.system(size: iconFontSize))
            .frame(width: slotWidth, height: slotHeight, alignment: .center)
    }
}

// MARK: - LoginItemSetting

private struct LoginItemSetting: View {
    @ObservedObject private var loginItemManager: LoginItemManager

    let settingIconSlotWidth: CGFloat
    let settingIconTextSpacing: CGFloat
    let minSettingColumnWidth: CGFloat
    let settingPadding: CGFloat
    let spaceBeforeSubtitle: CGFloat

    init(
        loginItemManager: LoginItemManager,
        settingIconSlotWidth: CGFloat,
        settingIconTextSpacing: CGFloat,
        minSettingColumnWidth: CGFloat,
        settingPadding: CGFloat,
        spaceBeforeSubtitle: CGFloat,
    ) {
        self.loginItemManager = loginItemManager
        self.settingIconSlotWidth = settingIconSlotWidth
        self.settingIconTextSpacing = settingIconTextSpacing
        self.minSettingColumnWidth = minSettingColumnWidth
        self.settingPadding = settingPadding
        self.spaceBeforeSubtitle = spaceBeforeSubtitle
    }

    var body: some View {
        VStack(alignment: .leading, spacing: spaceBeforeSubtitle) {
            HStack(alignment: .center, spacing: settingIconTextSpacing) {
                SettingIcon(
                    systemName: "power.circle.fill",
                    color: loginItemManager.isEnabled ? .green : .gray,
                    slotWidth: settingIconSlotWidth,
                )
                    .animation(.easeInOut(duration: 0.3), value: loginItemManager.isEnabled)

                Text("Open at Login")
                    .font(.system(size: 12, weight: .medium))
                    .frame(width: minSettingColumnWidth, alignment: .leading)

                Spacer()

                Toggle("", isOn: Binding(
                    get: { loginItemManager.isEnabled },
                    set: { loginItemManager.setEnabled($0) },
                ))
                .toggleStyle(SwitchToggleStyle(tint: .accentColor))
                .scaleEffect(0.8)
            }
        }
        .padding(.leading, settingPadding)
    }
}

// MARK: - HUDSliderSetting

private struct HUDSliderSetting: View {
    @Binding private var value: Double

    let range: ClosedRange<Double>
    let iconName: String
    let iconColor: Color
    let title: String
    let subtitle: String
    let settingIconSlotWidth: CGFloat
    let settingIconTextSpacing: CGFloat
    let minSettingColumnWidth: CGFloat
    let settingPadding: CGFloat
    let spaceBeforeSubtitle: CGFloat

    init(
        value: Binding<Double>,
        range: ClosedRange<Double>,
        iconName: String,
        iconColor: Color,
        title: String,
        subtitle: String,
        settingIconSlotWidth: CGFloat,
        settingIconTextSpacing: CGFloat,
        minSettingColumnWidth: CGFloat,
        settingPadding: CGFloat,
        spaceBeforeSubtitle: CGFloat,
    ) {
        _value = value
        self.range = range
        self.iconName = iconName
        self.iconColor = iconColor
        self.title = title
        self.subtitle = subtitle
        self.settingIconSlotWidth = settingIconSlotWidth
        self.settingIconTextSpacing = settingIconTextSpacing
        self.minSettingColumnWidth = minSettingColumnWidth
        self.settingPadding = settingPadding
        self.spaceBeforeSubtitle = spaceBeforeSubtitle
    }

    private var percentageBinding: Binding<Double> {
        Binding(
            get: { HUDPercentageValue.displayedPercent(for: value) },
            set: { newValue in
                value = HUDPercentageValue.unitValue(fromDisplayedPercent: newValue, range: range)
            },
        )
    }

    var body: some View {
        VStack(alignment: .leading, spacing: spaceBeforeSubtitle) {
            HStack(alignment: .center, spacing: settingIconTextSpacing) {
                SettingIcon(
                    systemName: iconName,
                    color: iconColor,
                    slotWidth: settingIconSlotWidth,
                )

                Text(title)
                    .font(.system(size: 12, weight: .medium))
                    .frame(width: minSettingColumnWidth, alignment: .leading)

                Spacer(minLength: 8)

                CleanHUDSlider(value: $value, range: range, title: title)
                    .frame(width: 150, height: 18)

                HStack(spacing: 3) {
                    TextField("", value: percentageBinding, format: .number.precision(.fractionLength(0)))
                        .textFieldStyle(.roundedBorder)
                        .font(.system(size: 11, design: .monospaced))
                        .multilineTextAlignment(.trailing)
                        .frame(width: 46)

                    Text("%")
                        .font(.system(size: 11, design: .monospaced))
                        .foregroundStyle(.secondary)
                }
                .frame(width: 62, alignment: .trailing)
            }

            HStack(spacing: settingIconTextSpacing) {
                Spacer()
                    .frame(width: settingIconSlotWidth)

                Text(subtitle)
                    .font(.system(size: 10))
                    .foregroundStyle(.secondary)
                    .opacity(0.8)
                    .frame(maxWidth: .infinity, alignment: .leading)
            }
        }
        .padding(.leading, settingPadding)
    }
}

private struct CleanHUDSlider: View {
    @Binding var value: Double
    @FocusState private var hasKeyboardFocus: Bool

    let range: ClosedRange<Double>
    let title: String

    private let trackHeight: CGFloat = 4
    private let thumbSize: CGFloat = 12

    private var normalizedValue: Double {
        guard range.upperBound > range.lowerBound else {
            return 0
        }

        let clampedValue = min(max(value, range.lowerBound), range.upperBound)
        return (clampedValue - range.lowerBound) / (range.upperBound - range.lowerBound)
    }

    var body: some View {
        GeometryReader { geometry in
            let width = geometry.size.width
            let fillWidth = width * CGFloat(normalizedValue)

            ZStack(alignment: .leading) {
                Capsule()
                    .fill(.secondary.opacity(0.26))
                    .frame(height: trackHeight)

                Capsule()
                    .fill(Color.accentColor.opacity(0.95))
                    .frame(width: fillWidth, height: trackHeight)

                Circle()
                    .fill(.background)
                    .frame(width: thumbSize, height: thumbSize)
                    .overlay {
                        Circle()
                            .stroke(.primary.opacity(0.12), lineWidth: 0.5)
                    }
                    .shadow(color: .black.opacity(0.16), radius: 2, x: 0, y: 1)
                    .offset(x: fillWidth - thumbSize / 2)
            }
            .frame(width: width, height: geometry.size.height)
            .contentShape(Rectangle())
            .gesture(
                DragGesture(minimumDistance: 0)
                    .onChanged { gesture in
                        value = HUDSliderInteraction.value(
                            forLocation: Double(gesture.location.x),
                            trackWidth: Double(width),
                            range: range,
                        )
                    },
            )
        }
        .focusable()
        .focused($hasKeyboardFocus)
        .onKeyPress(.leftArrow) {
            adjustValue(.decrement)
            return .handled
        }
        .onKeyPress(.downArrow) {
            adjustValue(.decrement)
            return .handled
        }
        .onKeyPress(.rightArrow) {
            adjustValue(.increment)
            return .handled
        }
        .onKeyPress(.upArrow) {
            adjustValue(.increment)
            return .handled
        }
        .accessibilityElement()
        .accessibilityLabel(title)
        .accessibilityValue("\(Int(HUDPercentageValue.displayedPercent(for: value))) percent")
        .accessibilityAdjustableAction { direction in
            switch direction {
            case .increment:
                adjustValue(.increment)
            case .decrement:
                adjustValue(.decrement)
            @unknown default:
                break
            }
        }
    }

    private func adjustValue(_ direction: HUDSliderInteraction.AdjustmentDirection) {
        value = HUDSliderInteraction.adjustedValue(value, direction: direction, range: range)
    }
}

#Preview {
    AboutView(
        onQuit: {},
        appDelegate: nil,
    )
    .environment(\.loginItemManager, LoginItemManager())
}
