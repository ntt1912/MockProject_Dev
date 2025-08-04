# Set the OpenWrt target platform (can be overridden by environment variable)
SDK_TARGET     ?= bcm27xx-bcm2711-snapshot

# Set the Docker image tag, using the target platform in the name
IMAGE_TAG      ?= openwrt-python-check:$(SDK_TARGET)

# Directory where OpenWrt build output (firmware images) will be stored
BUILD_DIR      ?= bin/targets/bcm27xx/bcm2711

# Declare these as phony targets (they do not represent files)
.PHONY: build copy_to_host flash clean

# Build the Docker image for OpenWrt with the python_checking package
build:
    @echo ">>> Building OpenWrt image with python_checking..."
    docker build -t $(IMAGE_TAG) .   # Build Docker image from current directory, tag it with IMAGE_TAG

# Extract the built OpenWrt image files from the Docker container to the host machine
copy_to_host:
    @echo ">>> Extracting image from Docker..."
    docker create --name temp_openwrt $(IMAGE_TAG)   # Create a temporary container from the built image
    docker cp temp_openwrt:/openwrt/$(BUILD_DIR)/ ./ # Copy the build output directory from the container to the host
    docker rm temp_openwrt                           # Remove the temporary container to clean up

# Flash the extracted OpenWrt image to an SD card for Raspberry Pi
flash:
    @if [ -z "$(DEV)" ]; then \
        echo "Please provide device path with: make flash DEV=/dev/sdX"; \
        exit 1; \
    fi
    # Check if the DEV variable is set (the device path for flashing). If not, print error and exit.

    @IMG_FILE=$$(find ./ -name 'openwrt-bcm27xx-bcm2711-rpi-4-ext4-factory.img.gz' | head -n 1); \
    if [ -z "$$IMG_FILE" ]; then \
        echo "Image file not found in $(BUILD_DIR)"; \
        exit 1; \
    fi; \
    # Search for the compressed OpenWrt image file. If not found, print error and exit.

    echo ">>> Found image: $$IMG_FILE"; \
    echo ">>> Unzipping image..."; \
    gunzip -kf "$$IMG_FILE"; \
    IMG_UNZIPPED=$$(echo "$$IMG_FILE" | sed 's/\.gz$$//'); \
    # Unzip the image file and get the uncompressed filename.

    echo ">>> Flashing to $(DEV)..."; \
    sudo dd if="$$IMG_UNZIPPED" of=$(DEV) bs=4M status=progress conv=fsync; \
    echo ">>>Flash complete. You may now insert the SD card into Raspberry Pi."
    # Use dd to write the image to the SD card device, showing progress and syncing data. Print completion message.

# Clean up build artifacts and Docker images
clean:
    docker rmi $(IMAGE_TAG) || true   # Remove the Docker image (ignore errors if image doesn't exist)
    rm -rf bin/                      # Remove the build output directory and all its contents