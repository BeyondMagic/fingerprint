#!/usr/bin/env python3
import sys
import os
import fcntl

# Equivalent of USBDEVFS_RESET ioctl in Linux kernel
USBDEVFS_RESET = ord('U') << (4 * 2) | 20  # or 21780 / 0x5514

if len(sys.argv) < 3:
    print(f"Usage: {sys.argv[0]} <bus> <device>")
    print("Example: sudo python3 reset.py 002 003")
    sys.exit(1)

bus = sys.argv[1].zfill(3)
device = sys.argv[2].zfill(3)
dev_path = f"/dev/bus/usb/{bus}/{device}"

try:
    fd = os.open(dev_path, os.O_WRONLY)
    try:
        fcntl.ioctl(fd, USBDEVFS_RESET, 0)
        print(f"Successfully reset USB device at {dev_path}")
    finally:
        os.close(fd)
except Exception as e:
    print(f"Failed to reset device {dev_path}: {e}", file=sys.stderr)
    sys.exit(1)

