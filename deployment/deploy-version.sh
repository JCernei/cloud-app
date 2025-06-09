#!/bin/bash
# deploy-version.sh: Deploys a specific version of the application
# Usage: ./deploy-version.sh <dockerhub-username> <version>
# Example: ./deploy-version.sh jcernei 202506091234-a1b2c3d

set -e

if [ -z "$1" ] || [ -z "$2" ]; then
  echo "Usage: $0 <dockerhub-username> <version>"
  echo "Example: $0 jcernei 202506091234-a1b2c3d"
  exit 1
fi

DOCKERHUB_USERNAME="$1"
VERSION="$2"
NAMESPACE="cloud-app-ns"

echo "Deploying version $VERSION from $DOCKERHUB_USERNAME/cloud-app..."

# Update the deployment with the specific version
kubectl set image deployment/cloud-app -n $NAMESPACE cloud-app=$DOCKERHUB_USERNAME/cloud-app:$VERSION

# Make sure to annotate for history tracking
kubectl annotate deployment/cloud-app -n $NAMESPACE kubernetes.io/change-cause="Deployed version $VERSION via deploy-version.sh" --overwrite

# Wait for rollout to complete
kubectl rollout status deployment/cloud-app -n $NAMESPACE

echo "Deployment of version $VERSION complete!"
echo "Check pod status: kubectl get pods -n $NAMESPACE"
echo "Check deployment history: ./check-deployment-history.sh $NAMESPACE"
