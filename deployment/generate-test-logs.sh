#!/bin/bash
# filepath: /home/ion/projects/cloud-app/deployment/generate-test-logs.sh
# generate-test-logs.sh: Script to generate test logs for the cloud app
# Usage: ./generate-test-logs.sh

set -e

NAMESPACE="cloud-app-ns"
APP_PODS=$(kubectl get pods -n $NAMESPACE -l app=cloud-app -o jsonpath='{.items[*].metadata.name}')

if [ -z "$APP_PODS" ]; then
  echo "No cloud-app pods found in namespace $NAMESPACE"
  exit 1
fi

echo "=== Generating test logs for cloud-app ==="
echo ""

for POD in $APP_PODS; do
  echo "Generating logs for pod: $POD"
  for i in {1..10}; do
    kubectl exec -n $NAMESPACE $POD -- sh -c "echo 'Test log entry $i from cloud-app at $(date)' > /proc/1/fd/1"
    echo "."
    sleep 1
  done
  # Generate some error logs as well
  for i in {1..5}; do
    kubectl exec -n $NAMESPACE $POD -- sh -c "echo 'ERROR: Test error log entry $i from cloud-app at $(date)' > /proc/1/fd/2"
    echo "x"
    sleep 1
  done
  echo "Done"
done

echo ""
echo "=== Test logs generated ==="
echo "You can now check Grafana (http://localhost:30300) to see the logs with the query:"
echo "1. {namespace=\"$NAMESPACE\"}"
echo "or"
echo "2. {app=\"cloud-app\"}"
