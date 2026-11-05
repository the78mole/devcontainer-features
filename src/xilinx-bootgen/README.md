# Xilinx Bootgen (xilinx-bootgen)

This DevContainer feature installs
[bootgen](https://github.com/Xilinx/bootgen), the AMD/Xilinx tool that creates
boot images (`BOOT.BIN`) for Zynq-7000, Zynq UltraScale+ MPSoC and Versal
devices.

bootgen is installed from the distribution package `xilinx-bootgen`, so only
Debian and Ubuntu based images are supported.

## Options

| Option  | Type   | Default  | Description                                                                                         |
| ------- | ------ | -------- | --------------------------------------------------------------------------------------------------- |
| version | string | `latest` | `latest` (repository candidate) or an exact package version of `xilinx-bootgen`, e.g. `2022.2-2+b1` |

## Usage

```json
{
  "features": {
    "ghcr.io/the78mole/devcontainer-features/xilinx-bootgen:1": {}
  }
}
```

```bash
bootgen -arch zynqmp -image boot.bif -o BOOT.BIN -w on
```

## Notes

- The bootgen version is the one shipped by the distribution (currently
  `2022.2` in Debian and Ubuntu). Available versions can be listed with
  `apt-cache policy xilinx-bootgen`.
- The open-source bootgen does not support traditional FPGA families (Artix,
  Kintex, Virtex) or obfuscated key generation; use the bootgen bundled with
  Vivado/Vitis for those.
