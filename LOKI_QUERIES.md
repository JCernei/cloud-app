# Using Loki in Grafana for Log Queries

This guide provides information on using Loki with Grafana to query and visualize logs from your cloud application.

## Accessing Logs in Grafana

1. Access Grafana at http://localhost:30300
2. Log in with username: `admin`, password: `admin`
3. Go to the Explore section (compass icon in the sidebar)
4. Select "Loki" from the data source dropdown at the top

## Basic LogQL Queries

Here are some useful LogQL queries to help you get started:

### 1. View all logs from cloud-app namespace

```
{namespace="cloud-app-ns"}
```

### 2. View logs for a specific application

```
{app="cloud-app"}
```

### 3. View logs for a specific pod

```
{pod="cloud-app-b4c87b98d-n8r4w"}
```

### 4. View logs containing errors

```
{namespace="cloud-app-ns"} |~ "(?i)error"
```

### 5. View logs containing warnings

```
{namespace="cloud-app-ns"} |~ "(?i)warn"
```

### 6. View logs from a specific container

```
{container="cloud-app"}
```

### 7. Filter logs by time

Use the time picker in the top-right corner of Grafana to select time ranges like:
- Last 5 minutes
- Last 15 minutes
- Last 1 hour
- Custom time range

## Advanced LogQL Queries

### 1. Counting log lines

Count error logs per minute:
```
count_over_time({namespace="cloud-app-ns"} |~ "(?i)error"[1m])
```

### 2. Extracting and filtering on labels

Extract and filter on status code:
```
{namespace="cloud-app-ns"} | json | status_code >= 400
```

### 3. Regular expression matching

Find logs with HTTP status codes:
```
{namespace="cloud-app-ns"} |~ "status [0-9]{3}"
```

## Creating Dashboards

1. Go to Dashboards → New → New Dashboard
2. Add a new panel
3. Select "Loki" as the data source
4. Enter your LogQL query
5. Choose visualization type (Logs, Graph, etc.)
6. Save the dashboard with a meaningful name

## Troubleshooting

If you don't see any logs:

1. Verify Loki is running:
   ```
   kubectl get pods -n logging
   ```

2. Check Promtail logs:
   ```
   kubectl logs -n logging -l app=promtail
   ```

3. Ensure your time range is appropriate. Logs older than the retention period won't be available.

4. Check if your application is generating logs to stdout/stderr rather than to files.

## Additional Resources

- [LogQL Documentation](https://grafana.com/docs/loki/latest/logql/)
- [Loki Best Practices](https://grafana.com/docs/loki/latest/best-practices/)
- [Grafana Explore Documentation](https://grafana.com/docs/grafana/latest/explore/)
