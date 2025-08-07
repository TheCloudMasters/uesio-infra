#!/bin/bash 

set -e

sourceEnv="${sourceEnv:-dev}"
targetEnv="${targetEnv:-prod}"

sourceAppImage=$(cat ./aws/$sourceEnv/ecs/task_definitions/uesio_web.json | jq -r '.containerDefinitions[0].image')
sourceWorkerImage=$(cat ./aws/$sourceEnv/ecs/task_definitions/uesio_worker.json | jq -r '.containerDefinitions[0].image')
targetAppTaskPath="./aws/$targetEnv/ecs/task_definitions/uesio_web.json"
targetWorkerTaskPath="./aws/$targetEnv/ecs/task_definitions/uesio_worker.json"
targetAppImage=$(cat $targetAppTaskPath | jq -r '.containerDefinitions[0].image')
targetWorkerImage=$(cat $targetWorkerTaskPath | jq -r '.containerDefinitions[0].image')

# If source and target env are already in sync, bail out.
if [ $sourceAppImage == $targetAppImage ] && [ $sourceWorkerImage == $targetWorkerImage ]; then
  echo "$targetEnv is already in sync with $sourceEnv, no changes needed."
  exit 0
fi

jq --arg img "$sourceAppImage" '.containerDefinitions[0].image = $img' $targetAppTaskPath > tmpApp.json
jq --arg img "$sourceWorkerImage" '.containerDefinitions[0].image = $img' $targetWorkerTaskPath > tmpWorker.json
mv tmpApp.json $targetAppTaskPath
mv tmpWorker.json $targetWorkerTaskPath

git config --global user.name "$gitUsername"
git config --global user.email "$gitEmail"

git add $targetAppTaskPath $targetWorkerTaskPath
git commit -m "release: Promote $sourceEnv image to $targetEnv"
git push

# Get the SHA of the commit
commitSHA=$(git rev-parse HEAD)
echo "COMMIT_SHA=${commitSHA}" >> "$GITHUB_OUTPUT"