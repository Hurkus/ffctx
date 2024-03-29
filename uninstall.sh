#!/bin/bash
# Author: Hurkus (2024)


function script(){
	if [[ -f '/usr/local/bin/ffctx.sh' ]]; then
		f='/usr/local/bin/ffctx.sh'
	elif [[ -f '/usr/local/ffctx.sh' ]]; then
		f='/usr/local/ffctx.sh'
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
	
	echo "rm -f '${desktop_path}/ffctx.desktop'"
	sudo rm -f "${desktop_path}/ffctx.desktop"
}


script
contextMenu
echo 'Done.'
