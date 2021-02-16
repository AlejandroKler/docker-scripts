# Author: Alejandro Kler (alejandrokler@gmail.com)
# Date: 2020-04-28
# License: MIT License
# GitHub repository: https://github.com/AlejandroKler/docker-scripts
#
# Build a docker image from a maven java project.
# First time configure image_name and project_name.
# Use -t to indicate image tag (mandatory)
# Use -p to indicate if should push image to registry (default false)
# Example usage: bash create_version.sh -t 2.1.5 -p true

# Configure this
image_name="repo.example.com/username/my-cool-project"
project_name="my-cool-project"
#

has_tag=false
SHOULD_PUSH_IMAGE=false

while getopts t:p: option; do
  case "${option}" in
    t) has_tag=true; TAG=${OPTARG};;
    p) SHOULD_PUSH_IMAGE=${OPTARG};;
    :) echo "Missing argument for option -$OPTARG"; exit 1;;
    \?) echo "Unknown option -$OPTARG"; exit 1;;
  esac
done

set -e # Exit on error

if ! ${has_tag}; then
    echo "Empty tag (use -t option)" && exit 1;
fi

full_image_name="${image_name}:${TAG}"

echo "Tag selected ${full_image_name}"
echo "Building jar using java version: "
echo | javac -version

mvn package -Dversion="${TAG}"

echo "Building docker image ${full_image_name}"

docker build -t "${full_image_name}" --build-arg JAR_FILE="target/${project_name}-${TAG}".jar .

if ${SHOULD_PUSH_IMAGE}; then
  docker push "${full_image_name}"
  echo "Image pushed: ${full_image_name}"
else
  echo "Image not pushed"
fi