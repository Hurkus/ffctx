#!/bin/bash
# Author: Hurkus (2024)
# Description: Convert videos to .webm format.
#              This script is meant to be used within a context menu.

# Install:
#   ln -f -s `realpath ./ffconvert.sh` /usr/local/bin
#   PASTE TO `qtpaths --locate-dirs GenericDataLocation kio/servicemenus`/ffconvert.desktop
#     [Desktop Entry]
#     Type=Service
#     MimeType=video/mp4
#     Actions=convertMediaFile
#     
#     [Desktop Action convertMediaFile]
#     Name=Convert To WEBM
#     Exec=konsole -e "bash -c 'type ffconvert.sh 1>/dev/null 2>/dev/null && ffconvert.sh %U'"
# 


function f(){
	in="$1"
	out="${1%.*}.webm"
	
	if [[ ! -f "$in" ]]; then
		echo "File '$in' does not exist." >&2
		return 1
	elif [[ -e "$out" ]]; then
		echo "File '$out' already exists." >&2
		return 1
	fi
	
	cmd='ffmpeg -hide_banner -i "$in"'
	cmd+=' -map 0:v:0'
	
	a_channels=`ffprobe "$in" -v error -select_streams a:0 -show_entries stream=channels -of compact=p=0:nk=1`
	if [[ -n "$a_channels" ]]; then
		cmd+=' -map 0:a:0'
		
		if [[ "$a_channels" != 1 && "$a_channels" != 2 ]]; then
			cmd+=' -ac 2'
		else
			cmd+=" -ac $a_channels"
		fi
		
	fi
	
	cmd+=' -map_chapters -1'
	cmd+=' -map_metadata -1'
	cmd+=' "$tmp" -y'
	
	tmp=`mktemp --suffix='.webm'`
	
	echo "$cmd"
	eval "$cmd"
	
	in_size=`stat "$in" --print='%s'`
	out_size=`stat "$tmp" --print='%s'`
	
	if (( $out_size <= $in_size )); then
		if [[ -e "$out" ]]; then
			echo "File '$out' already exists." >&2
			return 1
		else
			mv "$tmp" "$out"
			touch -r "$in" "$out"
		fi
	else
		echo "File '$in' could not be compressed." >&2
		return 2
	fi
	
	return 0
}


while (($# > 0)); do
	f "$1" || {
		read -p 'Press any key to exit ...'
		exit 1
	}
	shift
done

