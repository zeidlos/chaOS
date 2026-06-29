# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

chaOS is a custom [bootc](https://github.com/bootc-dev/bootc) OCI image based on `quay.io/fedora/fedora-bootc:44`. It bundles the COSMIC desktop, Steam/gaming packages, and a curated set of productivity tools. The built image is published to GHCR and can be switched to directly from any running bootc system.

## Key Commands

```bash
just build          # Build the container image with Podman
just lint           # Run shellcheck on all .sh files
just format         # Run shfmt --write on all .sh files
just check          # Validate Justfile/Just syntax (dry-run)
just fix            # Auto-fix Justfile syntax
just clean          # Remove build artifacts (output/, *.manifest.json, etc.)

# VM image targets (qcow2 / raw / iso)
just build-qcow2    # Build container then produce a QCOW2 disk image
just run-vm-qcow2   # Build if needed, then launch QEMU via browser VNC
just spawn-vm       # Run QCOW2 via systemd-vmspawn (GUI)
```

All `just` commands load their defaults from `image-template.env`.

## Architecture

### Build flow

```
Containerfile
  ├── stage ctx   — mounts build_files/ and system_files/ without copying them into the final image
  └── stage final — FROM fedora-bootc:44
        ├── bind-mounts ctx at /ctx
        ├── runs /ctx/build.sh       ← all package installs and config live here
        └── runs bootc container lint
```

### Customization entry points

| Path | Purpose |
|---|---|
| `Containerfile` | Choose base image; add extra `RUN` directives |
| `build_files/build.sh` | Install packages via `dnf5`, enable COPRs, configure systemd units |
| `system_files/` | Files overlaid onto `/` inside the image at build time (currently empty) |
| `image-template.env` | Image name, org, tags, BIB image — read by the Justfile |
| `disk_config/disk.toml` | Filesystem layout for QCOW2/RAW disk images |
| `disk_config/iso-*.toml` | Anaconda kickstart config for ISO installer |

### CI/CD

- **`build.yml`** — triggers on push to `main`, daily cron, and PRs. Builds, rechunks with `rpm-ostree`, tags, pushes to `ghcr.io/zeidlos/chaos`, and signs with cosign.
- **`build-disk.yml`** — manual/PR trigger; produces `qcow2` and `anaconda-iso` artifacts via `bootc-image-builder`; optionally uploads to S3.
- Cosign private key must be stored as the `SIGNING_SECRET` GitHub Actions secret.
- Action versions are pinned by Renovate (`renovate.json5`).

### Testing a local build

```bash
# Build as root so bootc can rebase from containers-storage
sudo just build

# List locally built bootc images
sudo podman image list --filter=label=containers.bootc=1

# Switch the running system to the local image
sudo bootc switch --transport containers-storage localhost/chaos:latest
```
