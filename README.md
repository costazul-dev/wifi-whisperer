# Wi-Fi Whisperer

A poetic surveillance system that listens for the digital ghosts of nearby Wi-Fi networks and uses an AI to find the most interesting among them.

## Core Idea

Wi-Fi Whisperer is a passive listening device built on a Raspberry Pi. It captures Wi-Fi "probe requests"—the little digital cries from phones searching for networks they remember. These remembered network names (SSIDs) are collected, parsed, and fed into a GPT model that ranks them daily based on humor, weirdness, and emotional undertones. It's a joke machine and a quiet eavesdropper on collective memory.

## Repository Structure

```
wifi-whisperer/
├── config/          # Service definitions for automation
├── scripts/         # Helper shell scripts for setup
└── src/             # Python source code for parsing and analysis
```

## How It Works

The project operates as a simple, automated data pipeline:

1. **Capture**: A systemd service runs airodump-ng 24/7 in the background, sniffing for Wi-Fi traffic and saving all captured data to CSV log files.
2. **Parse**: A Python script reads the raw CSV files, isolating and extracting only the unique "probed SSIDs" from client devices.
3. **Analyze (In Development)**: The collected SSIDs are sent to a GPT model to be ranked, categorized, and commented on.
4. **Publish (In Development)**: The AI's analysis is formatted into a daily Markdown digest.

## Setup Instructions

This guide details the one-time setup required to turn a Raspberry Pi into a dedicated Wi-Fi Whisperer device.

### 1. Hardware Prerequisites

- A Raspberry Pi (tested on a Pi 4B with Raspberry Pi OS Bookworm).
- The Pi's internal Wi-Fi (wlan0) for your primary SSH/internet connection.
- A separate USB Wi-Fi adapter that supports monitor mode (this will become wlan1).

### 2. Environment Setup

First, clone the repository, set up a Python virtual environment, and install the necessary dependencies.

```bash
# Clone the repository
git clone https://github.com/your-username/wifi-whisperer.git
cd wifi-whisperer

# Create and activate a virtual environment
python3 -m venv .venv
source .venv/bin/activate

# Install system and Python packages
sudo apt update && sudo apt install -y aircrack-ng
pip install -r requirements.txt
```

### 3. Isolate the Sniffing Adapter (One-Time Setup)

To ensure the capture process doesn't interfere with your Pi's connectivity, you must tell the system's NetworkManager to ignore your USB adapter.

First, find your adapter's MAC address:

```bash
# It will be the 'ether' address for wlan1
ip a
```

Then, add it to the unmanaged-devices list. Replace the MAC address in the command below with the one you just found.

```bash
echo -e "[keyfile]\nunmanaged-devices=mac:cc:64:1a:ee:93:1b" | sudo tee /etc/NetworkManager/conf.d/99-unmanaged-devices.conf
```

### 4. Install and Enable the Capture Service

Finally, copy the service definition into place and enable it to start automatically on boot. This will begin the 24/7 data capture.

```bash
# Copy the service file to the systemd directory
sudo cp config/wifi-monitor.service /etc/systemd/system/

# Reload systemd, then enable and start the service
sudo systemctl daemon-reload
sudo systemctl enable --now wifi-monitor.service
```

Your Pi is now sniffing! Raw capture data will be automatically saved as rotating CSV files in `/var/spool/wifi-monitor/data/`.

## Usage

Once the service is running, your main interaction with the project will be processing the data it collects.

### Check Service Status

You can check if the capture service is running correctly at any time:

```bash
sudo systemctl status wifi-monitor.service
```

### Parse Captured Data

Use the parser.py script to read a raw CSV capture file and print a clean list of the unique probed SSIDs found within it.

```bash
# Activate your virtual environment first if you haven't already
source .venv/bin/activate

# Run the parser on one of the capture files
python3 src/parser.py /var/spool/wifi-monitor/data/capture-01.csv
```

This command will output a simple list, which will serve as the input for the AI analysis in the next phase.

## Roadmap: Next Steps

The data collection foundation is complete. The next phase focuses on bringing the "personality" to the project.

- [ ] **Develop Orchestration Script**: Create a main Python script that automates the daily workflow:
  - Find all new capture files from the last 24 hours.
  - Run the parser on them to collect a single list of unique SSIDs.
  - Apply filters to remove common/uninteresting names (e.g., "XFINITY", "Starbucks WiFi").

- [ ] **Integrate AI Analysis**: Feed the filtered list of SSIDs to the OpenAI API with a carefully crafted prompt to get ranked results and commentary.

- [ ] **Generate Daily Digest**: Format the AI's response into a clean, timestamped Markdown file (e.g., digest-2025-09-01.md).

## License

This project is licensed under the MIT License - see the LICENSE file for details.