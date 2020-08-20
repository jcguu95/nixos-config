#!/bin/sh
# This script creates my personal file system
# by plugging in (symlinking) files in ".+PLUGS"

################# NOTICE ###############################
# 1. Don't symlink `~/.Xauthority`.
# 2. `zsh` does not run this code properly.
########################################################

# Link non-hidden files in Dropbox

dropbox_dir="$HOME/.+PLUGS/Dropbox/FILE-SYSTEM"; cd "$dropbox_dir"
for i in $(ls); do			## all non-hidden files
	ln -sfT "$dropbox_dir/$i" "$HOME/$i"
done

# Link dotfiles

dot_files_dir="$HOME/.+PLUGS/Dropbox/FILE-SYSTEM/.dot.files"; cd "$dot_files_dir"
for i in $(ls); do			## all non-hidden files
	ln -sfT "$dot_files_dir/$i" "$HOME/$i"
done

for i in $(ls -d .[!.]*); do		## all hidden files
	ln -sfT "$dot_files_dir/$i" "$HOME/$i"
done

# Link files in "Local"

local_dir="$HOME/.+PLUGS/Local";
if [ -d "$local_dir" ]; then
	cd "$local_dir"
	for i in $(ls); do			## all non-hidden files
		ln -sfT "$local_dir/$i" "$HOME/$i"
	done

	for i in $(ls -d .[!.]*); do		## all hidden files
		ln -sfT "$local_dir/$i" "$HOME/$i"
	done
fi

# Link files in "Syncthing"

syncthing_dir="$HOME/.+PLUGS/Syncthing";

if [ -d "$syncthing_dir" ]; then
	cd "$syncthing_dir"
	for i in $(ls); do			## all non-hidden files
		ln -sfT "$syncthing_dir/$i" "$HOME/$i"
	done

	for i in $(ls -d .[!.]*); do		## all hidden files
		ln -sfT "$syncthing_dir/$i" "$HOME/$i"
	done
fi

## Extra

### Link "~/.scripts/bin/" to "~/.local/bin/"

if [ -d "$HOME/.local/bin" ]; then
	echo "Warning: ~/.local/bin exists already.. exit"; exit 1;
elif [ -d "$HOME/.scripts/bin" ]; then
	ln -sf "$HOME/.scripts/bin" "$HOME/.local/"
else 	echo "Warning: ~/.scripts/bin does not exist.. exit"; exit 2;
fi

exit
