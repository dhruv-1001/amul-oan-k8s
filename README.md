# Deployment Guide

This guide describes the deployment flow for the application.

## Prerequisites
- Access to the repository.
- Access to [ArgoCD](https://dev-amulmitra.amul.com/argocd).

## Deployment Flow

1. **Trigger Build**: Create and push a git tag.
   - **Tag Formats**:
     - `dev-v*` : For Development (e.g., `dev-v0.0.1`)
     - `uat-v*` : For UAT (e.g., `uat-v0.0.1`)
     - `v*`     : For Production (e.g., `v0.0.1`)
   - This triggers the `build-and-push` workflow.
   - The Docker image will be built and pushed to the registry.

2. **Update Manifests**:
   - Update the image version in the `amul-services` files.
   - Add/Update environment variables in the ConfigMap if required.
   - [Link to Example PR]()

3. **Sync to Environment**:
   - Go to [ArgoCD](https://dev-amulmitra.amul.com/argocd).
   - Select the application based on the environment (e.g., `uat` or `dev`).
   - Click **Refresh**.
   - **Sync ConfigMap**: If you changed environment variables, sync the ConfigMap first.
   - **Sync Deployment**: Sync the deployment to apply the new image version.
