# Axon (Rootless, iOS 15–16+)

<p align="center">
  <img src="https://img.shields.io/badge/iOS-15.0%2B-blue.svg" alt="iOS 15.0+">
  <img src="https://img.shields.io/badge/Scheme-Rootless-success.svg" alt="Rootless">
  <img src="https://img.shields.io/badge/Arch-arm64%20%7C%20arm64e-orange.svg" alt="Architecture">
  <img src="https://img.shields.io/badge/Jailbreak-Dopamine%20%7C%20Palera1n-purple.svg" alt="Jailbreak">
  <img src="https://img.shields.io/badge/Version-1.6.0-brightgreen.svg" alt="Version">
</p>

Axon is a lightweight, elegant iOS jailbreak tweak built with Theos that brings **Priority Hub-style grouped notifications** to the Lock Screen and Notification Center. It reorganizes notifications by application icon, adds fast tap-to-filter management, and provides extensive preference customization for layout, style, badge count, haptics, sorting, and display behavior.

Originally created by **Nepeta** and maintained by **Baw Appie**. Updated and modernized for **modern rootless jailbreaks (iOS 15–16+, Dopamine, Palera1n)** by **Chase Dustevich** (version 1.6.0) with assistance from **Antigravity** (Google DeepMind).

---

> **Note (v1.6.0 Rootless Update):** This release updates the original Axon tweak to modern rootless architecture (`THEOS_PACKAGE_SCHEME = rootless`, `iphoneos-arm64`, installing under `/var/jb`) for iOS 15–16+ (tested on Dopamine, iOS 16.5) by Chase Dustevich. It fixes the long-standing bug where notifications got stuck in the UI over time and couldn't be cleared without a respring, repairs dynamic collection view alignment across different screen widths, and modernizes the build configuration. All original credit and licensing go to Nepeta and Baw Appie.

---

## ✨ Features

- **App-Grouped Notifications:** Groups Lock Screen and Notification Center alerts neatly by application icon.
- **Rootless Jailbreak Support:** Fully updated and built for modern rootless environments (`/var/jb`) on iOS 15.0 through iOS 16+.
- **Reliable Notification Clearing:** Completely resolves the stuck/ghost notification issue where notifications required multiple resprings to clear. State is strictly synchronized between SpringBoard's master list, `AXNManager`, and the system notification dispatcher.
- **Dynamic Alignment:** Proper real-time centering, left, and right alignment calculation on `layoutSubviews`.
- **Horizontal & Vertical Layouts:** Choose between a sleek horizontal bar across the screen or a vertical column alongside notification content.
- **Visual Styles & Badges:** Six distinct visual styles (Default, Packed, Compact, Tiny, Group, and Group Rounded) with notification count badges and adaptive background color analysis.
- **Live Preferences:** Full PreferenceLoader settings pane in the Settings app with instant Darwin notification reloading (`me.nepeta.axon/ReloadPrefs`) and a rootless Respring button.

---

## 🛠️ Technical Implementation & The iOS 16 Fixes

### 1. Rootless Architecture
- Modern rootless jailbreaks (Dopamine, Palera1n) stage jailbreak payloads under `/var/jb`.
- Axon now builds with standard Theos rootless packaging: `THEOS_PACKAGE_SCHEME = rootless`, targeting universal `arm64` and `arm64e` architectures (`iphoneos-arm64`).
- Replaced legacy `roothide` headers and hardcoded paths with `<rootless.h>`, `ROOT_PATH`, `ROOT_PATH_NS`, and dynamic bundle-relative asset resolution (`[NSBundle bundleForClass:]`).

