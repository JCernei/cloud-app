# Version Control Strategy for Kubernetes Deployments

This document describes the recommended versioning strategy for deploying this application to Kubernetes.

## The Problem with `latest` Tag

Using the `latest` tag in Kubernetes can lead to several issues:

1. **No Visibility**: You can't easily tell which code version is running
2. **No Rollback**: It's difficult to roll back to previous versions
3. **Caching Issues**: Kubernetes won't pull the image again if the tag hasn't changed, even if the content has
4. **Inconsistent Deployments**: Different nodes might have different versions of `latest`

## Recommended Versioning Strategy

### 1. Unique Version per Build

The CI/CD pipeline now generates a unique version for each build using:
- Date and time (YYYYMMDDHHMM)
- Short Git commit hash (7 characters)

Example: `202506091234-a1b2c3d`

### 2. Automatic Deployment

The CI/CD pipeline now:
1. Builds the application
2. Creates a unique version number
3. Builds and pushes the Docker image with both:
   - The specific version tag
   - The `latest` tag
4. **Automatically deploys the new version to your Kubernetes cluster**

### 3. Manual Deployment Scripts (Backup/Testing)

- **deploy-version.sh**: Deploy a specific version (recommended for production)
  ```bash
  ./deployment/deploy-version.sh <dockerhub-username> <version>
  ```

- **deploy-latest.sh**: Force-update with the latest tag (not recommended for production)
  ```bash
  ./deployment/deploy-latest.sh <dockerhub-username>
  ```
  
- **get-latest-version.sh**: Helper to get the latest version from GitHub Actions
  ```bash
  ./deployment/get-latest-version.sh <github-username> <repo-name>
  ```

### 3. CI/CD Integration

The GitHub Actions workflow:
1. Builds the application
2. Creates a unique version number
3. Builds and pushes the Docker image with both:
   - The specific version tag
   - The `latest` tag
4. Saves the version as an artifact that can be downloaded

### 4. Deployment Best Practices

1. **For Production**: Always use specific versions
   ```bash
   ./deployment/deploy-version.sh jcernei 202506091234-a1b2c3d
   ```

2. **For Testing**: You can use the latest tag with forced updates
   ```bash
   ./deployment/deploy-latest.sh jcernei
   ```

3. **For Rollbacks**: Use the rollback script with specific revisions
   ```bash
   ./deployment/rollback-deployment.sh
   ```

4. **For Version History**: Check deployment history
   ```bash
   ./deployment/check-deployment-history.sh
   ```

## Benefits

- **Reproducible Deployments**: Same version = same code
- **Easier Troubleshooting**: Each deployment has a unique identifier
- **Proper Rollback**: Can roll back to any previous version
- **Better Visibility**: Clear which version is running
- **CI/CD Integration**: Version history tracks with Git history
