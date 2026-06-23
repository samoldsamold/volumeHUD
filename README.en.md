# volumeHUD

<p align="right">
  <a href="./README.md"><kbd>中文</kbd></a>
  <strong>English</strong>
</p>

This is a personal fork of Danny Stewart's
[volumeHUD](https://github.com/dannystewart/volumeHUD). It keeps the classic
macOS volume and brightness HUD experience and adds more HUD appearance
customization.

This fork preserves the original MIT license attribution and records fork
modification attribution in [NOTICE](./NOTICE).

## What's New

- Adjustable HUD size. `30%` matches the original 200 px HUD size.
- Adjustable HUD height, including centered placement and **Set to Default** for the original lower placement.
- Adjustable HUD opacity.
- Optional native Liquid Glass style for the HUD background.
- Live HUD previews while changing size, height, opacity, and glass settings.
- Direct percentage input next to each HUD appearance slider.
- Clean custom settings sliders without native tick-like marks.
- Improved icon and level-bar contrast in light, dark, classic material, and Liquid Glass modes.
- **Set to Default** restores the original author's HUD appearance defaults.
- About window shows this fork's maintainer attribution.
- Update checks target `samoldsamold/volumeHUD`.

## Screenshots

<p>
  <img src="Images/volumeHUD-demo.gif" alt="volumeHUD Demo" height="300">
</p>

<p>
  <img src="Images/volumeHUD-settings.png" alt="volumeHUD settings in light mode" width="49%">
  <img src="Images/volumeHUD-settings-dark.png" alt="volumeHUD settings in dark mode" width="49%">
</p>

## Usage

Launch the app to start using the volume HUD. Launch it again to open the settings window, where you can enable open-at-login, brightness HUD support, choose the HUD display, adjust HUD size/height/opacity, toggle Liquid Glass, and quit the app.

Brightness HUD support is off by default. It only supports built-in displays and should still be considered experimental.

volumeHUD intercepts volume/brightness keys and hides the system HUD. If key interception is not working on your system, the app disables interception so you can still adjust volume or brightness normally.

## Installation

Download the latest build from this fork's GitHub Releases page:

<https://github.com/samoldsamold/volumeHUD/releases/latest>

For local development builds, you can build the app with Xcode and copy it to `/Applications`. To replace an older version, quit volumeHUD first, then overwrite `/Applications/volumeHUD.app`.

## Permissions

volumeHUD requests two optional but recommended permissions:

- **Notifications**: only used to confirm that the app started after a manual launch.
- **Accessibility**: required for full key interception and system HUD hiding.

Without Accessibility permission, the app still runs, but the system HUD may appear alongside volumeHUD, and edge-level volume/brightness detection may be incomplete.

## Troubleshooting

If HUD behavior is inconsistent, Accessibility permission state is the most likely cause. Try a clean reinstall:

1. Launch volumeHUD again and click **Quit volumeHUD**.
2. Open **System Settings** -> **Privacy & Security** -> **Accessibility**.
3. Remove **volumeHUD** from the list.
4. Delete `/Applications/volumeHUD.app`.
5. Reinstall the latest release from this fork.
6. Launch the app again and grant Accessibility permission when prompted.

## License

This project is open source under the [MIT License](./LICENSE).

The original project copyright belongs to Danny Stewart. This fork preserves the original copyright notice and adds modification attribution for ZHOU YONGYU in [NOTICE](./NOTICE).
