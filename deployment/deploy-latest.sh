#!/bin/bash
# deploy-latest.sh: Deploys the latest image from Docker Hub to your local Kubernetes cluster
# Usage: ./deploy-latest.sh <dockerhub-username>

set -e

if [ -z "$1" ]; then
  echo "Usage: $0 <dockerhub-username>"
  exit 1
fi

DOCKERHUB_USERNAME="$1"
MANIFEST="deployment/k3s-deployment/cloud-app-deployment.yaml"

# Substitute Docker Hub username in manifest and apply
export DOCKERHUB_USERNAME="$DOCKERHUB_USERNAME"
kubectl apply -f "$MANIFEST"

echo "Deployment applied with image: $DOCKERHUB_USERNAME/cloud-app:latest"
