# Docker Image configurations

This folder exists to enable external systems, such as Github Actions, to initiate remote updates of which Docker Images are being used for a given container deployment.

In AWS, we use Terraform to define the ECS cluster, services, and task definitions, but the actual Docker Image run in a given container needs to change frequently, so we need a way to externalize this configuration such that external systems can update it.

Each text file in the various app-specific folders will correspond to the fully-qualified Docker image which should be run in a specific environment.
