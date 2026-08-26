# Axon iOS 16 Compatibility Fork

Axon is a Theos-based iOS tweak that provides Priority Hub-style grouped notifications for jailbroken iOS 16 devices. It reorganizes Lock Screen and Notification Center notifications by application, adds icon-based filtering, and exposes preference controls for layout, style, badges, haptics, sorting, and display behavior.

This archived compatibility fork targets a roothide-style package build and keeps the tweak logic and preference bundle together in one Theos project.

## Scope and Attribution

The original Axon package is credited to Nepeta and Baw Appie in the preserved package metadata. This repository focuses on iOS 16 compatibility, roothide packaging, consolidated build structure, and maintainable project documentation; it does not claim original authorship of Axon.

## Features

- Groups notifications by app on the Lock Screen and Notification Center.
- Supports horizontal and vertical layouts.
- App icons can show badge counts and optional backgrounds.
- Preference bundle for enabling the tweak, changing styles, alignment, icon behavior, sorting, spacing, haptics, and default visibility.
- Compatibility hooks for common lock-screen notification flows, including clearing and notification-history behavior.
- Builds a tweak bundle plus an `AxonPrefs` preference bundle.

## Requirements

- Jailbroken iOS 16 device using a compatible roothide environment.
- Theos installed and configured.
- MobileSubstrate-compatible injection environment.
- Xcode command-line tools or an equivalent iOS toolchain.

The package metadata is in `control` and declares:

- Package id: `me.nepeta.axon`
- Package name: `Axon`
- Firmware dependency: `>= 16.0`
- Architecture: `iphoneos-arm`

## Repository Layout

```text
.
|-- control              # Debian package metadata
|-- Makefile             # Top-level Theos aggregate
|-- Tweak/               # SpringBoard notification hooks and Axon UI
|-- Prefs/               # Preference bundle shown in Settings
`-- LICENSE
```

## Build

From the repository root:

```bash
make clean package
```

The top-level `Makefile` sets:

```make
THEOS_PACKAGE_SCHEME = roothide
FINALPACKAGE = 1
DEBUG = 0
```

The generated `.deb` package will be written under `packages/`.

## Install

Copy the built `.deb` to the device and install it with your package manager or with `dpkg` over SSH:

```bash
dpkg -i packages/*.deb
uicache -a
sbreload
```

If the preference bundle does not appear immediately, respring and reopen Settings.

## Preferences

Runtime preferences are stored at:

```text
/var/mobile/Library/Preferences/me.nepeta.axon.plist
```

Important preference keys include:

- `Enabled`
- `Vertical`
- `HapticFeedback`
- `BadgesEnabled`
- `BadgesShowBackground`
- `DarkMode`
- `SortingMode`
- `SelectionStyle`
- `Style`
- `ShowByDefault`
- `Alignment`
- `iconStyle`
- `VerticalPosition`
- `Spacing`

The preference bundle writes these values, and the tweak reads them during SpringBoard initialization.

## Development Notes

- `Tweak/Tweak.xm` contains the SpringBoard and Notification Center hooks.
- `Tweak/AXNManager.*` owns notification request state and filtering.
- `Tweak/AXNView.*` and `Tweak/AXNAppCell.*` render the grouped app selector.
- `Prefs/Resources/Prefs.plist` defines the settings UI.
- This project hooks private iOS classes, so iOS updates may require selector or class-name maintenance.

## License

GPL-3.0. See `LICENSE`.
