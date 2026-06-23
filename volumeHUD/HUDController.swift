//
//  HUDController.swift
//  by Danny Stewart (2025)
//  MIT License
//  https://github.com/dannystewart/volumeHUD
//

import AppKit
import Combine
import CoreGraphics
import Foundation
import SwiftUI

private extension HUDContentKind {
    init(hudType: HUDType) {
        switch hudType {
        case .volume:
            self = .volume

        case .brightness:
            self = .brightness
        }
    }
}

@MainActor
class HUDController: ObservableObject {
    @Published var isShowing = false

    let logger: Logger = .init()

    private var hudWindow: NSWindow?
    private var hostingView: NSHostingView<HUDView>?
    private var hideTimer: Timer?
    private var lastShownContentSnapshot: HUDContentSnapshot?
    private var hideAnimationGeneration = 0
    private var isObservingDisplayChanges = false
    private let isPreviewMode: Bool

    init(isPreviewMode: Bool = false) {
        self.isPreviewMode = isPreviewMode
    }

    deinit {}

    @MainActor
    func showVolumeHUD(volume: Float, isMuted: Bool) {
        displayHUD(hudType: .volume, value: volume, isMuted: isMuted)
    }

    @MainActor
    func showPreviewHUD() {
        displayHUD(hudType: .volume, value: 0.7, isMuted: false)
    }

    #if !SANDBOX
        @MainActor
        func showBrightnessHUD(brightness: Float) {
            // Only show brightness HUD if the feature is enabled
            guard UserDefaults.standard.bool(forKey: "brightnessEnabled") else {
                logger.debug("Brightness HUD disabled; skipping display.")
                return
            }
            displayHUD(hudType: .brightness, value: brightness, isMuted: false)
        }
    #endif // !SANDBOX

    @MainActor
    func startDisplayChangeMonitoring() {
        guard !isObservingDisplayChanges else { return }

        // Skip display monitoring in preview mode
        if isPreviewMode {
            logger.debug("Skipping display monitoring in preview mode.")
            isObservingDisplayChanges = true
            return
        }

        NotificationCenter.default.addObserver(
            self,
            selector: #selector(displayConfigurationDidChange(_:)),
            name: NSApplication.didChangeScreenParametersNotification,
            object: nil,
        )
        isObservingDisplayChanges = true

        logger.debug("Started monitoring display configuration changes.")
    }

    @MainActor
    func stopDisplayChangeMonitoring() {
        guard isObservingDisplayChanges else { return }
        NotificationCenter.default.removeObserver(
            self,
            name: NSApplication.didChangeScreenParametersNotification,
            object: nil,
        )
        isObservingDisplayChanges = false

        logger.debug("Stopped monitoring display configuration changes.")
    }

    @objc
    private func displayConfigurationDidChange(_: Notification) {
        // Ensure we hop to the main actor for UI work
        Task { @MainActor in
            self.handleDisplayConfigurationChange()
        }
    }

