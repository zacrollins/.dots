#!/bin/zsh

######################################
# Resize Mode
######################################
# increase window size
resize  <  h : yabai3 resize shrink width 96
resize  <  j : yabai3 resize grow height 64
resize  <  k : yabai3 resize shrink height 64
resize  <  l : yabai3 resize grow width 96

######################################
# Navigation
######################################
resize  <  alt - j : yabai3 focus west
resize  <  alt - k : yabai3 focus south
resize  <  alt - i : yabai3 focus north
resize  <  alt - l : yabai3 focus east

######################################
# Equalize Windows
######################################
resize < ctrl - 0 : yabai -m space --balance


