# ffconvert

A context menu script for dolphin file explorer for plasma KDE.<br/>
The goal of the setup is to easily reduce file sizes of certain media files by converting them into other formats.<br/>
The resulting compressed file is accepted only if it is considerably smaller than the original.

The script supports video files, such `.mp4` into `.webm`, and image files, such as `.png` into `.jpg`.
JPG files can also be recompressed as they originally might not have been optimally compressed.

To invoke the script, the user right clicks a file and then presses 'Convert to ...'.
The script then spawns a terminal that provides feedback on the conversion process.
The new file is generated within a `/tmp/` folder and is then swapped with the original.
This ensures that the user can still undo the conversion untill `/tmp/` is cleared.

Conversion is done by [ffmpeg](https://github.com/FFmpeg). <br/>
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