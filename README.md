# Uesio Infrastructure

Work in progress. In conjunction with thecloudmasters/AWS-Eng repo, defines the current state of Uesio cloud infrastructure.

Long term goal is for AWS-Eng repo to be merged into this repo, with all infrastructure state defined with Terraform, rather than CloudFormation templates.

Short term, we need to get all of the CloudFormation templates moved into this repo with all environment-specific properties codified here as well.

## Automated ECS deploys

Whenever the `uesio` repo's `master` branch is built, a Github Action workflow will be run to automatically update the `./aws/dev/ecs/task_definitions/uesio_web.json` file with the latest image, and commit that change to this repo. This repo has a Github Action workflow which will kick off a new Code Deploy deployment (using Blue/Green strategy) of the ECS Task Definition, to get the latest image deployed to Dev.
