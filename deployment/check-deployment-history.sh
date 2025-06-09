#!/bin/bash
# check-deployment-history.sh: Check revision history of the cloud-app deployment
# Usage: ./check-deployment-history.sh <namespace>

set -e

NAMESPACE="${1:-cloud-app-ns}"

echo "Checking deployment history for cloud-app in namespace $NAMESPACE..."
kubectl rollout history deployment/cloud-app -n "$NAMESPACE"

echo -e "\nCurrent status of deployment:"
kubectl get deployment/cloud-app -n "$NAMESPACE"