    @MainActor
    private func handleDisplayConfigurationChange() {
        logger.debug("Display configuration changed, updating HUD position.")

        // If the HUD window exists, update its position
        if hudWindow != nil {
            updateWindowPosition()
            // Re-apply after a short delay to handle transient frame/layout updates macOS screen
            // geometry may still be adjusting after didChangeScreenParameters fires
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.15) { [weak self] in
                self?.updateWindowPosition()
            }
        }
    }

    @MainActor
    private func updateWindowPosition(for hudType: HUDType? = nil) {
        guard let window = hudWindow else { return }

        let windowSize = HUDPreferences.windowSize(size: HUDPreferences.storedSize())

        // Brightness HUD always shows on built-in display (since that's what it controls). Volume
        // HUD respects user preference for display location.
        let targetScreen: NSScreen
        let selectionReason: String
        #if !SANDBOX
            if hudType == .brightness {
                if let builtin = getBuiltinScreen() {
                    targetScreen = builtin
                    selectionReason = "brightness builtin"
                } else if let main = NSScreen.main {
                    targetScreen = main
                    selectionReason = "brightness builtin-missing fallback NSScreen.main"
                } else {
                    targetScreen = NSScreen.screens.first!
                    selectionReason = "brightness builtin-missing fallback firstScreen"
                }
            } else {
                // Check user preference for volume HUD location
                let followMouse = UserDefaults.standard.bool(forKey: "volumeHUDFollowsMouse")
                if followMouse {
                    if let mouse = getScreenWithMouse() {
                        targetScreen = mouse
                        selectionReason = "volume followsMouse"
                    } else if let main = NSScreen.main {
                        targetScreen = main
                        selectionReason = "volume followsMouse missing-mouse fallback NSScreen.main"
                    } else {
                        targetScreen = NSScreen.screens.first!
                        selectionReason = "volume followsMouse missing-mouse fallback firstScreen"
                    }
                } else {
                    if let primary = getPrimaryScreen() {
                        targetScreen = primary
                        selectionReason = "volume primaryDisplay"
                    } else if let main = NSScreen.main {
                        targetScreen = main
                        selectionReason = "volume primaryDisplay missing-primary fallback NSScreen.main"
                    } else {
                        targetScreen = NSScreen.screens.first!
                        selectionReason = "volume primaryDisplay missing-primary fallback firstScreen"
                    }
                }
            }
        #else
            // Check user preference for volume HUD location
            let followMouse = UserDefaults.standard.bool(forKey: "volumeHUDFollowsMouse")
            if followMouse {
                if let mouse = getScreenWithMouse() {
                    targetScreen = mouse
                    selectionReason = "volume followsMouse"
                } else if let main = NSScreen.main {
                    targetScreen = main
                    selectionReason = "volume followsMouse missing-mouse fallback NSScreen.main"
                } else {
                    targetScreen = NSScreen.screens.first!
                    selectionReason = "volume followsMouse missing-mouse fallback firstScreen"
                }
            } else {
                if let primary = getPrimaryScreen() {
                    targetScreen = primary
                    selectionReason = "volume primaryDisplay"
                } else if let main = NSScreen.main {
                    targetScreen = main
                    selectionReason = "volume primaryDisplay missing-primary fallback NSScreen.main"
                } else {
                    targetScreen = NSScreen.screens.first!
                    selectionReason = "volume primaryDisplay missing-primary fallback firstScreen"
                }
            }
        #endif // !SANDBOX

        let selectedDisplayID: CGDirectDisplayID? = {
            guard
                let screenNumber = targetScreen.deviceDescription[NSDeviceDescriptionKey("NSScreenNumber")] as? NSNumber else { return nil }
            return CGDirectDisplayID(screenNumber.uint32Value)
        }()
        let selectedDisplayIDText = selectedDisplayID.map { String($0) } ?? "unknown"
        logger.debug("HUD screen selection: \(selectionReason), displayID=\(selectedDisplayIDText), frame=\(targetScreen.frame)")

        // Use full screen frame to ignore Dock positioning
        let screenFrame = targetScreen.frame

        let newWindowRect = HUDPreferences.windowRect(
            screenFrame: screenFrame,
            windowSize: windowSize,
            verticalPosition: HUDPreferences.storedVerticalPosition(),
        )

        // Update the window frame
        window.setFrame(newWindowRect, display: true)

        logger.debug("Updated HUD window position to: \(newWindowRect)")
    }

    /// Returns the NSScreen that currently contains the mouse cursor
    private func getScreenWithMouse() -> NSScreen? {
        let mouseLocation = NSEvent.mouseLocation

        for screen in NSScreen.screens where screen.frame.contains(mouseLocation) {
            return screen
        }

        return nil
    }

    /// Returns the NSScreen corresponding to the built-in display, if present
    private func getBuiltinScreen() -> NSScreen? {
        for screen in NSScreen.screens {
            if let screenNumber = screen.deviceDescription[NSDeviceDescriptionKey("NSScreenNumber")] as? NSNumber {
                let displayID = CGDirectDisplayID(screenNumber.uint32Value)
                if CGDisplayIsBuiltin(displayID) != 0 {
                    return screen
                }
            }
        }
        return nil
    }

    /// Returns the NSScreen corresponding to macOS's primary (menu bar) display, if present.
    private func getPrimaryScreen() -> NSScreen? {
        let mainDisplayID = CGMainDisplayID()
        for screen in NSScreen.screens {
            if let screenNumber = screen.deviceDescription[NSDeviceDescriptionKey("NSScreenNumber")] as? NSNumber {
                let displayID = CGDirectDisplayID(screenNumber.uint32Value)
                if displayID == mainDisplayID {
                    return screen
                }
            }
        }
        return nil
    }

    @MainActor
    private func displayHUD(hudType: HUDType, value: Float, isMuted: Bool) {
        // Cancel any existing hide timer
        hideTimer?.invalidate()
        hideAnimationGeneration += 1

        // Create or update the HUD window
        if hudWindow == nil {
            createHUDWindow()
        }

        // Update the content view
        if let window = hudWindow {
            let currentWindowSize = HUDPreferences.windowSize(size: HUDPreferences.storedSize())
            let currentGlassEffectEnabled = HUDPreferences.storedGlassEffectEnabled()
            let currentSnapshot = HUDContentSnapshot(
                kind: HUDContentKind(hudType: hudType),
                windowSideLength: currentWindowSize.width,
                glassEffectEnabled: currentGlassEffectEnabled,
                value: value,
                isMuted: isMuted,
            )
            let shouldUpdateContent = hostingView == nil
                || HUDContentRefreshPolicy.shouldRefresh(
                    previous: lastShownContentSnapshot,
                    current: currentSnapshot,
                )

            // If nothing changed and the window is already visible, just extend the timer
            if window.isVisible, !shouldUpdateContent {
                window.alphaValue = CGFloat(HUDPreferences.storedOpacity())
                updateWindowPosition(for: hudType)
                scheduleHideTimer()
                return
            }

            // Always recreate hosting view to avoid SwiftUI state issues
            let newHostingView = NSHostingView(rootView: HUDView(
                hudType: hudType,
                value: value,
                isMuted: isMuted,
                hudSize: currentWindowSize.width,
                glassEffectEnabled: currentGlassEffectEnabled,
            ))
            newHostingView.frame = NSRect(
                x: 0,
                y: 0,
                width: currentWindowSize.width,
                height: currentWindowSize.height,
            )

            // Ensure hosting view background is clear for proper material rendering
            newHostingView.wantsLayer = true
            newHostingView.layer?.backgroundColor = NSColor.clear.cgColor

            // Remove old content view if it exists
            if let oldView = window.contentView { oldView.removeFromSuperview() }

            window.contentView = newHostingView
            hostingView = newHostingView

            // Update position based on HUD type
            updateWindowPosition(for: hudType)

            // Show the window
            window.alphaValue = CGFloat(HUDPreferences.storedOpacity())
            window.orderFront(nil)
            isShowing = true
        }

        scheduleHideTimer()

        // Remember last shown state to avoid redundant view rebuilds
        lastShownContentSnapshot = HUDContentSnapshot(
            kind: HUDContentKind(hudType: hudType),
            windowSideLength: HUDPreferences.windowSize(size: HUDPreferences.storedSize()).width,
            glassEffectEnabled: HUDPreferences.storedGlassEffectEnabled(),
            value: value,
            isMuted: isMuted,
        )
    }

    @MainActor
    private func scheduleHideTimer() {
        hideTimer?.invalidate()
        hideTimer = Timer.scheduledTimer(withTimeInterval: 1.1, repeats: false) { [weak self] _ in
            Task { @MainActor in
                self?.hideHUD()
            }
        }
    }

    @MainActor
    private func createHUDWindow() {
        let windowSize = HUDPreferences.windowSize(size: HUDPreferences.storedSize())

        // Create the window with special properties for overlay
        hudWindow = NSWindow(
            contentRect: NSRect(x: 0, y: 0, width: windowSize.width, height: windowSize.height),
            styleMask: [.borderless],
            backing: .buffered,
            defer: false,
        )

        guard let window = hudWindow else {
            logger.error("createHUDWindow: failed to create NSWindow (hudWindow is nil)")
            return
        }

        // Configure window properties for overlay behavior. Use `.statusBar` level to appear above
        // normal windows but not block Exposé/Show Desktop.
        window.level = .statusBar
        window.isOpaque = false
        window.backgroundColor = .clear
        window.alphaValue = CGFloat(HUDPreferences.storedOpacity())
        window.hasShadow = false
        window.ignoresMouseEvents = true
        // Avoid .stationary: it can interact badly with Mission Control / Show Desktop.
        // `canJoinAllSpaces` is sufficient for cross-space visibility.
        window.collectionBehavior = [.canJoinAllSpaces, .ignoresCycle, .transient]

        // Set the initial position
        updateWindowPosition()

        // Start the window hidden (only show when volume changes)
        window.orderOut(nil)

        logger.debug("Created HUD window.")
    }

    // MARK: Hide HUD

    @MainActor
    private func hideHUD() {
        guard let window = hudWindow else { return }
        hideAnimationGeneration += 1
        let animationGeneration = hideAnimationGeneration

        // Animate fade-out before hiding
        NSAnimationContext.runAnimationGroup { context in
            context.duration = 0.11
            context.timingFunction = CAMediaTimingFunction(name: .easeInEaseOut)
            window.animator().alphaValue = 0.0
        } completionHandler: { [weak self] in
            Task { @MainActor [weak self] in
                guard let self, self.hideAnimationGeneration == animationGeneration else { return }
                window.orderOut(nil)
                window.alphaValue = CGFloat(HUDPreferences.storedOpacity()) // Reset for next show
                self.isShowing = false
            }
        }
    }
}
