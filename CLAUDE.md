# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Language policy
- All files written to disk (CLAUDE.md, docs/*.md, code comments, commit messages) MUST be in English, regardless of the language used in the conversation.
- Chat responses to the user can remain in the user's language (Vietnamese).

## Environment constraint
- This machine is NOT capable of building (`bitbake` cannot be run here).
- All changes should ONLY be reviewed/analyzed statically; running `bitbake` or `runqemu` should NOT be recommended as something to execute in this environment.
- If verification is necessary, only verify by reading the syntax/dependencies; do not assume the build results. Use the `yocto` skill for release-aware, doc-grounded review of `.bb`/`.bbappend`/`.bbclass`/layer/machine config changes.

## Project overview
This is a personal study project for learning Yocto/BitBake, built around a Yocto/OpenEmbedded workspace for custom Linux images for the **BeagleBone Black**, targeting the **scarthgap** release of Poky. Actual building happens inside a devcontainer/Docker container (this repo is only the metadata: layers, build config, and notes), so treat everything under `.tmp/`, `tmp/`, `sstate-cache/`, `downloads/` as generated/non-authoritative and gitignored. Since the goal is learning, prefer explaining the *why* behind Yocto/BitBake concepts (layers, overrides, tasks, classes) over just making changes.

### Repo layout
- `env_init.sh` — one-time setup: clones `poky` into `.tmp/poky` (checked out at `scarthgap`).
- `setup.sh` — interactive menu to create/select a build directory under `src/builds/` and source `oe-init-build-env` for it.
- `run_docker.sh` — `cd .devcontainer && ./run.sh`, the entry point for the dev container.
- `.devcontainer/` — Docker Compose + Dockerfile (Ubuntu 22.04) defining the build environment; VS Code devcontainer with the `yocto-project.yocto-bitbake` extension. Workspace is mounted at `/home/yocto/workspace`.
- `src/layers/` — custom layers (see below).
- `src/builds/` — one subdirectory per BitBake build (each with its own `conf/`); `build-bbb-bsp` is the active/only fleshed-out build.
- `src/build-base/` — a template/reference `local.conf` (the stock Poky sample, machine-agnostic), not an actual build directory.
- `notes/` — free-form working notes (command history, porting notes, board overview); not documentation, treat as scratch/reference only.

### Layers
- `src/layers/meta-bbb-bsp` — the BSP layer for the custom board. `BBFILE_PRIORITY = "10"`, `LAYERSERIES_COMPAT = "scarthgap"`.
  - `conf/machine/bbb-custom.conf` requires upstream `beaglebone-yocto.conf` and applies `MACHINEOVERRIDES =. "beaglebone-yocto:"`.
  - `recipes-core/images/core-image-%.bbappend` — appends a `do_image_complete` postfunc that wipes and repopulates `${TOPDIR}/outputs/{wic,flash}` with the built `.wic`/`.wic.bmap`/rootfs tarball plus bootloader/kernel/dtb artifacts copied out of `DEPLOY_DIR_IMAGE`. This is the mechanism for getting flashable artifacts out of the Yocto `tmp/deploy` tree.
  - `recipes-kernel/linux/linux-yocto_%.bbappend` — currently a no-op stub (the LED devicetree overlay `bbb-custom-leds.dtsi` inclusion is commented out).
- `src/layers/meta-anhle` — a personal/example layer (`BBFILE_PRIORITY = "6"`) with a sample recipe (`recipes-example/example`) and a UART demo app (`recipes-apps/my-uart-app`, plain C compiled/installed via `do_compile`/`do_install`, no build system).
  - **Gotcha:** its `layer.conf` sets `LAYERSERIES_COMPAT_meta-anhle = "wrynose"`, inconsistent with the rest of the repo (`scarthgap`). It is also **not listed** in `src/builds/build-bbb-bsp/conf/bblayers.conf` — recipes in this layer (e.g. `my-uart-app`) are not currently reachable from the active build without adding the layer.

### Active build: `src/builds/build-bbb-bsp`
- `conf/bblayers.conf` — layers wired in: `poky/meta`, `poky/meta-poky`, `poky/meta-yocto-bsp`, `meta-bbb-bsp`, plus a devtool `workspace` layer. Paths are hardcoded to `/home/yocto/workspace/...` (the devcontainer mount point).
- `conf/local.conf` — `MACHINE = "bbb-custom"`; adds `wic`/`wic.bmap` to `IMAGE_FSTYPES`; `DL_DIR`/`SSTATE_DIR` point two levels up from the build dir (shared across builds).
- `build.sh` — `bitbake core-image-minimal`.
- `flash_wic.sh <device>` — flashes the built `.wic` via `bmaptool` to a block device (SD card/USB); requires interactive `yes` confirmation and destroys all data on the target. Never invoke non-interactively or assume a device path.
- `workspace/` — a `devtool`-managed workspace layer. `workspace/appends/linux-yocto_6.6.bbappend` uses `externalsrc` to build the kernel from `workspace/sources/linux-yocto` (an external source tree, not fetched via `SRC_URI`); `do_patch` is disabled (`noexec`) accordingly. This means kernel recipe changes are expected to happen by editing the external source tree, not by adding patches to the layer.

## Common layer/recipe commands (for reference — do not run bitbake/runqemu here)
```
bitbake-layers create-layer <layer-name>
bitbake-layers add-layer <layer-name>
bitbake-layers show-layers
bitbake my-uart-app
bitbake core-image-minimal
runqemu core-image-minimal nographic slirp snapshot qemuparams="-serial tcp:127.0.0.1:5555,server,nowait"
```
