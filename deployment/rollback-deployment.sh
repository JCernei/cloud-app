#!/bin/bash
# rollback-deployment.sh: Rollback the cloud-app deployment to a previous revision
# Usage: ./rollback-deployment.sh <namespace> [revision-number]

set -e

NAMESPACE="${1:-cloud-app-ns}"
REVISION="$2"

# First check if there's any history
if ! kubectl rollout history deployment/cloud-app -n "$NAMESPACE" | grep -q "REVISION"; then
    echo "Error: No rollout history found for deployment/cloud-app"
    echo "You need to have at least one previous deployment to roll back to."
    echo "Deploy a new version first by updating the image and applying the changes."
    exit 1
fi

# Show history
echo "Current deployment history:"
kubectl rollout history deployment/cloud-app -n "$NAMESPACE"

# If a specific revision was provided, roll back to that
if [ -n "$REVISION" ]; then
    echo "Rolling back to revision $REVISION..."
    kubectl rollout undo deployment/cloud-app -n "$NAMESPACE" --to-revision="$REVISION"
else
    # Check if there's more than one revision
    REVISION_COUNT=$(kubectl rollout history deployment/cloud-app -n "$NAMESPACE" | grep -c "^[0-9]")
    
    if [ "$REVISION_COUNT" -lt 2 ]; then
        echo "Error: Only one revision exists. You need at least two revisions to roll back."
        echo "Deploy a new version first by updating the image and applying the changes."
        exit 1
    fi
    
    echo "Rolling back to previous revision..."
    kubectl rollout undo deployment/cloud-app -n "$NAMESPACE"
fi

echo "Rollback triggered for deployment/cloud-app in namespace $NAMESPACE."
echo "Use 'kubectl rollout status deployment/cloud-app -n $NAMESPACE' to check status."
