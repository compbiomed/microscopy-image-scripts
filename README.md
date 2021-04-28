# Scripts for working with microscopy image files (SVS, etc.)

These scripts are intended for use with a system using [Environment Modules](http://modules.sourceforge.net/).

### `extract_SVS_slide_labels.sh`

This script extracts the slide label images from all SVS files in an input directory and writes them to JPEG files (with the same filename prefix but the .jpg extension) in an output directory.

Usage:
`  bash extract_SVS_slide_labels.sh [options]`
Options:
```
  -i, --input-path     Path where image files are located
                       (Default: current working directory)
  -o, --output-path    Path where output will be written (will be created if it does not exist)
                       (Default: current working directory)
```
