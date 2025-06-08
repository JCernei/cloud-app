# setup-local-k8s.sh: Installs and starts all local Kubernetes resources for the project
# Usage: ./setup-local-k8s.sh <your-dockerhub-username>

set -e

if [ -z "$1" ]; then
  echo "Usage: $0 <your-dockerhub-username>"
  exit 1
fi

DOCKERHUB_USERNAME="$1"

# Check for kubectl
if ! command -v kubectl &> /dev/null; then
  echo "kubectl not found. Please install kubectl and configure it for your local cluster."
  exit 1
fi

# Check if cluster is running
if ! kubectl cluster-info &> /dev/null; then
  echo "Kubernetes cluster not running or not configured. Please start your local cluster (minikube, k3s, kind, etc)."
  exit 1
fi

# Create namespaces and apply monitoring/logging
kubectl apply -f deployment/k3s-deployment/monitoring-namespaces.yaml
kubectl apply -f deployment/k3s-deployment/monitoring.yaml
kubectl apply -f deployment/k3s-deployment/logging.yaml

# Deploy database
kubectl apply -f deployment/k3s-deployment/postgres-deployment.yaml

# Deploy application (latest image)
export DOCKERHUB_USERNAME
./deployment/deploy-latest.sh "$DOCKERHUB_USERNAME"

# Deploy autoscaler
kubectl apply -f deployment/k3s-deployment/cloud-app-hpa.yaml

# Show status
kubectl get pods -A
kubectl get svc -A

cat <<EOF

---
All resources have been applied!

- App:           http://localhost:8080 (or NodePort if using minikube/kind)
- Prometheus:    http://localhost:30090
- Grafana:       http://localhost:30300
- Loki:          http://localhost:31000

To rollback deployment:
  ./deployment/rollback-deployment.sh

To clean up:
  kubectl delete -f deployment/k3s-deployment/
---
EOF
