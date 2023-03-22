# Uesio Infrastructure

Work in progress. In conjunction with thecloudmasters/AWS-Eng repo, defines the current state of Uesio cloud infrastructure.

Long term goal is for AWS-Eng repo to be merged into this repo, with all infrastructure state defined with Terraform, rather than CloudFormation templates.

Short term, we need to get all of the CloudFormation templates moved into this repo with all environment-specific properties codified here as well.

## Automated ECS deploys

### Latest uesio master auto-deployment to dev cluster

Whenever the `uesio` repo's `master` branch is built, a Github Action workflow will be run to automatically update the `./aws/dev/ecs/task_definitions/uesio_web.json` file with the latest Docker image, and commit that change to this repo. This repo has a Github Action workflow which will kick off a new Code Deploy deployment (using Blue/Green strategy) of the ECS Task Definition, to get the latest image deployed to dev cluster (https://studio.ues-dev.io).

### Deploying to Prod

To update the Prod environment (https://studio.ues.io), the corresponding ECS Task Definition must be updated, and this will automatically update the corresponding environment.

To promote what's in dev to prod, run this Github Workflow:

- [Promote DEV Docker image to PROD](../../actions/workflows/update-environment-image.yml)

### Manual deployments

If for some reason you need to re-initiate a deployment, simply run the "Manual Deploy to AWS" Github Action, and select the desired environment.
