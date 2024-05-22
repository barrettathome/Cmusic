#!/bin/bash

# Ensure the script has executable permissions
chmod +x /root/entrypoint.sh

# Adjust permissions
chmod -R +x /root/Cmusic/static-builds
chmod -R +x /root/Cmusic/build-aux

# Find and make all .sh files executable in build-aux
find /root/Cmusic/build-aux -type f -name '*.sh' -exec chmod +x {} \;

# Find and set execute permissions for config.guess and config.sub files
find /root/Cmusic -type f -name 'config.guess' -exec chmod +x {} \;
find /root/Cmusic -type f -name 'config.sub' -exec chmod +x {} \;

# Switch to bash shell
/bin/bash
