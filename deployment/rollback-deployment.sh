#!/bin/bash
# rollback-deployment.sh: Rollback the cloud-app deployment to a previous revision
# Usage: ./rollback-deployment.sh <namespace>

set -e

NAMESPACE="${1:-cloud-app-ns}"

kubectl rollout undo deployment/cloud-app -n "$NAMESPACE"

echo "Rollback triggered for deployment/cloud-app in namespace $NAMESPACE."
