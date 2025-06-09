# Testing Database Persistence in Kubernetes

This document explains how to demonstrate data persistence in your PostgreSQL database running in Kubernetes.

## What is Persistence?

Persistence means that your data remains safe and available even if:
- The database container/pod is restarted
- The database pod is deleted and recreated
- The node running the database crashes

This is achieved through Kubernetes persistent volumes that are linked to your StatefulSet.

## Running the Persistence Test

A script has been provided to demonstrate database persistence:

```bash
./deployment/db-persistence-test.sh
```

### What the Test Does

1. Creates a test table in your database (if it doesn't exist)
2. Adds initial test data
3. Shows all current data
4. **Deletes the database pod** (forcing Kubernetes to create a new one)
5. Waits for the new pod to be ready
6. Verifies the data still exists
7. Adds more data to confirm the database is working
8. Shows the final state of the data

### Expected Results

If persistence is working correctly, you should see:
- The original data from before restarting the pod
- The new data added after restarting the pod

This confirms that your database storage is properly persisted even when pods are deleted and recreated.

## Manual Testing

You can also use the script for manual testing:

```bash
# Add custom data to the database
./deployment/db-persistence-test.sh add "My custom data entry"

# Retrieve all data from the database
./deployment/db-persistence-test.sh get

# Run a complete persistence test
./deployment/db-persistence-test.sh test
```

## How Persistence Works in Your Setup

Your PostgreSQL database uses:
1. A **StatefulSet** instead of a Deployment (in `postgres-deployment.yaml`)
2. **volumeClaimTemplates** that create a PersistentVolumeClaim
3. A **volumeMount** that mounts the persistent storage to `/var/lib/postgresql/data`

This ensures that your data is stored on persistent storage rather than within the container's filesystem.

## Potential Issues

If data is not persisting, check:
1. The StatefulSet configuration in `postgres-deployment.yaml`
2. Whether PersistentVolumeClaims are being created:
   ```bash
   kubectl get pvc -n cloud-app-ns
   ```
3. Whether the PersistentVolumes are properly bound:
   ```bash
   kubectl get pv
   ```
