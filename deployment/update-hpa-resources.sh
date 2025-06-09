#!/bin/bash
# update-hpa-resources.sh: Updates the deployment with CPU/memory resource settings for HPA
# Usage: ./update-hpa-resources.sh <namespace>

set -e

NAMESPACE="${1:-cloud-app-ns}"

echo "Updating cloud-app deployment with CPU and memory resource settings..."

# Apply the updated deployment configuration
kubectl apply -f deployment/k3s-deployment/cloud-app-deployment.yaml

# Restart the deployment to ensure the new settings are applied
kubectl rollout restart deployment/cloud-app -n "$NAMESPACE"

# Wait for the rollout to complete
kubectl rollout status deployment/cloud-app -n "$NAMESPACE"

echo "Deployment updated with resource settings for HPA."
echo "Verify the HPA is now working with:"
echo "kubectl describe hpa cloud-app-hpa -n $NAMESPACE"
echo ""
echo "Wait a few minutes for metrics to be collected, then try running the load test:"
echo "./deployment/simulate-load.sh"
