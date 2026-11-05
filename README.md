# Incus examples

Practical, copy-paste [Incus](https://linuxcontainers.org/incus/) configuration for running **system containers** and VMs: profiles, cloud-init, and helper scripts.

VeloxaHost servers are system containers, so everything here also explains how a VeloxaHost server behaves under the hood. You can use it on your own Incus host, a homelab, or any Linux machine.

> Tested with Incus 6.x on Ubuntu 24.04 and Debian 12.

## What's inside

| Path | What it does |
|---|---|
| `profiles/docker-ready.yaml` | Container profile that can run Docker inside (nesting + syscall interception) |
| `profiles/web-small.yaml` | 1 vCPU / 1 GiB limits, root disk size, bridged NIC |
| `profiles/hardened.yaml` | Unprivileged, no nesting, restricted devices, process limits |
| `cloud-init/ubuntu-base.yaml` | Creates a sudo user, installs your SSH key, enables unattended upgrades + UFW |
| `cloud-init/docker-host.yaml` | Installs Docker Engine + Compose plugin from Docker's apt repo |
| `scripts/launch.sh` | Launch a container with profiles + cloud-init in one command |
| `scripts/snapshot-rotate.sh` | Take a snapshot and keep the last N |

## Quick start

```bash
# 1. Install Incus (Ubuntu 24.04)
sudo apt install -y incus
sudo incus admin init --minimal
sudo usermod -aG incus-admin $USER   # log out/in

# 2. Load the profiles
for p in profiles/*.yaml; do
  name=$(basename "$p" .yaml)
  incus profile create "$name" 2>/dev/null || true
  incus profile edit "$name" < "$p"
done

# 3. Launch a Docker-ready Ubuntu container with cloud-init
./scripts/launch.sh web-01 images:ubuntu/24.04/cloud docker-ready,web-small cloud-init/docker-host.yaml
```

Then:

```bash
incus exec web-01 -- cloud-init status --wait
incus exec web-01 -- docker run --rm hello-world
```

## Containers vs VMs

| | System container | Virtual machine |
|---|---|---|
| Start time | ~1–3 s | ~10–30 s |
| Overhead | Near zero (shared kernel) | Full kernel + firmware |
| Docker inside | Yes, with `security.nesting` | Yes |
| Custom kernel / modules | No | Yes |

Most web apps, databases and Docker workloads run fine — and faster — in a system container.

## Don't want to run Incus yourself?

[VeloxaHost](https://veloxahost.com/vps?utm_source=github&utm_medium=referral&utm_campaign=incus-examples) gives you a root system container that starts in seconds, runs Docker, and bills hourly from $4/mo — with snapshots, a browser terminal and a REST API.

## License

MIT
