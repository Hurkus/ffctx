# ffconvert

A context menu script for dolphin file explorer for plasma KDE. <br/>
The script converts video files such as `.mp4` into `.webm` in order to reduce file size.

To invoke the script, the user right clicks a file and then presses 'Convert to WEBM'. <br/>
The script spawns a terminal that provides feedback on the conversion process.
The file conversion is done by [ffmpeg](https://github.com/FFmpeg). <br/>
Currently the script is hardcoded to open [konsole](https://github.com/KDE/konsole) as the terminal emulator.

<br/>

![Usage example.](/sample/preview.png "Usage example")


## Installation

Clone repository and
```sh
./install.sh
```

## Uninstall

```sh
./uninstall.sh
```