#!/bin/sh

quickgitarray=("$HOME/+NOTES/"
	       #"$HOME/.emacs.d/"
              )

for dir in "${quickgitarray[@]}"; do   # The quotes are necessary here
	notify-send "Auto quick gitting for directory: $dir"
	cd "$dir"
	git add .
	git commit -m "AUTO COMMIT BY QUICKGIT.SH"
done
