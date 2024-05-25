#!/bin/bash
# Author: Hurkus (2024)
# Description: Convert videos to .webm format.
#              This script is used from a context menu.


# Move source file to /tmp/ after completion: -r
replace=0


function ff(){
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
	eval "$cmd" || return 3
	
	in_size=`stat "$in" --print='%s'`
	out_size=`stat "$tmp" --print='%s'`
	
	if (( $out_size >= $in_size )); then
		echo "File '$in' could not be compressed." >&2
		return 2
	elif [[ -e "$out" ]]; then
		echo "File '$out' already exists." >&2
		return 1
	fi
	
	Move from tmp to final destination
	mv -- "$tmp" "$out"
	touch -r "$in" -- "$out"
	
	# Remove file
	if (($replace)); then
		
		# Move to /tmp/
		if [[ "$tmp" =~ ^/tmp/ ]]; then
			tmp="$(dirname -- "$tmp")/$(basename -- "$in")"
			
			if [[ -e "$tmp" ]]; then
				tmp=`mktemp --suffix=".${in##*.}"`
			fi
			
			echo "Moved original '$in' to '$tmp'"
			mv -- "$in" "$tmp"
			return 0
		fi
		
		# Delete file
		echo "Delete original '$in'"
		rm -- "$in"
		return 0
	fi
	
	return 0
}


while (($# > 0)); do
	if [[ "$1" = '-r' ]]; then
		replace=1
	else
		ff "$1" || {
			read -s -n 1 -p 'Press any key to exit ...'
			echo ""
			exit 1
		}
	fi
	shift
done
