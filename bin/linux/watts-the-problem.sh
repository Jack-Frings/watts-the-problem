#!/bin/sh
printf '\033c\033]0;%s\a' Watt's the Problem-
base_path="$(dirname "$(realpath "$0")")"
"$base_path/watts-the-problem.x86_64" "$@"
