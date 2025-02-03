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
	sudo cp -f "$src" "$dst"
}


function contextMenu(){
	src='./ffconvert.desktop'
	
	desktop_path=`qtpaths --locate-dirs GenericDataLocation kio/servicemenus`
	desktop_path="${desktop_path%%:*}"
	
	if [[ ! -d "$desktop_path" ]]; then
		echo "Could not find 'kio/servicemenus'. This is a problem with dolphin." >&2
		exit 1
	fi
	
	echo "cp -f '$src' '${desktop_path}/ffconvert.desktop'"
	sudo cp -f "$src" "${desktop_path}/ffconvert.desktop"
}


script
contextMenu
echo 'Done.'
