# 🐉🗡 HydraKiller

HydraKiller is a lightweight macOS application bundle and daemon wrapper
designed to mitigate runaway Apple system daemons (`photoanalysisd`,
`mediaanalysisd`, and `photolibraryd`) on macOS Monterey 12.0 and later.

These background processes frequently trigger a cascading bug that forces the
macOS "Shared with You" "Syndication" database write-ahead log
(`Photos.sqlite-wal`) to grow unchecked, wasting significant CPU cycles and
consuming hundreds of gigabytes of disk space until the hard drive is completely
full.

Because launchd aggressively restarts these daemons like a replicating hydra,
this project uses a C99 application shim to cleanly disable the daemons, wait
out their file locks, and truncate the runaway SQLite database safely under full
Transparency, Consent, and Control (TCC) authorization.

In other words... It kills Apple's hydra and saves your CPU & disk! 🐉🗡

------------------------------

## 🛠️ System Architecture

Standard background scripts run via `launchd` trigger strict macOS TCC security
blocks when attempting to access user Photos libraries. HydraKiller solves this
by packaging a POSIX-compliant shell script inside a native compiled macOS App
Bundle container.  Thus, it can be run within the inherited permissions context
from the App bundle.

- `HydraKiller.app`: A signable C99 application binary wrapper that resolves its
  own bundle paths and executes the embedded shell script payload via `execv`.
- `truncate_syndication_wal.sh`: The underlying POSIX script that sequentially
  disables and kills the daemons, monitors file locks via `lsof` to prevent
  database corruption, and safely truncates the write-ahead log.
- Launch Agent: Automates execution on a periodic background interval
  (e.g., hourly).
  - **On macOS Monterey:**
    `com.lyraphase.HydraKillerLauncher.truncatesyndication.plist` —
    A native user `LaunchAgent` that uses the older `Program` and
   `ProgramArguments` `plist` keys, for macOS 12.x compatibility
  - **On macOS Ventura or later:** `com.lyraphase.HydraKillerLauncher.plist` — A
    native bundled `LaunchAgent` that uses `BundleProgram` `plist` key to launch
    the embedded shim and script.  This makes it possible for the
    `HydraKillerLauncher.app` to register the `LaunchAgent` with Apple's
    `SMAppService` API.

------------------------------

## 🚀 Installation & Setup

### App Store (Maybe in future)

TODO! I don't have an Apple Developer account, which requires $$, time, and
possibly more entitlements & code signing debugging.

### Manual Build

### 1. Embed and Build the Application

- Open the project in Xcode. Ensure your target type is a macOS App Template named `HydraKillerLauncher`.
- Compile the project (`Product` -> `Build For` -> `Running`) or press
   <kbd>⌘</kbd>+<kbd>Shift</kbd>+<kbd>R</kbd>.
- Find the built App (`Product` -> `Show Build Folder in Finder`)
- Move the compiled App package to your `/Applications` folder.
   Drag and drop the `HydraKillerLauncher.app`, OR run:

      cp -R /path/to/built/HydraKillerLauncher.app ~/Applications

### 2. Configure the LaunchAgent Daemon

#### macOS Ventura `13.0` and Above

Run the `HydraKillerLauncher.app` once to trigger registering the `LaunchAgent`.

#### macOS Monterey `12.x`

Copy the `com.lyraphase.HydraKillerLauncher.truncatesyndication.plist`
configuration file into your user `LaunchAgents` folder:

    cp HydraKillerLauncher/com.lyraphase.HydraKillerLauncher.truncatesyndication.plist  ~/Library/LaunchAgents/
    launchctl load ~/Library/LaunchAgents/com.lyraphase.HydraKillerLauncher.truncatesyndication.plist

### 3. Authorize Full Disk Access (Optional)

In case the Photos library permissions were not enough, you can enable
_Full Disk Access_ to workaround issues with Apple's app sandbox permissions.

Because the app relies on a compiled app bundle rather than a raw terminal
script, this allows it to be whitelisted natively in macOS System Settings:

- Navigate to `System Settings` -> `Privacy & Security` -> `Full Disk Access`.
- Click the `+` (Plus) button.
- Locate `/Applications/HydraKillerLauncher.app` and add it to the list.
- Toggle the permission switch next to it to `On`.

## 4. Start the Service

### macOS Ventura `13.0` and Above

To run manual mitigation immediately at any time:

    launchctl start com.lyraphase.HydraKillerLauncher

### macOS Monterey `12.x`

To run manual mitigation immediately at any time:

    launchctl start com.lyraphase.HydraKillerLauncher.truncatesyndication

## 5. Print Service Details

### macOS Ventura `13.0` and Above

    launchctl print gui/$(id -u)/com.lyraphase.HydraKillerLauncher

### macOS Monterey `12.x`

    launchctl print gui/$(id -u)/com.lyraphase.HydraKillerLauncher.truncatesyndication

## 🧾 License

This project is open-source software licensed under the
[GNU Affero General Public License v3.0 (AGPLv3)][agpl-3.0].

See [LICENSE](LICENSE)

## 🔗 References & Acknowledgments

* [Controlling photoanalysisd background workloads: G.J. Bianco on dev.to][1]
* [App bundle project structure and wrapper mechanics: StackOverflow Compilation Guidelines][2]
* [Runaway `mediaanalysisd` & Syndication WAL analysis: MacRumors Forums][3] (Posts #29 and #30 by myself)

[agpl-3.0]: https://choosealicense.com/licenses/agpl-3.0/
[1]: https://dev.to/gjbianco/controlling-photoanalysisd-3j2a
[2]: https://stackoverflow.com/a/67152388/645491
[3]: https://forums.macrumors.com/threads/mediaanalysisd-photoanalysisd-and-photolibraryd.2445597/post-34063746
