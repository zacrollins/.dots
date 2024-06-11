#!/usr/bin/env bash

# setup spaces

SPACES=8
for _ in $(yabai -m query --spaces | jq ".[].index | select(. > $SPACES)"); do
  yabai -m space --destroy "$((SPACES+1))"
done

function setup_space {
  local idx="$1"
  local name="$2"
  local space=
  echo "setup space $idx : $name"

  space=$(yabai -m query --spaces --space "$idx")
  if [ -z "$space" ]; then
    yabai -m space --create
  fi

  yabai -m space "$idx" --label "$name"
}

setup_space 1 web
setup_space 2 term
setup_space 3 code
setup_space 4 code2
setup_space 5 code3
setup_space 6 
setup_space 7 
setup_space 8 comm
