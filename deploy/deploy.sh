#!/bin/bash
#
# deploy.sh: Installation script for the Wi-Fi Whisperer project.
#
# This script performs the following actions:
# 1. Verifies it is being run with root privileges.
# 2. Installs the 'aircrack-ng' dependency.
# 3. Creates the project directory at /opt/wifi-whisperer.
# 4. Creates the data capture directory at /var/spool/wifi-monitor/data.
# 5. Copies the project's source code and scripts to the new location.
# 6. Sets the necessary executable permissions on the scripts.
# 7. Copies and enables the systemd service and timer for automated capture.

set -e

# --- Configuration ---
# The target directory where project files will be installed.
PROJECT_DIR="/opt/wifi-whisperer"
# The directory where airodump-ng will store raw capture files.
DATA_DIR="/var/spool/wifi-monitor/data"
# The source directory of the repository files (assumes this script is in the root).
SOURCE_DIR="$( dirname "$(readlink -f "${BASH_SOURCE[0]}")" )"


# --- Main Logic ---

# 1. Check for root privileges
if [ "$EUID" -ne 0 ]; then
  echo "Error: This script must be run as root or with sudo."
  exit 1
fi

echo "--- Starting Wi-Fi Whisperer Deployment ---"

# 2. Install Dependencies
echo "[1/5] Updating package list and installing aircrack-ng..."
apt-get update > /dev/null
apt-get install -y aircrack-ng
echo "      Done."

# 3. Create Directories
echo "[2/5] Creating project and data directories..."
mkdir -p "${PROJECT_DIR}/src"
mkdir -p "${PROJECT_DIR}/scripts"
mkdir -p "${DATA_DIR}"
echo "      Project dir: ${PROJECT_DIR}"
echo "      Data dir:    ${DATA_DIR}"
echo "      Done."

# 4. Copy Project Files
echo "[3/5] Copying project files..."
cp "${SOURCE_DIR}/src/parser.py" "${PROJECT_DIR}/src/"
cp "${SOURCE_DIR}/scripts/start-monitor-mode.sh" "${PROJECT_DIR}/scripts/"
cp "${SOURCE_DIR}/LICENSE" "${PROJECT_DIR}/"
cp "${SOURCE_DIR}/README.md" "${PROJECT_DIR}/"
# Make scripts executable
chmod +x "${PROJECT_DIR}/scripts/start-monitor-mode.sh"
echo "      Done."

# 5. Install Systemd Service
echo "[4/5] Installing systemd service and timer..."
cp "${SOURCE_DIR}/config/wifi-monitor.service" /etc/systemd/system/
cp "${SOURCE_DIR}/config/wifi-monitor.timer" /etc/systemd/system/
echo "      Done."

# 6. Enable and Start the Service
echo "[5/5] Reloading systemd and enabling the capture timer..."
systemctl daemon-reload
systemctl enable --now wifi-monitor.timer
echo "      Done."

echo ""
echo "--- Deployment Complete! ---"
echo "The Wi-Fi Whisperer is now active."
echo ""
echo "To check the status of the capture timer, run:"
echo "  sudo systemctl list-timers | grep wifi"
echo ""
echo "Captured data will be saved to: ${DATA_DIR}"
echo "Project files have been installed in: ${PROJECT_DIR}"
