# AGENTS.md — Axon (iOS 16 & Rootless)

Axon is an **iOS jailbreak tweak** built with **Theos**, originally created by Nepeta and maintained by Baw Appie, modernized for **iOS 15–16+ rootless jailbreaks (Dopamine, Palera1n)** by Chase Dustevich. It brings Priority Hub-style grouped notifications by application to the Lock Screen and Notification Center (`NCNotificationStructuredListViewController` / `NCNotificationCombinedListViewController`). It also includes a **Settings (PreferenceLoader) bundle** for live configuration.

- Package ID: `me.nepeta.axon` (see `control`, version `1.5.1`).
- Scheme: **rootless only** (`THEOS_PACKAGE_SCHEME = rootless`, `iphoneos-arm64`, installs under `/var/jb`).
- Depends on: `mobilesubstrate`, `preferenceloader`, `firmware (>= 15.0)`
- Primary test environment: Dopamine, iOS 16.5
- Origin fork: `https://github.com/chasedustevich/axon-ios16-compatibility`
- Attribution: Nepeta & Baw Appie; modernized by Chase Dustevich

## Layout

| Path | Purpose |
|---|---|
| `Tweak/Tweak.xm` | SpringBoard & Notification Center hooks: hooks `NCNotificationStructuredListViewController` (iOS 13+ / iOS 16) and `NCNotificationCombinedListViewController`, handles filtering, insertion, removal, and clearing. |
| `Tweak/AXNManager.h/.m` | Singleton notification manager: tracks requests by bundle identifier, handles count caches, timestamps, icons, and coordinates clearing with `NCNotificationDispatcher`. |
| `Tweak/AXNView.h/.m` | Main Axon horizontal/vertical collection view displaying grouped application icons. |
| `Tweak/AXNAppCell.h/.m` | Individual collection view cell for each application icon, badge counter, and long-press clear menu. |
| `Tweak/AXNRequestWrapper.h/.m` | Model wrapper around `NCNotificationRequest`. |
| `Prefs/` | PreferenceLoader bundle `AxonPrefs` (`AXNPrefsListController`, Location, Debug options). |
| `Prefs/Resources/Prefs.plist` | Specifiers for Axon configuration (styles, alignment, badges, sorting, vertical layout). |
| `control` | Debian package control metadata (`iphoneos-arm64`, version 1.5.1). |
| `Makefile` | Root aggregate Theos makefile targeting iOS 15.0+ rootless. |
| `README.md` | User documentation and build instructions. |

## How it works & The Notification Clearing Fix

1. **Root Cause of Stuck Notifications:**
   - Previous versions checked `if (!req.bulletin || !req.bulletin.sectionID)` when removing notifications. Modern iOS (iOS 15/16) frequently passes requests where `req.bulletin` is nil on remote/app dismissals, using `req.sectionIdentifier` instead. Those dismissals were ignored.
   - `removeNotificationRequest:` only called `%orig` when the notification's app was currently selected on screen. If no app or a different app was active, `%orig` was skipped, leaving zombie notifications inside SpringBoard's `NCNotificationMasterList`.
   - `hideNotificationRequest:` erroneously called `[self insertNotificationRequest:req]`. Every time the display woke up or went to sleep, `reset` called `hideAllNotificationRequests` which forcibly resurrected all dismissed notifications from `clvc.allNotificationRequests` back into Axon's dictionary.
   - Once a dismissed notification became a zombie, `usernotificationsd` no longer tracked it, making subsequent clear actions no-ops until a respring cleared SpringBoard's memory.
   - `clearAll:` and `clearAll` in `AXNManager` did not synchronize state with `self.clvc`, did not clear `countCache` or `timestamps`, and left empty entries in `notificationRequests`.

2. **The Fix:**
   - Unified bundle identifier extraction using `req.sectionIdentifier ?: req.bulletin.sectionID`.
   - In `removeNotificationRequest:`, all entries matching `[req notificationIdentifier]` are removed across all bundle identifiers, and empty arrays are pruned.
   - In `Tweak.xm`, `removeNotificationRequest:` forwards to `%orig` with `axnAllowChanges = YES` even when the bundle is not actively selected, keeping SpringBoard's underlying `masterList` strictly in sync.
   - Removed `[self insertNotificationRequest:req]` from `hideNotificationRequest:`.
   - Added missing clear hooks (`_clearAllNotificationRequests`, `_clearAllPriorityListNotificationRequests`, `clearAll`) to `NCNotificationStructuredListViewController`.
   - In `clearAll:` and `clearAll`, requests are actively cleared from `self.clvc`, caches are emptied, and the UI view is reset and refreshed immediately.

3. **Rootless Architecture:**
   - Switched from legacy `roothide` to standard Theos rootless (`THEOS_PACKAGE_SCHEME = rootless`, `iphoneos-arm64`).
   - Replaced `<roothide.h>` and `jbroot` with `<rootless.h>`, `ROOT_PATH`, `ROOT_PATH_NS`, and bundle-relative asset loading.

## Build / install

Requires [Theos](https://theos.dev/) with `$THEOS` set and an iOS 15+ SDK.

```sh
make clean package                                # build rootless .deb (iphoneos-arm64)
make package install THEOS_DEVICE_IP=<device-ip>  # install over SSH, then respring
```
