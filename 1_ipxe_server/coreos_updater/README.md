# CoreOS Updater

Since we are self-hosting the cluster on an internal network, we need to have
the iPXE server get the updated images from the internet periodically.
This simple script will simply go out to the internet and retrieve the latest
bootstrap images of CoreOS.

# Prerequisites

 * A Linux OS using SystemD
 * About ~200MB of disk space
 * Internet access on the machine running this updater

# Usage

This systemd service and script should be installed on the server acting as the
iPXE server.  The service and timer should be enabled and started.

# Installation

| File | Suggested Location |
|------|--------------------|
| coreos_updater.sh | /usr/share/iac/ |
| coreos_updater.service | /lib/systemd/system/ |
| coreos_updater.timer | /lib/systemd/system/

# Configuration

All configuration should be done via the .service file. The parameters are
passed in as environment variables for the script to use.

## Available options

| Variable Name | Options | Description |
|---------------|---------|-------------|
| CHANNEL | alpha, beta, stable | This determines which release channel to look at. |
| VERSION | latest, <XXXX.Y.Z> | You can either specify the word 'latest' or the specific version number to pin the version... although this kind of defeats the purpose. |
| SAVEPATH | /path/to/save/to | This specifies the location to save the downloaded files. |

# Contributors

* Chase Lee - ACM SysAdmin @ UIC
