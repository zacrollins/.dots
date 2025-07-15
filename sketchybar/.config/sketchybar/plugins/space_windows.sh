#!/usr/bin/env bash

if [ "$SENDER" = "space_windows_change" ]; then
  space="$(echo "$INFO" | jq -r '.space')"
  # apps="$(echo "$INFO" | jq -r '.apps | keys[]')"

  icon_strip=" —"

  sketchybar --set space.$space label="$icon_strip"
fi
