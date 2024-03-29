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
	desktop_path=`qtpaths --locate-dirs GenericDataLocation kio/servicemenus`
	desktop_path="${desktop_path%%:*}"
	
	if [[ ! -d "$desktop_path" ]]; then
		echo "Could not find 'kio/servicemenus'. This is a problem with dolphin." >&2
		exit 1
	fi
	
	desktop_tmp=`mktemp --suffix='.desktop'`
cat >"$desktop_tmp" <<'EOF'
[Desktop Entry]
Type=Service
MimeType=video/mp4
Actions=convertMediaFile

[Desktop Action convertMediaFile]
Name=Convert To WEBM
Exec=konsole -e "bash -c 'type ffconvert.sh 1>/dev/null 2>/dev/null && ffconvert.sh %U'"
EOF
	
	chmod +r "$desktop_tmp"
	echo "cp -f '$desktop_tmp' '${desktop_path}/ffconvert.desktop'"
	sudo cp -f "$desktop_tmp" "${desktop_path}/ffconvert.desktop"
}


script
contextMenu
echo 'Done.'
