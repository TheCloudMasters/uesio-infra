# Uesio Infrastructure

Work in progress. In conjunction with thecloudmasters/AWS-Eng repo, defines the current state of Uesio cloud infrastructure.

Long term goal is for AWS-Eng repo to be merged into this repo, with all infrastructure state defined with Terraform, rather than CloudFormation templates.

Short term, we need to get all of the CloudFormation templates moved into this repo with all environment-specific properties codified here as well.

## Automated ECS deploys

### Latest uesio master auto-deployment to dev cluster

Whenever the `uesio` repo's `master` branch is built, a Github Action workflow will be run to automatically update the `./aws/dev/ecs/task_definitions/uesio_web.json` file with the latest Docker image, and commit that change to this repo. This repo has a Github Action workflow which will kick off a new Code Deploy deployment (using Blue/Green strategy) of the ECS Task Definition, to get the latest image deployed to dev cluster (https://studio.ues-dev.io).

### uat / prod

To update the UAT / Prod environments, one of the files in the corresponding ECS Task Definition must be updated, and this will automatically update the corresponding environment.

To promote what's in dev/uat to uat/prod, run this Github Workflow:

- [Promote DEV/UAT Docker image to UAT/PROD](./actions/workflows/update-environment-image.yml)

** NOTE ** In Prod, this will only _create_ a new Task Definition, but it will NOT automatically re-route traffic. To actually deploy, you will need to login to AWS UAT / Prod, account, go to the corresponding [Code Deploy Deployment](https://us-east-1.console.aws.amazon.com/codesuite/codedeploy/deployments?region=us-east-1) ( will be the latest Deployment in the list) and click "Re-route Traffic". Once you are sure everything looks good, you can click "Terminate Original Task Set" (or just wait for an hour and it will automatically be terminated by CodeDeploy).

These deploy to the following environments:

- uat: https://studio.ues-uat.io
- prod: https://studio.ues.io

### Manual deployments

If for some reason you need to re-initiate a deployment, simply run the "Manual Deploy to AWS" Github Action, and select the desired environment.