# pi-monitor

Turn a **Raspberry Pi 5** (connected to an HDMI display) into a hardware-accelerated, low-latency **wireless/wired second monitor** for a **Linux Hyprland** workstation — without a physical HDMI dummy plug.

`pi-monitor` orchestrates:
1. **Hyprland Headless Output** (`HEADLESS-1`) created/destroyed on demand on the Host.
2. **Sunshine** (`wlr` / `zwlr_screencopy_manager_v1` + hardware encoding such as NVENC/VAAPI) streaming only the virtual display.
3. **Moonlight Qt** on the Raspberry Pi 5 decoding HEVC in hardware (`rpi-hevc-dec` V4L2Request + `drm_prime` zero-copy) in fullscreen.

Over a direct 1 Gbps Ethernet link (`~0.2 ms` RTT), this delivers **1080p @ 60 FPS at 60+ Mbps HEVC** with near-native responsiveness.

---

## Architecture

```text
+----------------------------------+         1 Gbps Ethernet         +----------------------------------+
| Linux Host (Hyprland + Sunshine) | ==============================> | Raspberry Pi 5 (Moonlight Qt)    |
|                                  |   HEVC 1080p60 (60 Mbps UDP)    |                                  |
|  - HEADLESS-1 virtual monitor    |                                 |  - rpi-hevc-dec (V4L2Request)    |
|  - capture = wlr (output_name)   | <============================== |  - drm_prime -> EGL/GLES         |
|  - systemd user service          |     SSH control (pi-monitor)    |  - HDMI-A-1 -> Physical Monitor  |
+----------------------------------+                                 +----------------------------------+
```

---

## Prerequisites

### Host (Linux + Hyprland)
- **Hyprland** (`hyprctl` available)
- **Sunshine** installed and paired with the Raspberry Pi (`systemd --user` service, e.g. `app-dev.lizardbyte.app.Sunshine.service`)
- Passwordless SSH access from the Pi to the Host (e.g. `ssh laptop`)

### Raspberry Pi 5
- **Moonlight Qt** (`moonlight-qt`, e.g. from Cloudsmith Debian `arm64` repo) already paired with the Host
- Active X11/desktop session (`DISPLAY=:0`) for `moonlight-qt` fullscreen output
- Passwordless SSH access from the Host to the Pi (e.g. `ssh pi`) if you want to trigger `pi-monitor` from the Host

---

## Installation

### 1. On the Raspberry Pi 5
```bash
git clone https://github.com/zynordev/pi-monitor.git
cd pi-monitor
./install.sh --pi
```
Edit `~/.config/pi-monitor/config.env` to match your Host IP, SSH alias, and desired resolution/position.

### 2. On the Host (Hyprland)
```bash
git clone https://github.com/zynordev/pi-monitor.git
cd pi-monitor
./install.sh --host
```
Configure Sunshine (`~/.config/sunshine/sunshine.conf`):
```ini
capture = wlr
output_name = HEADLESS-1
origin_web_ui_allowed = lan
min_log_level = info
```
*(See [`config/sunshine.conf.example`](config/sunshine.conf.example).)*

### 3. Firewall (Optional, UFW on Host)
Restrict Sunshine ports to your Raspberry Pi's IP:
```bash
./scripts/setup-ufw.sh 192.168.10.2 eno1
```

---

## Usage

Run from **either** the Host or the Raspberry Pi:

```bash
# Enable second monitor on the right (default)
pi-monitor on

# Enable second monitor on the left
pi-monitor on left

# Disable second monitor (stops Moonlight & removes HEADLESS-1)
pi-monitor off

# Toggle on/off
pi-monitor toggle

# Check status
pi-monitor status

# Override bitrate on the fly (kbps)
PI_MONITOR_BITRATE=80000 pi-monitor on
```

---

## Configuration

All settings live in `~/.config/pi-monitor/config.env` (see [`config/config.env.example`](config/config.env.example)):

| Variable | Default | Description |
|---|---|---|
| `PI_MONITOR_HOST` | `192.168.10.1` | Host IP for Moonlight streaming |
| `PI_MONITOR_SSH_HOST` | `laptop` | SSH alias from Pi to Host |
| `PI_MONITOR_PI_SSH_HOST` | `pi` | SSH alias from Host to Pi |
| `PI_MONITOR_OUTPUT` | `HEADLESS-1` | Hyprland virtual output name |
| `PI_MONITOR_WIDTH` / `HEIGHT` / `FPS` | `1920` / `1080` / `60` | Virtual monitor mode |
| `PI_MONITOR_POS_RIGHT` / `POS_LEFT` | `1920x0` / `-1920x0` | Hyprland monitor position |
| `PI_MONITOR_BITRATE` | `60000` | Moonlight bitrate in kbps |
| `PI_MONITOR_CODEC` | `HEVC` | Video codec (`HEVC`, `H264`, `AV1`) |
| `PI_MONITOR_AUDIO_ON_HOST` | `1` | Keep audio playback on the Host (`--audio-on-host`) |

---

## License

MIT — see [LICENSE](LICENSE).
