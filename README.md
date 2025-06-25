# LPLS - Launchpad Lightshow

A Flutter-based application for creating and performing lightshows on various platforms using different Novation Launchpad devices.

## Why?

Ableton Live is powerful, but creating light effects with its standard tools is complicated and unintuitive. Additionally, Ableton Live is not available on Linux — and likely never will be.

## Supported Operating Systems

- Windows
- Linux  
- ~~Android~~ (planned, not yet supported)

## Features

- Import `.lpls` project files.
- Export `.lpls` project files (desktop only).
- Open and save unpacked projects (`.lpp` format) (desktop only).
- Create and edit effects (`.lpe` format) (desktop only).

## Launchpad Compatibility

As of version **0.1.0**, the following Launchpad models are supported:

- Launchpad Mini
- Launchpad Mk2
- Launchpad Mini Mk3 (in Legacy Mode)

### How to Enter Legacy Mode (Launchpad Mini Mk3)

Make sure your device is running the latest firmware.

1. Hold the `Session` button.
2. When the setup grid appears, release `Session` and press the **violet pad** (third from the bottom in the far-right column).
3. You’ll see the word **Legacy** appear on the screen. You can skip it by pressing any button.
4. Press the `Session` button again (or the bottom-right pad on the grid) to confirm.
5. Your device is now in Legacy Mode.

## Roadmap

- [ ] Full localization
- [ ] Android support (via [`minisound`](https://pub.dev/packages/minisound) and updated Android SDK)
- [ ] Persistent settings