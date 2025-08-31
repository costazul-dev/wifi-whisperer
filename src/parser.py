import csv
import sys
from typing import Set

def parse_probes(file_path: str) -> Set[str]:
    """
    Parses an airodump-ng CSV file to extract unique, probed SSIDs.

    Args:
        file_path: The path to the CSV capture file.

    Returns:
        A set of unique SSID strings found in the file.
    """
    probed_ssids = set()
    
    with open(file_path, 'r', encoding='utf-8', errors='ignore') as f:
        # Skip to the client data section of the file
        for line in f:
            if line.strip().startswith('Station MAC'):
                break
        
        # We are now at the beginning of the client data
        # The first column is 'Station MAC', the last is ' Probed ESSIDs'
        # Note the leading space in the Probed ESSIDs header
        reader = csv.DictReader(f)
        for row in reader:
            # The key might have leading/trailing whitespace
            ssid_list = row.get(' Probed ESSIDs', '').strip()
            if ssid_list:
                # A device can probe for multiple SSIDs, comma-separated
                for ssid in ssid_list.split(','):
                    ssid = ssid.strip()
                    if ssid:
                        probed_ssids.add(ssid)

    return probed_ssids

if __name__ == "__main__":
    if len(sys.argv) < 2:
        print(f"Usage: python {sys.argv[0]} <path_to_capture_file.csv>")
        sys.exit(1)

    capture_file = sys.argv[1]
    unique_ssids = parse_probes(capture_file)
    
    if unique_ssids:
        print("Found Unique Probed SSIDs:")
        for ssid in sorted(list(unique_ssids)):
            print(f"- {ssid}")
    else:
        print("No probed SSIDs found in the capture file.")