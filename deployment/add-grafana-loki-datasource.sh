#!/bin/bash
# add-grafana-loki-datasource.sh: Script to add Loki as a data source in Grafana
# Usage: ./add-grafana-loki-datasource.sh

set -e

NAMESPACE="monitoring"
GRAFANA_POD=$(kubectl get pods -n $NAMESPACE -l app=grafana -o jsonpath='{.items[0].metadata.name}')

echo "=== Adding Loki data source to Grafana ==="
echo ""

# Create the data source JSON payload
echo "Creating data source configuration..."
cat <<EOF > /tmp/loki-datasource.json
{
  "name": "Loki",
  "type": "loki",
  "access": "proxy",
  "url": "http://loki.logging.svc.cluster.local:3100",
  "basicAuth": false,
  "isDefault": true,
  "jsonData": {}
}
EOF

# Apply the data source to Grafana
echo "Applying data source to Grafana..."
kubectl -n $NAMESPACE exec $GRAFANA_POD -- curl -s -X POST -H "Content-Type: application/json" -d @- \
  --user admin:admin \
  http://localhost:3000/api/datasources < /tmp/loki-datasource.json

echo ""
echo "=== Loki data source has been added to Grafana ==="
echo "You can now view logs in Grafana (http://localhost:30300) by:"
echo "1. Logging in with username: admin, password: admin"
echo "2. Going to Explore (compass icon in the sidebar)"
echo "3. Selecting 'Loki' from the data source dropdown"
echo "4. Using a LogQL query like '{job=\"varlogs\"}'"
