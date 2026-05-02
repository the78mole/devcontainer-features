# nrf-tools Feature

This DevContainer feature installs
[nRF Command Line Tools](https://www.nordicsemi.com/Products/Development-tools/nRF-Command-Line-Tools)
(`nrfjprog`, `mergehex`) together with
[J-Link](https://www.segger.com/products/debug-probes/j-link/) from the
**official SEGGER `.tgz` archive** required for `west flash` and `west debug`
on nRF52 / nRF53 / nRF91 targets.

The installation is fully headless (no Qt, no X11) and is suitable for CI/CD
containers.

> **License notice:** Installing J-Link requires you to accept the
> [SEGGER J-Link EULA](https://www.segger.com/downloads/jlink/).
> You must set `acceptSeggerEula: true` in your devcontainer options.

## Options

| Option           | Type    | Default   | Description                                                                                         |
| ---------------- | ------- | --------- | --------------------------------------------------------------------------------------------------- |
| nrfCliVersion    | string  | `10.24.2` | Version of nRF Command Line Tools to install                                                        |
| version          | string  | `V796a`   | Version of J-Link to install. See <https://www.segger.com/downloads/jlink/> for available versions. |
| acceptSeggerEula | boolean | `false`   | **Required.** Read and accept the SEGGER EULA at <https://www.segger.com/downloads/jlink/> first.   |

## Usage

```json
{
  "features": {
    "ghcr.io/the78mole/devcontainer-features/nrf-tools:1": {
      "acceptSeggerEula": true
    }
  },
  "runArgs": ["--privileged"],
  "mounts": ["source=/dev,target=/dev,type=bind"]
}
```

### Custom versions

```json
{
  "features": {
    "ghcr.io/the78mole/devcontainer-features/nrf-tools:1": {
      "nrfCliVersion": "10.24.2",
      "version": "V796a",
      "acceptSeggerEula": true
    }
  },
  "runArgs": ["--privileged"],
  "mounts": ["source=/dev,target=/dev,type=bind"]
}
```

## What's Installed

| Binary / Library      | Location                             | Description                        |
| --------------------- | ------------------------------------ | ---------------------------------- |
| `nrfjprog`            | `/usr/bin/nrfjprog`                  | Flash & debug tool for nRF devices |
| `mergehex`            | `/usr/bin/mergehex`                  | Merge Intel HEX files              |
| J-Link installation   | `/opt/SEGGER/JLink/`                 | Full J-Link toolset                |
| `JLinkExe`            | `/usr/local/bin/JLinkExe`            | J-Link Commander (CLI)             |
| `JLinkGDBServerCLExe` | `/usr/local/bin/JLinkGDBServerCLExe` | J-Link GDB Server (headless)       |
| `JLinkRTTClient`      | `/usr/local/bin/JLinkRTTClient`      | RTT Client                         |
| `JLinkRTTLogger`      | `/usr/local/bin/JLinkRTTLogger`      | RTT Logger                         |
| `libjlinkarm.so`      | `/usr/lib/libjlinkarm.so`            | Symlink to J-Link shared library   |

> **udev rules** are **not** installed inside the container – see
> [Host: udev rules](#host-udev-rules-for-usb-access) below.

## How It Works

1. Checks that `acceptSeggerEula` is `true` – aborts immediately otherwise.
2. Downloads `nrf-command-line-tools_<VERSION>_<ARCH>.deb` from Nordic's
   Azure blob storage and installs it with `dpkg`. `<ARCH>` is `amd64` or
   `arm64`.
3. Downloads `JLink_Linux_<VERSION>_<ARCH>.tgz` from
   `https://www.segger.com/downloads/jlink/` using `curl` with
   `-d "accept_license_agreement=accepted"` (POST form parameter required by
   the SEGGER download server). `<ARCH>` is auto-detected from `uname -m`
   (`x86_64`, `arm64`, or `arm`).
4. Extracts the archive to `/opt/SEGGER/JLink`.
5. Creates symlinks for CLI tools in `/usr/local/bin`.
6. Symlinks `libjlinkarm.so` into `/usr/lib/` and runs `ldconfig`.
7. Deletes the downloaded `.tgz` archive.

## Requirements

- **Architecture**: `amd64` / `x86_64` and `arm64` / `aarch64` – full support
  (nRF CLI + J-Link). 32-bit ARM is not supported.
- **OS**: Debian / Ubuntu based images (uses `apt-get`, `dpkg`, `wget`, `curl`).

## Example: west flash inside a devcontainer

```bash
# J-Link probe must be accessible on the host (udev rules applied) and
# forwarded to the container via runArgs / USB/IP
west flash --runner jlink
```

## Host: udev rules for USB access

udev is a host-level daemon – rules installed inside a container have no
effect on the host and are therefore **not** copied by this feature.

To allow non-root users on the **host** to access a J-Link probe, install the
rules file once on the host machine.

### Option A – Helper script (recommended)

A ready-to-use script is included in this repository. Run it **on the host**
from the root of the checked-out repo:

```bash
bash scripts/install-host-udev-rules.sh
```

The script automatically locates the running devcontainer, extracts
`/opt/SEGGER/JLink/99-jlink.rules` from it and installs it to
`/etc/udev/rules.d/`. You can also pass the container name explicitly:

```bash
CONTAINER=my_container bash scripts/install-host-udev-rules.sh
```

### Option B – Manual one-liner

```bash
docker exec <container_name> cat /opt/SEGGER/JLink/99-jlink.rules \
  | sudo tee /etc/udev/rules.d/99-jlink.rules
sudo udevadm control --reload-rules
sudo udevadm trigger
```

### Option C – Package manager

Many Linux distributions provide a `jlink-udev` or `libjaylink` package that
ships the same rules.

## Notes

- Hardware access (USB probe) requires `"runArgs": ["--privileged"]` and
  `"mounts": ["source=/dev,target=/dev,type=bind"]` in your `devcontainer.json`.
  Static `--device` entries are resolved at container start and miss probes
  that are plugged in afterwards.
- For CI builds without attached hardware, use `west build` only or a
  simulation runner.
