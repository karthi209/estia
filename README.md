# Estia

*The centre of your desktop.*

GNOME-inspired quick settings for KDE Plasma 6 with a slate palette and a
compact panel button. The widget includes audio output and per-app volume,
monitor brightness, Wi-Fi, Bluetooth, power profiles, Night Light, and Do Not
Disturb. Use **Edit quick settings** to show, hide, or reorder tiles. Plasma's
native system tray handles third-party application icons.

**Keep Awake**, **Media**, **Battery**, and **Clipboard** appear when PowerDevil,
a controllable MPRIS player, a present UPower battery, or Klipper is available.
Clipboard opens KDE’s native history picker.

Use the widget’s **Keyboard Shortcuts** configuration page to assign a global
shortcut. Opening the popup focuses volume when available. The camera button
opens Spectacle without taking a screenshot.

## Install

From the repository root, install the widget for your user:

```sh
kpackagetool6 --type Plasma/Applet --install ./plasmoids/org.slatematerial.controlcenter
```

Use `--upgrade` for an existing installation. Add **Estia**
from Plasma's widget picker. Installation requires KDE Plasma and its native
modules. The Slate Dark palette and symbols ship with Estia. It uses regular
system fonts and keeps its own typography hierarchy. Slate Light and System
colour presets are planned.

Development validation used Fedora KDE, Plasma 6.8.3, Qt 6.11.2, and Wayland.
Missing optional KDE modules can make the associated controls unavailable.
Display modes, monitor arrangement, and new Bluetooth pairing open KDE Settings.

To uninstall:

```sh
kpackagetool6 --type Plasma/Applet --remove org.slatematerial.controlcenter
```

This is a development preview. Author and license notices still need
confirmation before public distribution.
