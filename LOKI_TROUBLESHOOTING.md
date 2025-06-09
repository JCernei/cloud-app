# Troubleshooting Loki Deployment

This document explains the issues you were facing with Loki and how they've been fixed.

## The Problem

The error message indicated:
```
creating WAL folder at "/wal": mkdir wal: permission denied
```

This was happening because:

1. **Permission Issues**: The Loki container was running without proper permissions to create directories
2. **Missing Volumes**: No persistent storage was provided for Loki's data, including the write-ahead log (WAL)
3. **Incorrect Configuration**: The WAL wasn't explicitly configured in the Loki config

## The Solution

The following changes have been made to fix these issues:

### 1. Changed Deployment to StatefulSet

- StatefulSets are better suited for stateful applications like Loki
- They provide stable, unique network identifiers
- They support persistent storage through volumeClaimTemplates

### 2. Added Proper Security Context

```yaml
securityContext:
  fsGroup: 10001
  runAsGroup: 10001
  runAsNonRoot: true
  runAsUser: 10001
```

This ensures the container runs with the correct user ID (10001) which matches the Loki image's expected permissions.

### 3. Added Persistent Storage

```yaml
volumeClaimTemplates:
- metadata:
    name: loki-data
  spec:
    accessModes: ["ReadWriteOnce"]
    resources:
      requests:
        storage: 10Gi
```

This provides a 10GB persistent volume for Loki's data, including:
- Write-Ahead Log (WAL)
- Index files
- Chunks storage
- Cache files

### 4. Updated Loki Configuration

```yaml
ingester:
  # ... existing config ...
  wal:
    enabled: true
    dir: /loki/wal
```

This explicitly configures the WAL directory and ensures it's enabled.

## How to Apply the Fix

A script has been provided to apply these fixes:

```bash
./deployment/fix-loki.sh
```

This script will:
1. Remove the old Loki deployment
2. Apply the updated configuration
3. Wait for the new Loki pod to become ready
4. Verify that Loki is running correctly

## Verifying the Fix

After running the fix script, you should be able to:

1. See Loki running without errors:
   ```bash
   kubectl logs -n logging -l app=loki
   ```

2. Access the Loki API at http://localhost:31000

3. Configure Grafana to use Loki as a data source with URL:
   ```
   http://loki.logging.svc.cluster.local:3100
   ```

## Additional Improvements

### Fixed Compactor Configuration

Another issue that was encountered was with the Loki compactor module:

```
failed to initialize module: compactor
```

This was fixed by improving the overall Loki configuration, particularly by adding the `common` section which properly configures the ring and storage paths:

```yaml
common:
  path_prefix: /loki
  storage:
    filesystem:
      chunks_directory: /loki/chunks
      rules_directory: /loki/rules
  replication_factor: 1
  ring:
    kvstore:
      store: inmemory
```

The improved configuration provides:

1. A centralized `common` section for shared settings
2. Clear path definitions for all components
3. Proper ring configuration for the compactor to use

This configuration approach matches the latest Loki best practices and ensures all components can properly coordinate their activities.

## Monitoring Loki Health

After fixing these issues, you can monitor Loki's health by:

1. Checking the logs:
   ```bash
   kubectl logs -n logging -l app=loki
   ```

2. Verifying metrics are being collected:
   ```bash
   curl http://localhost:31000/metrics
   ```

3. Querying logs from Grafana's Explore section with LogQL

The fix also includes:
- Read-only root filesystem for improved security
- Dropped all Linux capabilities for better security
- Temporary directory mounted as emptyDir
- Service account for Loki
