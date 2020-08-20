#!/bin/sh

DEVICE='HUION Huion Tablet Pad pad'

xsetwacom --set "$DEVICE" Button 1 "key +ctrl +z -z -ctrl"
xsetwacom --set "$DEVICE" Button 2 "key e"
xsetwacom --set "$DEVICE" Button 3 "key b"
xsetwacom --set "$DEVICE" Button 8 "key +"
xsetwacom --set "$DEVICE" Button 9 "key -"
xsetwacom --set "$DEVICE" Button 10 "key ]"
xsetwacom --set "$DEVICE" Button 11 "key ["
xsetwacom --set "$DEVICE" Button 12 "key p"

xsetwacom --set "$DEVICE" Pressure-Curve "5 10 90 95"

exit
