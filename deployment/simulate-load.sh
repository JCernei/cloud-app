#!/bin/bash
# simulate-load.sh: Script to generate load on the application to demonstrate autoscaling
# Usage: ./simulate-load.sh <duration-in-seconds> [requests-per-second] [concurrent-connections]

set -e

DURATION=${1:-300}  # Default: 5 minutes
RPS=${2:-100}       # Default: 100 requests per second
CONCURRENCY=${3:-10} # Default: 10 concurrent connections
NAMESPACE="cloud-app-ns"
APP_URL=""

# Check for required tools
if ! command -v kubectl &> /dev/null; then
  echo "kubectl not found. Please install kubectl and try again."
  exit 1
fi

if ! command -v hey &> /dev/null; then
  echo "Load testing tool 'hey' not found. Installing it now..."
  
  # Check OS and install hey accordingly
  if [[ "$OSTYPE" == "linux-gnu"* ]]; then
    # For Linux
    echo "Detected Linux. Installing hey..."
    curl -sf https://gobinaries.com/rakyll/hey | sh
  elif [[ "$OSTYPE" == "darwin"* ]]; then
    # For MacOS
    echo "Detected MacOS. Installing hey using brew..."
    brew install hey
  else
    echo "Unsupported OS. Please install 'hey' manually: https://github.com/rakyll/hey"
    exit 1
  fi
fi

# Get the app URL from the service
echo "Getting application endpoint..."
NODE_PORT=$(kubectl get svc cloud-app-service -n $NAMESPACE -o jsonpath='{.spec.ports[0].nodePort}')
NODE_IP=$(kubectl get nodes -o jsonpath='{.items[0].status.addresses[?(@.type=="InternalIP")].address}')

if [[ -z "$NODE_PORT" || -z "$NODE_IP" ]]; then
  echo "Could not determine application URL. Using localhost:30000 as default."
  APP_URL="http://localhost:30000"
else
  APP_URL="http://$NODE_IP:$NODE_PORT"
fi

echo "Application URL: $APP_URL"

# Show current HPA status before load
echo "Current HPA status before load:"
kubectl get hpa -n $NAMESPACE
echo ""

echo "Current pods before load:"
kubectl get pods -n $NAMESPACE
echo ""

# Start load test
echo "Starting load test: $RPS requests/second with $CONCURRENCY concurrent connections for $DURATION seconds"
echo "Press Ctrl+C to stop the test early"
echo ""

# Run hey in the background
hey -z ${DURATION}s -q $RPS -c $CONCURRENCY $APP_URL &
HEY_PID=$!

# Monitor HPA while load test is running
echo "Monitoring HPA and pods during load test..."
END_TIME=$(($(date +%s) + DURATION))
MONITOR_INTERVAL=10 # seconds

while [ $(date +%s) -lt $END_TIME ]; do
  if ! kill -0 $HEY_PID 2>/dev/null; then
    echo "Load test finished early"
    break
  fi
  
  echo "=== $(date) ==="
  echo "HPA status:"
  kubectl get hpa -n $NAMESPACE
  echo ""
  echo "Pod status:"
  kubectl get pods -n $NAMESPACE
  echo ""
  
  sleep $MONITOR_INTERVAL
done

# Clean up if hey is still running
if kill -0 $HEY_PID 2>/dev/null; then
  kill $HEY_PID
  echo "Load test stopped"
fi

# Show final state
echo "Load test completed"
echo ""
echo "Final HPA status:"
kubectl get hpa -n $NAMESPACE
kubectl describe hpa -n $NAMESPACE
echo ""
echo "Final pod status:"
kubectl get pods -n $NAMESPACE
