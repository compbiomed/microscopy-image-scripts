#!/bin/bash
# Extract images of slide labels from SVS files using ImageMagick
# Adam Gower

# Parse command-line arguments
eval set -- "$(
  getopt --options=i:o: \
         --longoptions=input-path:,output-path: \
         --name "$0" -- "$@"
)"

while true
do
  case "$1" in
    -i|--input-path)
      output_path="$(realpath "$2")"
      shift 2 ;;
    -o|--output-path)
      output_path="$(realpath "$2")"
      shift 2 ;;
    --)
      shift
      break ;;
    *)
      echo "Internal error"
      exit 1 ;;
  esac
done

# If input path is not specified, the current working directory will be used
[[ "${input_path}" == "" ]] && input_path="$(pwd)"
# If output path is not specified, the current working directory will be used
if [[ "${output_path}" == "" ]]
then
  output_path="$(pwd)"
else
  [[ -d ${output_path} ]] || mkdir --verbose ${output_path}/
fi

# Load and list modules
module load fftw/3.3.4
module load tiff/4.0.6
module load openjpeg/2.1.2
module load imagemagick/7.0.9-8
module list

# Get an array of all SVS filenames (note: this is case-insensitive)
readarray -t svs_filenames < <(find ${input_path} -type f -iname "*.svs")

for svs_filename in "${svs_filenames[@]}"
do
  # Replace final (.svs or .SVS) extension with '.jpg' to get output filename
  output_filename="${output_path}/$(basename "${svs_filename%.*}").jpg"
  echo "Extracting slide label from '${svs_filename}' to: '${output_filename}'"
  # Check the comments of each image in turn for the leading term "label";
  # if it is a slide label, extract to a read-only JPG and exit the loop
  # Note: The first two images (indices 0 and 1) are skipped, as these are
  #       always the baseline and thumbnail images, respectively
  #       (see https://openslide.org/formats/aperio/ for details)
  for (( i=2; ; i++ ))
  do
    if magick convert tif:"${svs_filename}"[$i] -format "%c\n" info: |& \
      grep -q "^label"
    then
      magick convert tif:"${svs_filename}"[$i] -scene 1 "${output_filename}"
      chmod -c a-w "${output_filename}"
      break
    fi
  done
done
