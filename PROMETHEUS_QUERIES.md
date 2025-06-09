# Prometheus Queries for Monitoring Cloud App

Here are some useful Prometheus queries for monitoring your Cloud App application:

## System Health Queries

### JVM Memory Usage
```
# Total memory used by the JVM
sum(jvm_memory_used_bytes)

# Memory usage by area (heap vs non-heap)
sum(jvm_memory_used_bytes) by (area)

# Memory usage percentage
sum(jvm_memory_used_bytes) / sum(jvm_memory_max_bytes) * 100

# Memory used by each memory pool
sum(jvm_memory_used_bytes) by (id)
```

### CPU Usage
```
# Process CPU usage
process_cpu_usage

# System CPU usage
system_cpu_usage

# Normalized CPU usage (relative to available processors)
process_cpu_usage / system_cpu_count
```

### Thread Status
```
# Total number of JVM threads
jvm_threads_live_threads

# Threads by state
jvm_threads_states_threads
```

### Garbage Collection
```
# GC pause time in seconds
rate(jvm_gc_pause_seconds_sum[1m])

# GC collection count
rate(jvm_gc_pause_seconds_count[1m])

# GC memory allocated
rate(jvm_gc_memory_allocated_bytes_total[1m])

# GC memory promoted
rate(jvm_gc_memory_promoted_bytes_total[1m])
```

## Application Performance Queries

### HTTP Request Stats
```
# Total HTTP requests
sum(http_server_requests_seconds_count)

# HTTP requests per second
rate(http_server_requests_seconds_count[1m])

# HTTP requests by status code
sum(http_server_requests_seconds_count) by (status)

# HTTP requests by method
sum(http_server_requests_seconds_count) by (method)

# HTTP requests by endpoint
sum(http_server_requests_seconds_count) by (uri)
```

### Response Time
```
# Average response time
rate(http_server_requests_seconds_sum[1m]) / rate(http_server_requests_seconds_count[1m])

# 95th percentile response time for a specific endpoint
histogram_quantile(0.95, sum(rate(http_server_requests_seconds_bucket{uri="/your-endpoint"}[5m])) by (le))

# Max response time in the last 5 minutes
max_over_time(http_server_requests_seconds_max[5m])
```

### Error Rates
```
# Error rate (non-2xx responses)
sum(rate(http_server_requests_seconds_count{status!~"2.."}[1m])) / sum(rate(http_server_requests_seconds_count[1m]))

# Specific error counts by status code
sum(rate(http_server_requests_seconds_count{status=~"5.."}[1m])) by (uri)
```

## Database Connection Queries

### Hikari Connection Pool (if you're using it)
```
# Active connections
hikaricp_connections_active

# Idle connections
hikaricp_connections_idle

# Pending threads
hikaricp_connections_pending

# Connection timeouts
rate(hikaricp_connections_timeout_total[1m])
```

## Custom Application Metrics

If you've added custom metrics to your application, you can query them like:

```
# Example for a custom counter
rate(my_custom_counter_total[1m])

# Example for a custom gauge
my_custom_gauge
```

## System Resource Queries

### Disk Usage
```
# Node disk usage (if node_exporter is running)
(node_filesystem_size_bytes - node_filesystem_free_bytes) / node_filesystem_size_bytes * 100
```

### Network Usage
```
# Network I/O (if node_exporter is running)
rate(node_network_receive_bytes_total[1m])
rate(node_network_transmit_bytes_total[1m])
```

## Alerting Rules Examples

These queries can be used to create alerting rules in Prometheus:

```
# CPU usage too high
process_cpu_usage > 0.8

# High memory usage
sum(jvm_memory_used_bytes) / sum(jvm_memory_max_bytes) * 100 > 90

# High error rate
sum(rate(http_server_requests_seconds_count{status=~"5.."}[1m])) / sum(rate(http_server_requests_seconds_count[1m])) > 0.05

# Slow response time
rate(http_server_requests_seconds_sum[1m]) / rate(http_server_requests_seconds_count[1m]) > 1
```

## How to Use These Queries

1. Access the Prometheus UI at http://localhost:30090
2. Enter the query in the "Expression" box
3. Click "Execute" to run the query
4. Use the "Graph" tab to visualize metrics over time

For continuous monitoring, it's recommended to set up Grafana dashboards that use these Prometheus queries as data sources.
