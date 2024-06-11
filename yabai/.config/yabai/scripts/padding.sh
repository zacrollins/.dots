#!/opt/homebrew/bin/bash

windowcount=$(yabai -m query --windows --space | jq -r '[ .[] | select(."is-floating" == false and ."subrole" != "AXDialog") ] | length' )
case "${windowcount}" in
        "1")
                display=$( yabai -m query --displays --space | jq )
                width=$( echo "$display" | jq '.frame.w')
                if [[ "${width}" == "3840.0000" ]]; then
                        yabai -m space --padding abs:20:10:400:400
                        yabai -m space --balance
                else
                        yabai -m space --padding abs:20:10:10:10
                        yabai -m space --balance
                fi
        ;;
        *)
                yabai -m space --padding abs:20:10:10:10
        ;;
esac
