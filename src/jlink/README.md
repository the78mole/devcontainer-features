# jlink Feature

This DevContainer feature installs the
[SEGGER J-Link](https://www.segger.com/products/debug-probes/j-link/) toolset
from the **official SEGGER `.tgz` archive**.

The installation is fully headless (no Qt, no X11) and is suitable for CI/CD
containers.

> **License notice:** Installing J-Link requires you to accept the
> [SEGGER J-Link EULA](https://www.segger.com/downloads/jlink/).
> You must set `acceptSeggerEula: true` in your devcontainer options.

## Options

| Option           | Type    | Default | Description                                                                                         |
| ---------------- | ------- | ------- | --------------------------------------------------------------------------------------------------- |
| version          | string  | `V796a` | Version of J-Link to install. See <https://www.segger.com/downloads/jlink/> for available versions. |
| acceptSeggerEula | boolean | `false` | **Required.** Read and accept the SEGGER EULA at <https://www.segger.com/downloads/jlink/> first.   |

## Usage

```json
{
  "features": {
    "ghcr.io/the78mole/devcontainer-features/jlink:0": {
      "acceptSeggerEula": true
    }
  },
  "runArgs": ["--privileged"],
  "mounts": ["source=/dev,target=/dev,type=bind"]
}
```

### Pinned version

```json
{
  "features": {
    "ghcr.io/the78mole/devcontainer-features/jlink:0": {
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
| `JLinkExe`            | `/usr/local/bin/JLinkExe`            | J-Link command line interface      |
| `JLinkGDBServerCLExe` | `/usr/local/bin/JLinkGDBServerCLExe` | J-Link GDB server (headless)       |
| `JLinkRTTClient`      | `/usr/local/bin/JLinkRTTClient`      | RTT terminal client                |
| `JLinkRTTLogger`      | `/usr/local/bin/JLinkRTTLogger`      | RTT data logger                    |
| `libjlinkarm.so`      | `/usr/lib/libjlinkarm.so`            | J-Link shared library (symlink)    |
| J-Link installation   | `/opt/SEGGER/JLink/`                 | Full J-Link installation directory |

## Host: udev Rules for USB Access

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
- For CI builds without attached hardware, use `JLinkExe` in script mode only.
