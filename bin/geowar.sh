#!/bin/sh
echo -ne '\033c\033]0;Geowar\a'
base_path="$(dirname "$(realpath "$0")")"
"$base_path/geowar.x86_64" "$@"
