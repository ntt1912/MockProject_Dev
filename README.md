# OpenWrt Image with Custom Python Checker Package

This project builds a **custom OpenWrt firmware image** for **Raspberry Pi 4 Model B**, containing a simple C-based application that checks and logs the system's Python 3 version.

---

##  Project Structure

```text
MockProject_Dev/
├── Dockerfile                # Build image using official OpenWrt SDK
├── Makefile                  # Orchestrate docker build/test/flash
├── .config                   # OpenWrt build config (pre-enable needed packages)
├── feeds.conf.default        # Feeds list (includes custom src-git)
└── bin/                      # Will contain built firmware image
```

The C application source is maintained in a **separate feed repository**:

```
https://github.com/<your-username>/c-application-feed.git
```

---

##  What This Project Does

-  Build an OpenWrt image via Docker using Ubuntu base image
-  Add a custom feed `python_checking` via `feeds.conf.default`
-  Enable the package in `.config`
-  Build an image that includes:
  - Python3 interpreter
  - A C-based binary named `check_python`
-  Export the final firmware image
-  Flash it to a Raspberry Pi
-  Verify application runs correctly and logs Python version

---

##  Requirements

- OS: Ubuntu 22.04+
- Docker Engine installed
- Git + make

---

##  Usage Instructions

### 1. Clone This Project

```bash
git clone https://github.com/ntt1912/MockProject_Dev.git
cd MockProject_Dev
```

Make sure to also prepare your custom feed (see [Feed Structure](#feed-structure)) and push it to GitHub.

---

### 2. Build Docker Image & OpenWrt Firmware

```bash
make build
```

This builds the OpenWrt image using Docker (based on official OpenWrt SDK). The output will be in:

```bash
bin/targets/bcm27xx/bcm2711/openwrt-*-rpi-4-ext4-factory.img.gz
```

---

### 3. Export Image from Docker

```bash
make copy_to_host
```

Extracts the image from the build container to your host for flashing.

---

### 4. Flash Image to SD Card

```bash
make flash DEVICE=/dev/sdX
```

Replace `/dev/sdX` with your actual SD card device (e.g. `/dev/mmcblk0`). This will:

- Unzip image
- Flash it using `dd`
- Sync and safely unmount

⚠️ WARNING: **Make sure **``** is your SD card!**(This can be seen using **lsblk**)

---

### 5. Boot on Raspberry Pi

- Insert SD card into Raspberry Pi 4.
- Power it on.
- Login via UART or SSH (default user: `root`, no password).
- Run:

```sh
check_python
cat /tmp/python_ver.log
```

Expected output:

```
Detected Python Version: 3.x.x
```

Or if Python is missing:

```
Error: Python 3.x not found
```

---

## Feed Structure

Repo: `https://github.com/ntt1912/c-application-feed.git`

Branch: `feature/python-version-check`\
Tag: `v1.0-python-check`

Structure:

```text
c-application-feed/
├── python_checking/
│   ├── Makefile            # OpenWrt package Makefile
│   └── src/
│       ├── Makefile        # Standard C build Makefile
│       └── check_python.c  # App source
└── Makefile                # Required to declare feed packages
```

Top-level Makefile:

```makefile
# c-application-feed/Makefile
define FeedDescription
  Custom C application to check Python version
endef

define Package/python_checking
SECTION:=utils
CATEGORY:=Utilities
TITLE:=Python Version Checker
endef
```

---

## Build Targets in Makefile

| Target                       | Description                                        |
| ---------------------------- | -------------------------------------------------- |
| `make build`                 | Build OpenWrt image with `python_checking` package |
| `make copy_to_host`          | Export built image from Docker to host             |
| `make flash DEVICE=/dev/sdX` | Flash image to SD card                             |
| `make clean`                 | Remove built image and binaries                    |

---

## Verifying Results

Test with raspberry pi 4

```sh
check_python
cat /tmp/python_ver.log
```

---

## Notes

- The package is built-in to the rootfs. No `.ipk` is produced unless you build it manually via `make package/python_checking/compile`.
- This builds the OpenWrt image using Docker based on `Ubuntu base image`, with toolchain and dependencies installed manually.
- Designed for real Raspberry Pi testing — **not QEMU**.

---

## Contact

Author: [@ntt1912](https://github.com/ntt1912)  


