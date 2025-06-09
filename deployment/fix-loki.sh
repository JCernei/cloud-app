#!/bin/bash
# fix-loki.sh: Script to fix Loki deployment issues
# Usage: ./fix-loki.sh

set -e

NAMESPACE="logging"

echo "==== Fixing Loki Deployment ===="
echo ""

# Step 1: Delete the old Loki deployment if it exists
echo "Step 1: Removing old Loki deployment..."
kubectl delete deployment loki -n $NAMESPACE --ignore-not-found=true
kubectl delete statefulset loki -n $NAMESPACE --ignore-not-found=true
echo ""

# Step 2: Apply the updated logging.yaml which contains StatefulSet instead of Deployment
echo "Step 2: Applying updated logging configuration..."
kubectl apply -f deployment/k3s-deployment/logging.yaml
echo ""

# Step 3: Wait for the new Loki pod to start
echo "Step 3: Waiting for new Loki pod to be ready..."
kubectl wait --for=condition=ready pod -l app=loki -n $NAMESPACE --timeout=180s
echo ""

# Step 4: Verify that Loki is now running correctly
echo "Step 4: Checking Loki pod status..."
kubectl get pods -n $NAMESPACE -l app=loki -o wide
echo ""
kubectl logs -n $NAMESPACE -l app=loki --tail=20
echo ""

# Step 5: Check if compactor module is working properly
echo "Step 5: Verifying compactor module configuration..."
if kubectl logs -n $NAMESPACE -l app=loki | grep -i "failed to initialize module: compactor"; then
  echo "WARNING: Compactor module still has issues. Please check the Loki configuration."
else
  echo "Compactor module appears to be configured correctly."
fi
echo ""

echo "Loki should now be running with proper permissions and storage."
echo "To access the Loki API: http://localhost:31000"
echo "To see logs in Grafana, add Loki as a data source with URL: http://loki.logging.svc.cluster.local:3100"
echo ""
echo "If you still encounter issues, please refer to LOKI_TROUBLESHOOTING.md"