### 2. The Stuck / Ghost Notification Bug
In previous builds, notifications frequently jammed in the Axon interface, refusing to clear or tap until a respring was executed:
- **`nil` Bulletin on Modern Dismissals:** Modern iOS (iOS 15–16+) often dismisses notifications with `req.bulletin = nil`, relying exclusively on `req.sectionIdentifier`. Old checks evaluated `if (!req.bulletin || !req.bulletin.sectionID)` and dropped those dismissals, leaving zombie items in memory. Axon now resolves identifiers using `req.sectionIdentifier ?: req.bulletin.sectionID`.
- **SpringBoard MasterList Desynchronization:** `removeNotificationRequest:` only forwarded to `%orig` if the notification's app was currently selected. If another app or no app was active, `%orig` was skipped, leaving the dismissed notification trapped inside SpringBoard's `NCNotificationMasterList`. We now invoke `%orig` with `axnAllowChanges = YES` to ensure SpringBoard's list stays in sync.
- **Resurrection Loop in `hideNotificationRequest:`:** The previous implementation contained an erroneous `[self insertNotificationRequest:req]` inside `hideNotificationRequest:`. Every time the display turned off or woke up, all notifications were resurrected back into Axon's dictionary even after daemon-level dismissal. This has been removed.
- **Complete Cache and List Purging:** `clearAll:` and `clearAll` now actively synchronize removal with `self.clvc`, flush the count and timestamp caches, prune empty dictionary keys, and refresh the collection view immediately.

### 3. Collection View Alignment Fix
- Previous versions erroneously declared `-viewDidLayoutSubviews` on `AXNView` (which is a `UIView`, not a `UIViewController`), so UIKit never called it. When AutoLayout expanded the view from its initial 64pt width, the collection view layout was never invalidated, causing insets to calculate against 64pt and remain permanently pinned to the left edge.
- Replaced with `-layoutSubviews` to correctly trigger layout invalidation whenever view bounds change.
- Replaced broken `semanticContentAttribute` RTL logic with explicit, dynamic section inset calculations for Left (`0`), Center (`1`), and Right (`2`) alignments across all cell styles.

---

## 📋 Requirements

- Jailbroken iOS 15.0–16.x+ device using a rootless jailbreak (Dopamine, Palera1n).
- Theos with an iOS 15+ SDK.
- MobileSubstrate / ElleKit tweak injection environment.
- PreferenceLoader.

Package metadata in `control`:
- **Package:** `me.nepeta.axon`
- **Name:** `Axon`
- **Version:** `1.6.0`
- **Architecture:** `iphoneos-arm64`
- **Depends:** `mobilesubstrate, preferenceloader, firmware (>= 15.0)`

---

## 🚀 Build & Install

### Building
From the repository root with `$THEOS` set:

```bash
make clean package
```

The top-level `Makefile` configures:

```make
export TARGET = iphone:clang:latest:15.0
export ARCHS = arm64 arm64e
export THEOS_PACKAGE_SCHEME = rootless
FINALPACKAGE = 1
DEBUG = 0
```

The compiled package will be placed in `packages/me.nepeta.axon_1.6.0_iphoneos-arm64.deb`.

### Installing
To install over SSH to a jailbroken device:

```bash
make package install THEOS_DEVICE_IP=<device-ip>
```

Or copy the `.deb` file to your device and install via Sileo, Zebra, or the terminal:

```bash
dpkg -i me.nepeta.axon_1.6.0_iphoneos-arm64.deb
```

---

## ⚙️ Preferences

Runtime preferences are stored at:
```text
/var/mobile/Library/Preferences/me.nepeta.axon.plist
```

Key preference controls available in Settings > Axon:
- **Enabled:** Enable or disable Axon.
- **Style:** Default, Packed, Compact, Tiny, Group, Group Rounded.
- **Alignment:** Left, Center (default), Right.
- **Vertical Mode:** Displays the app icon column vertically along the side of the display.
- **Sorting Mode:** By Date, By Count, By Name.
- **Badges:** Toggle badge counts and adaptive color backgrounds.
- **Show By Default:** None, Latest Notification, First Section, Selected Section.
- **Haptic Feedback:** Vibrates when tapping on an app icon.

---

## 📜 Scope & Attribution

The original Axon was created by **Nepeta** and maintained by **Baw Appie**. This repository provides the **v1.6.0 rootless update**, authored by **Chase Dustevich** with assistance from **Antigravity** (Google DeepMind), modernizing the tweak for iOS 15–16+ rootless environments and fixing persistent notification-clearing and alignment issues.

## 📄 License

GPL-3.0. See [LICENSE](LICENSE).
