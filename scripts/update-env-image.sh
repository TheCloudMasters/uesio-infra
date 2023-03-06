#!/bin/bash 

set -e

targetEnv="${targetEnv:-uat}"

devImage=$(cat ./aws/dev/ecs/task_definitions/uesio_web.json | jq -r '.containerDefinitions[0].image')
targetTaskPath="./aws/$targetEnv/ecs/task_definitions/uesio_web.json"
targetImage=$(cat $targetTaskPath | jq -r '.containerDefinitions[0].image')

# If dev and target env are already in sync, bail out.
if [ $devImage == $targetImage ]; then
  echo "$targetEnv is already in sync with dev, no changes needed."
  exit 0
fi

jq --arg img "$devImage" '.containerDefinitions[0].image = $img' $targetTaskPath > tmp.json
mv tmp.json $targetTaskPath

git config user.name github-actions
git config user.email github-actions@github.com
git add $targetTaskPath
git commit -m "release: Update ${{ targetEnv }} image to $devImage"
git push