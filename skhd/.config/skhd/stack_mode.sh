#!/usr/bin/env sh

##########################
# Stack Mode
##########################
# enter stack
stack < h : yabai3 stack-enter west; skhd -k escape
stack < j : yabai3 stack-enter south; skhd -k escape
stack < k : yabai3 stack-enter north; skhd -k escape
stack < l : yabai3 stack-enter east; skhd -k escape

# leave stack
stack < shift - h : yabai3 stack-leave west
stack < shift - j : yabai3 stack-leave south
stack < shift - k : yabai3 stack-leave north
stack < shift - l : yabai3 stack-leave east

# insert window into stack
stack < s      : yabai -m window --insert stack; skhd -k escape

stack < return : yabai -m window --insert stack \
    && open -na "Alacritty"; skhd -k escape
