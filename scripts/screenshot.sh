#!/bin/sh

set -euo pipefail

file_path="$(xdg-user-dir PICTURES)/screenshot_$(date +"%Y%m%d_%H%M%S").png"
import_params=""

if [ "$#" -gt 0 ] && [ "$1" = "-f" ]; then
    import_params="-window root"
fi

import $import_params "$file_path"
xclip -selection clipboard -target image/png -i < "$file_path"
