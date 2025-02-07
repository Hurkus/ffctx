#!/bin/bash
# Author: Hurkus (2024)
# Description:
#    Compress and convert videos and images to any format.
#    Result is accepted only if the file is smaller than the original.
#    This script is supposed to be used from the context menu.


# Move source file to /tmp/ after completion: -r
OPT_REPLACE=0
OPT_FORCE=0
OPT_TYPE=''
TRESHOLD_PROMIL=10


function ff(){
	FF_IN="$1"
	local out_ext="$2"
	FF_OUT="${1%.*}.$out_ext"
	local recompress=0
	
	# Verify files
	if [[ ! -f "$FF_IN" ]]; then
		FF_ERR="File '$FF_IN' does not exist."
		echo "$FF_ERR" >&2
		return 1
	elif [[ -e "$FF_OUT" ]]; then
		if [[ $OPT_FORCE != 0 ]]; then
			[[ "$FF_IN" == "$FF_OUT" ]] && recompress=1
		else
			FF_ERR="File '$FF_OUT' already exists." >&2
			echo "$FF_ERR" >&2
			return 2
		fi
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
	local tmp=`mktemp --suffix=".new.$out_ext"`
	echo "$cmd"
	eval "$cmd" || return 3
	
	# Check if resulting file is actually smaller than original
	FF_IN_SIZE=`stat "$FF_IN" --print='%s'`
	FF_OUT_SIZE=`stat "$tmp" --print='%s'`
	local treshold=$(( $FF_IN_SIZE * $TRESHOLD_PROMIL / 1000 ))
	
	if (( $FF_OUT_SIZE >= $FF_IN_SIZE - $treshold )); then
		rm "$tmp"
		FF_ERR="File '$FF_IN' could not be compressed."
		echo "$FF_ERR" >&2
		return 4
	elif [[ -e "$FF_OUT" && $OPT_FORCE == 0 ]]; then
		rm "$tmp"
		FF_ERR="File '$FF_OUT' already exists."
		echo "$FF_ERR" >&2
		return 5
	else
		echo "Reduced $FF_IN_SIZE B to $FF_OUT_SIZE B"
	fi
	
	# Ensure identical timestamp
	touch -r "$FF_IN" -- "$tmp"
	
	# Remove old file (option)
	if (( $OPT_REPLACE == 1 || $recompress == 1 )); then
		# Try move original to /tmp/ or delete
		if [[ "$tmp" =~ ^/tmp/ ]]; then
			local tmp_2="$(dirname -- "$tmp")/$(basename -- "$FF_IN")"
			
			echo $tmp_2
			if [[ -e "$tmp_2" ]]; then
				tmp_2=`mktemp --suffix=".${FF_IN##*.}"`
			fi
			
			echo "Move original '$FF_IN' to '$tmp_2'"
			mv -- "$FF_IN" "$tmp_2"
		else
			echo "Delete original '$FF_IN'"
			rm -- "$FF_IN"
		fi
	fi
	
	echo "Move '$tmp' '$FF_OUT'."
	mv -- "$tmp" "$FF_OUT"
	return 0
}


_err=0

while (($# > 0)); do
	if [[ "$1" = '-k' ]]; then		# Open konsole for feedback
		shift
		konsole -e "$0" "$@" & disown
		exit
	elif [[ "$1" = '-r' ]]; then	# Delete original file
		OPT_REPLACE=1
	elif [[ "$1" = '-f' ]]; then	# Force replace existing file
		OPT_FORCE=1
	elif [[ "$1" = '-t' ]]; then	# Output type
		shift
		OPT_TYPE="$1"
	else							# Process file
		
		if [[ -z "$OPT_TYPE" ]]; then
			echo 'Unknown output file type.' >&2
			exit 1
		fi
		
		# Run and report error
		ff "$1" "$OPT_TYPE" ; err=$?
		
		# Report stats
		if (( $err == 0 )); then
			s="File '$FF_IN' has been converted to '`basename -- "$FF_OUT"`'.\n"
			s+="Reduced $(numfmt --to=iec "$FF_IN_SIZE")B to $(numfmt --to=iec "$FF_OUT_SIZE")B."
			kdialog --title 'File converted.' --passivepopup "$s" 8
		else
			s="$FF_ERR\n"
			(( $err == 4 )) && s+="Source $(numfmt --to=iec "$FF_IN_SIZE")B inflated to $(numfmt --to=iec "$FF_OUT_SIZE")B.\n"
			s+="Operation canceled."
			kdialog --title 'File conversion failed!' --passivepopup "$s" 30
			_err=$err
		fi
		
	fi
	shift
done

exit $_err
