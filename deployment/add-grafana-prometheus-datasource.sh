#!/bin/bash
# filepath: /home/ion/projects/cloud-app/deployment/add-grafana-prometheus-datasource.sh
# add-grafana-prometheus-datasource.sh: Script to add Prometheus as a data source in Grafana
# Usage: ./add-grafana-prometheus-datasource.sh

set -e

NAMESPACE="monitoring"
GRAFANA_POD=$(kubectl get pods -n $NAMESPACE -l app=grafana -o jsonpath='{.items[0].metadata.name}')

echo "=== Adding Prometheus data source to Grafana ==="
echo ""

# Create the data source JSON payload
echo "Creating data source configuration..."
cat <<EOF > /tmp/prometheus-datasource.json
{
  "name": "Prometheus",
  "type": "prometheus",
  "access": "proxy",
  "url": "http://prometheus.monitoring.svc.cluster.local:9090",
  "basicAuth": false,
  "isDefault": false,
  "jsonData": {
    "timeInterval": "15s"
  }
}
EOF

# Apply the data source to Grafana
echo "Applying data source to Grafana..."
kubectl -n $NAMESPACE exec $GRAFANA_POD -- curl -s -X POST -H "Content-Type: application/json" -d @- \
  --user admin:admin \
  http://localhost:3000/api/datasources < /tmp/prometheus-datasource.json

echo ""
echo "=== Prometheus data source has been added to Grafana ==="
echo "You can now view metrics in Grafana (http://localhost:30300) by:"
echo "1. Logging in with username: admin, password: admin"
echo "2. Going to Explore (compass icon in the sidebar)"
echo "3. Selecting 'Prometheus' from the data source dropdown"
echo "4. Using a PromQL query like 'up' to see which targets are being scraped"
