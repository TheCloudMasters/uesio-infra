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

- [Promote DEV Docker image to PROD](.github/workflows/update-environment-image.yml)

### Manual deployments

If for some reason you need to re-initiate a deployment, simply run the "Manual Deploy to AWS" Github Action, and select the desired environment.

### Running a platform command ad-hoc

The [Run Platform Command](.github/workflows/run-platform-command.yml) supports running a platform command (e.g., migrate, seed) in a one-off manner. This can be helpful for setting up a new environment and/or running database migrations.  To use:

1. Choose a target environment
2. Choose a command to execute
3. Provide any additional command arguments (e.g., to migrate down 1 version specify `down 1`)

### Deployment duration

There is currently an issue/limitation with [amazon-ecs-deploy-task-definition](https://github.com/aws-actions/amazon-ecs-deploy-task-definition) related to how "stability" is determined. The approach used is to start checking
for stability after an initial delay which is currently hardcoded to 15 seconds. After that check, an exponential backoff is applied with a max of 120 seconds. The challenge is that health will fail immediately as it takes ECS
a bit to shutdown current container and provision/start new container. This results in essentially almost always reaching the 120 second delay causing longer than necessary deployment times. The healthchecks for both worker and 
app are successfully quickly after the container starts but the deploy task prolongs the process. If/When https://github.com/aws-actions/amazon-ecs-deploy-task-definition/issues/102#issuecomment-1266750550 is addressed, github
workflow run times times should be reduced assuming any necessary configuration changes are made to the steps of the job. See https://github.com/aws-actions/amazon-ecs-deploy-task-definition/issues/102#issuecomment-2145854763 
for a good explanation of how the task behaves as of v2.3.3 at least.

### Healthcheck troubleshooting

Healthcheck operations are not visible in the logs. In order to troubleshoot healtchecks themselves, see the information at https://docs.aws.amazon.com/AmazonECS/latest/developerguide/view-container-health.html.

For example, changing the worker command to the following would output the healthcheck to the log:

```diff
- test -f /tmp/worker-healthcheck.json && test $(( $(date +%s) - $(stat -c %Y /tmp/worker-healthcheck.json) )) -lt 60
+ (echo 'Running healthcheck' && test -f /tmp/worker-healthcheck.json && test $(( $(date +%s) - $(stat -c %Y /tmp/worker-healthcheck.json) )) -lt 60) >> /proc/1/fd/1 2>&1
```
