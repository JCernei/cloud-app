#!/bin/bash
# db-persistence-test.sh: Script to demonstrate database persistence
# Usage: ./db-persistence-test.sh [operation] [data]
#   operations: add, get, or test
#   data: string to add to the database (only for 'add' operation)

set -e

NAMESPACE="cloud-app-ns"
OPERATION=${1:-"test"}
DATA=${2:-"This is a test entry from $(date)"}

# Function to execute SQL in the Postgres pod
run_sql() {
  local sql=$1
  echo "Executing SQL: $sql"
  kubectl exec -n $NAMESPACE $(kubectl get pod -n $NAMESPACE -l app=postgres -o jsonpath='{.items[0].metadata.name}') \
    -- psql -U postgres -d cloud_app_db -c "$sql"
}

# Function to create the test table if it doesn't exist
ensure_table() {
  echo "Ensuring test table exists..."
  run_sql "CREATE TABLE IF NOT EXISTS persistence_test (
    id SERIAL PRIMARY KEY,
    data TEXT NOT NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
  );"
}

# Function to add data to the test table
add_data() {
  local data=$1
  ensure_table
  echo "Adding data to test table: '$data'"
  run_sql "INSERT INTO persistence_test (data) VALUES ('$data') RETURNING id, data, created_at;"
}

# Function to get all data from the test table
get_data() {
  ensure_table
  echo "Retrieving all data from test table:"
  run_sql "SELECT * FROM persistence_test ORDER BY created_at DESC;"
}

# Function to run a full persistence test
run_persistence_test() {
  echo "=== RUNNING DATABASE PERSISTENCE TEST ==="
  echo ""
  
  # 1. Add initial test data
  echo "STEP 1: Adding initial test data..."
  add_data "$DATA"
  echo ""
  
  # 2. Check current data
  echo "STEP 2: Current data in the database:"
  get_data
  echo ""
  
  # 3. Stop the database pod
  echo "STEP 3: Stopping the database pod..."
  DB_POD=$(kubectl get pod -n $NAMESPACE -l app=postgres -o jsonpath='{.items[0].metadata.name}')
  echo "Database pod: $DB_POD"
  echo "Deleting pod..."
  kubectl delete pod -n $NAMESPACE $DB_POD
  echo ""
  
  # 4. Wait for the new pod to be ready
  echo "STEP 4: Waiting for new database pod to be ready..."
  echo "This may take a minute..."
  kubectl wait --for=condition=ready pod -l app=postgres -n $NAMESPACE --timeout=180s
  NEW_DB_POD=$(kubectl get pod -n $NAMESPACE -l app=postgres -o jsonpath='{.items[0].metadata.name}')
  echo "New database pod: $NEW_DB_POD"
  echo ""
  
  # 5. Check data after restart (with a delay to ensure the pod is fully ready)
  echo "STEP 5: Waiting a moment for database to be fully initialized..."
  sleep 10
  echo "Checking data after restart:"
  get_data
  echo ""
  
  # 6. Add more data after restart
  echo "STEP 6: Adding more data after restart..."
  NEW_DATA="Data added after restart: $(date)"
  add_data "$NEW_DATA"
  echo ""
  
  # 7. Show final state
  echo "STEP 7: Final state of the database:"
  get_data
  echo ""
  
  echo "=== PERSISTENCE TEST COMPLETE ==="
  echo "If you can see both the original data and the new data,"
  echo "this confirms that your database storage is persistent!"
}

# Main script logic
case "$OPERATION" in
  "add")
    add_data "$DATA"
    ;;
  "get")
    get_data
    ;;
  "test")
    run_persistence_test
    ;;
  *)
    echo "Unknown operation: $OPERATION"
    echo "Usage: $0 [operation] [data]"
    echo "  operations: add, get, or test"
    echo "  data: string to add to the database (only for 'add' operation)"
    exit 1
    ;;
esac
