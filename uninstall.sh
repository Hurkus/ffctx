#!/bin/bash
# Author: Hurkus (2024)


function script(){
	if [[ -d '/usr/local/bin/' ]]; then
		f='/usr/local/bin/ffconvert.sh'
	elif [[ -d '/usr/local/' ]]; then
		f='/usr/local/ffconvert.sh'
	else
		return 1
	fi
	
	echo "rm -f '$f'"
	sudo rm -f "$f"
}


function contextMenu(){
	desktop_path=`qtpaths --locate-dirs GenericDataLocation kio/servicemenus`
	desktop_path="${desktop_path%%:*}"
	
	if [[ ! -d "$desktop_path" ]]; then
		return 1
	fi
	
	echo "rm -f '${desktop_path}/ffconvert.desktop'"
	sudo rm -f "${desktop_path}/ffconvert.desktop"
}


script
contextMenu
echo 'Done.'
