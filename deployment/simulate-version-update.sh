#!/bin/bash
# simulate-version-update.sh: Simulate a new version of the application deployment
# Usage: ./simulate-version-update.sh <namespace> [docker-hub-username]

set -e

NAMESPACE="${1:-cloud-app-ns}"
DOCKERHUB_USERNAME="${2:-jcernei}"

# Update the app with a no-op change to trigger a new deployment revision
echo "Simulating a version update by updating annotations..."
kubectl patch deployment/cloud-app -n "$NAMESPACE" -p '{
  "spec": {
    "template": {
      "metadata": {
        "annotations": {
          "kubectl.kubernetes.io/restartedAt": "'$(date +%Y-%m-%dT%H:%M:%S%z)'"
        }
      }
    }
  }
}'

echo "New deployment revision created. You can now use rollback-deployment.sh"
echo "Check the history with: ./check-deployment-history.sh $NAMESPACE"
