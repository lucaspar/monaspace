#!/bin/bash
set -e

# if on linux, install fonts to ~/.local/share/fonts/Monaspace
if [ "$(uname)" == "Linux" ]; then
    FONTS_LOCATION="${XDG_DATA_HOME:-$HOME/.local/share}"/fonts
# on mac, install fonts to ~/Library/Fonts/Monaspace
elif [ "$(uname)" == "Darwin" ]; then
    FONTS_LOCATION="${HOME}/Library/Fonts"
else
    echo "Could not determine operating system. Please install fonts manually."
    exit 1
fi
MONASPACE_LOCATON="${FONTS_LOCATION}/Monaspace"
SCRIPT_LOCATION="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_LOCATION="$(dirname "${SCRIPT_LOCATION}")"

if [ ! -d "${FONTS_LOCATION}" ]; then
    echo "No fonts directory found. Make sure '${FONTS_LOCATION}' exists."
    exit 2
fi

if [ ! -d "${REPO_LOCATION}" ]; then
    echo "Repository could not be found at '${REPO_LOCATION}'."
    exit 2
fi

mkdir -p "${MONASPACE_LOCATON}"

# Safety check: if MONASPACE_LOCATON is not set, empty, or points to root or home, exit
if [ -z "${MONASPACE_LOCATON}" ] || [ "${MONASPACE_LOCATON}" == "/" ] || [ "${MONASPACE_LOCATON}" == "${HOME}" ]; then
    echo "Invalid install location: '${MONASPACE_LOCATON}'."
    exit 3
fi

# remove all fonts from ~/.local/share/fonts/Monaspace/ that start with "Monaspace"
find "${MONASPACE_LOCATON}" -type f \( -name "Monaspace*.ttf" -o -name "Monaspace*.otf" \) -delete

# copy all fonts from ./otf to ~/.local/share/fonts
rsync -a "${REPO_LOCATION}/fonts/otf/"* "${MONASPACE_LOCATON}"

# copy variable fonts from ./variable to ~/.local/share/fonts
rsync -a "${REPO_LOCATION}/fonts/variable/" "${MONASPACE_LOCATON}"

# on linux, build font information caches
if [ "$(uname)" == "Linux" ]; then
    fc-cache -f
fi

NUM_FONTS=$(find "${MONASPACE_LOCATON}" \( -name "Monaspace*.ttf" -o -name "Monaspace*.otf" \) | wc -l)
echo "${NUM_FONTS} fonts installed to '${MONASPACE_LOCATON}'."
