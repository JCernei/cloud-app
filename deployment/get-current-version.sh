#!/bin/bash
# get-current-version.sh: Gets the currently deployed version from Kubernetes
# Usage: ./get-current-version.sh

set -e

NAMESPACE="cloud-app-ns"

echo "Current deployment details:"
kubectl describe deployment/cloud-app -n $NAMESPACE | grep -i Image:

echo ""
echo "Deployment change history:"
kubectl rollout history deployment/cloud-app -n $NAMESPACE

echo ""
echo "For more details on a specific revision:"
echo "kubectl rollout history deployment/cloud-app -n $NAMESPACE --revision=<revision-number>"
