#!/bin/bash
# Author: Hurkus (2024)
# Description:
#    Compress and convert videos and images to any format.
#    Result is accepted only if the file is smaller than the original.
#    This script is supposed to be used from the context menu.


# Move source file to /tmp/ after completion: -r
OPT_REPLACE=0
OPT_TYPE=''


function ff(){
	FF_IN="$1"
	local out_ext="$2"
	FF_OUT="${1%.*}.$out_ext"
	
	# Verify files
	if [[ ! -f "$FF_IN" ]]; then
		FF_ERR="File '$FF_IN' does not exist."
		echo "$FF_ERR" >&2
		return 1
	elif [[ -e "$FF_OUT" ]]; then
		FF_ERR="File '$FF_OUT' already exists." >&2
		echo "$FF_ERR" >&2
		return 2
	fi
	
	# Build ffmpeg command
	local cmd='ffmpeg -hide_banner -i "$FF_IN"'
	cmd+=' -map 0:v:0'
	
	local a_channels=`ffprobe "$FF_IN" -v error -select_streams a:0 -show_entries stream=channels -of compact=p=0:nk=1`
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
	
	# Run command on temp file
	local tmp=`mktemp --suffix=".$out_ext"`
	echo "$cmd"
	eval "$cmd" || return 3
	
	# Check if resulting file is actually smaller than original
	FF_IN_SIZE=`stat "$FF_IN" --print='%s'`
	FF_OUT_SIZE=`stat "$tmp" --print='%s'`
	
	if (( $FF_OUT_SIZE >= $FF_IN_SIZE )); then
		FF_ERR="File '$FF_IN' could not be compressed."
		echo "$FF_ERR" >&2
		return 4
	elif [[ -e "$FF_OUT" ]]; then
		FF_ERR="File '$FF_OUT' already exists."
		echo "$FF_ERR" >&2
		return 5
	fi
	
	# Move new file next to original
	mv -- "$tmp" "$FF_OUT"
	touch -r "$FF_IN" -- "$FF_OUT"
	
	# Remove old file (option)
	if (($OPT_REPLACE)); then
		
		# Move original to /tmp/
		if [[ "$tmp" =~ ^/tmp/ ]]; then
			tmp="$(dirname -- "$tmp")/$(basename -- "$FF_IN")"
			
			if [[ -e "$tmp" ]]; then
				tmp=`mktemp --suffix=".${in##*.}"`
			fi
			
			echo "Moved original '$FF_IN' to '$tmp'"
			mv -- "$FF_IN" "$tmp"
			return 0
		fi
		
		# Delete file
		echo "Delete original '$FF_IN'"
		rm -- "$FF_IN"
		return 0
	fi
	
	return 0
}


while (($# > 0)); do
	if [[ "$1" = '-r' ]]; then
		OPT_REPLACE=1
	elif [[ "$1" = '-t' ]]; then
		shift
		OPT_TYPE="$1"
	else
		
		if [[ -z "$OPT_TYPE" ]]; then
			echo 'Unknown output file type.' >&2
			exit 1
		fi
		
		# Run and report error
		ff "$1" "$OPT_TYPE" ; err=$?
		
		# Report stats
		if (( $err == 0)); then
			s="File '$FF_IN' has been converted to '`basename -- "$FF_OUT"`'.\n"
			s+="Reduced $(numfmt --to=iec "$FF_IN_SIZE")B to $(numfmt --to=iec "$FF_OUT_SIZE")B."
			kdialog --title 'File converted.' --passivepopup "$s" 8
		else
			s="$FF_ERR\n"
			(( err >= 4 )) && s+="Source $(numfmt --to=iec "$FF_IN_SIZE")B inflated to $(numfmt --to=iec "$FF_OUT_SIZE")B.\n"
			s+="Operation canceled."
			kdialog --title 'File conversion failed!' --passivepopup "$s" 30
			exit $e
		fi
		
	fi
	shift
done
