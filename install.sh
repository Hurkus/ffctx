#!/bin/bash
# Author: Hurkus (2024)


function script(){
	src='./ffconvert.sh'
	
	if [[ -d '/usr/local/bin/' ]]; then
		dst='/usr/local/bin/ffconvert.sh'
	elif [[ -d '/usr/local/' ]]; then
		dst='/usr/local/ffconvert.sh'
	fi
	
	echo "cp -f '$src' '$dst'"
	sudo cp -f "$src" "$dst" || return 1
}


function contextMenu(){
	src='./ffconvert.desktop'
	
	desktop_path=`qtpaths --locate-dirs GenericDataLocation kio/servicemenus`
	desktop_path="${desktop_path%%:*}"
	
	if [[ ! -d "$desktop_path" ]]; then
		echo "Could not find 'kio/servicemenus'. This is a problem with dolphin." >&2
		return 1
	fi
	
	echo "cp -f ./ffconvert-*.desktop '${desktop_path}/'"
	sudo cp -f ./ffconvert-*.desktop "${desktop_path}/" || return 1
}


script || echo "Failed to install script." >&2
contextMenu || echo "Failed to context menu." >&2
echo 'Done.'
