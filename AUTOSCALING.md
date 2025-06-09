# Demonstrating Kubernetes Autoscaling

This guide will help you demonstrate how the Horizontal Pod Autoscaler (HPA) scales your application in response to load.

## Prerequisites

- Your Kubernetes cluster is running
- You have deployed the application with `./setup-local-k8s.sh <your-dockerhub-username>`
- You have applied the HPA with `kubectl apply -f deployment/k3s-deployment/cloud-app-hpa.yaml`

## Important: Resource Requirements for HPA

For the HPA to work correctly, your pods **must** have CPU resource requests defined. If you see errors like "missing request for cpu in container", run the update script:

```bash
./deployment/update-hpa-resources.sh
```

This script adds the necessary CPU and memory resource requests to your deployment.

## 1. Verify Current State

First, check the current state of your HPA and pods:

```bash
kubectl get hpa -n cloud-app-ns
kubectl get pods -n cloud-app-ns
```

You should see the HPA configured with min=2, max=5 replicas, and the current number of pods (likely the minimum of 2).

## 2. Generate Load to Trigger Autoscaling

Use the provided script to generate load on your application:

```bash
# Basic usage (5 minutes of load)
./deployment/simulate-load.sh

# Custom duration (2 minutes)
./deployment/simulate-load.sh 120

# Custom duration and requests per second
./deployment/simulate-load.sh 180 200

# Full customization (3 minutes, 250 requests/sec, 20 concurrent connections)
./deployment/simulate-load.sh 180 250 20
```

The script will:
1. Install the `hey` load testing tool if it's not already installed
2. Find your application's endpoint
3. Generate HTTP load on your application
4. Monitor the HPA status and pod count at regular intervals

## 3. What to Look For

During the test, you should observe:

1. **Increasing CPU Utilization**: The HPA should show increasing CPU utilization
2. **Scaling Up**: After CPU utilization exceeds the target (60%), new pods will be created
3. **Maximum Replicas**: The system will scale up to the maximum of 5 replicas if load is high enough

## 4. After the Test

After the load stops:

1. **Cool-down Period**: Kubernetes won't immediately scale down pods
2. **Gradual Scale-down**: After a few minutes (typically 5-10), pods will gradually be removed
3. **Return to Minimum**: Eventually, the pod count will return to the minimum of 2

## 5. Understanding the Results

- **Scale-up Delay**: There's typically a 30-60 second delay between increased load and new pods
- **Scale-down Delay**: There's a longer delay (5+ minutes) before scaling down after load decreases
- **HPA Algorithms**: Kubernetes uses sophisticated algorithms to prevent thrashing (rapid scaling up and down)

## Additional Options

You can modify your HPA configuration (`deployment/k3s-deployment/cloud-app-hpa.yaml`) to:
- Change target CPU utilization (currently 60%)
- Modify minimum and maximum replicas
- Add memory-based scaling
- Configure behavior policies for scaling up/down

```bash
kubectl edit hpa cloud-app-hpa -n cloud-app-ns
```

or edit the yaml file and reapply it.
