#!/bin/bash
# deploy-latest.sh: Deploys the latest image from Docker Hub to your local Kubernetes cluster
# Usage: ./deploy-latest.sh <dockerhub-username>
# 
# NOTE: Using 'latest' tag is not recommended for production!
# Consider using './deploy-version.sh' with specific versions instead.

set -e

if [ -z "$1" ]; then
  echo "Usage: $0 <dockerhub-username>"
  exit 1
fi

DOCKERHUB_USERNAME="$1"
NAMESPACE="cloud-app-ns"

echo "CAUTION: Deploying 'latest' tag. This may not pick up recent changes!"
echo "For production deployments, use './deploy-version.sh' with specific versions."
echo ""

# Explicitly pull the latest image to force an update
echo "Forcing Kubernetes to update with latest image..."
kubectl set image deployment/cloud-app -n $NAMESPACE cloud-app=$DOCKERHUB_USERNAME/cloud-app:latest

# Use rollout restart to force a new deployment that will pick up the latest image
echo "Restarting deployment to ensure latest image is used..."
kubectl rollout restart deployment/cloud-app -n $NAMESPACE

# Annotate for history tracking
kubectl annotate deployment/cloud-app -n $NAMESPACE kubernetes.io/change-cause="Deployed latest via deploy-latest.sh" --overwrite

# Wait for rollout to complete
kubectl rollout status deployment/cloud-app -n $NAMESPACE

echo "Deployment with latest tag complete (but we strongly recommend versioned deployments)!"
echo "Check pod status: kubectl get pods -n $NAMESPACE"
