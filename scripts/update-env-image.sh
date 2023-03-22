#!/bin/bash 

set -e

sourceEnv="${sourceEnv:-dev}"
targetEnv="${targetEnv:-prod}"

sourceImage=$(cat ./aws/$sourceEnv/ecs/task_definitions/uesio_web.json | jq -r '.containerDefinitions[0].image')
targetTaskPath="./aws/$targetEnv/ecs/task_definitions/uesio_web.json"
targetImage=$(cat $targetTaskPath | jq -r '.containerDefinitions[0].image')

# If source and target env are already in sync, bail out.
if [ $sourceImage == $targetImage ]; then
  echo "$targetEnv is already in sync with $sourceEnv, no changes needed."
  exit 0
fi

jq --arg img "$sourceImage" '.containerDefinitions[0].image = $img' $targetTaskPath > tmp.json
mv tmp.json $targetTaskPath

git config --global user.name "$gitUsername"

git add $targetTaskPath
git commit -m "release: Promote $sourceEnv image to $targetEnv"
git push