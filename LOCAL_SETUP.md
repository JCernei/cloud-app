# Local CI/CD, Kubernetes, Monitoring & Logging Setup

This guide will help you set up, deploy, and verify your Spring Boot application with Docker, Kubernetes, autoscaling, monitoring, and logging—all running locally.

---

## Prerequisites
- Local Kubernetes cluster (k3s, minikube, or kind)
- Docker installed and running
- `kubectl` configured for your local cluster
- Docker Hub account
- GitHub repository for your project

---

## 1. Set Up GitHub Actions for CI/CD
1. **Add Docker Hub secrets to your GitHub repository:**
   - Go to your repo → Settings → Secrets and variables → Actions → New repository secret
   - Add `DOCKERHUB_USERNAME` and `DOCKERHUB_TOKEN` (Docker Hub access token)
2. **Push or merge to `main` branch:**
   - This triggers the workflow in `.github/workflows/docker-build-push.yml` to build and push your Docker image to Docker Hub.
3. **Check the Actions tab:**
   - Ensure the workflow completes successfully and the image appears in your Docker Hub repo.

---

## 2. Deploy to Local Kubernetes

### a. Create Namespaces and Deploy Monitoring/Logging
```bash
kubectl apply -f deployment/k3s-deployment/monitoring-namespaces.yaml
kubectl apply -f deployment/k3s-deployment/monitoring.yaml
kubectl apply -f deployment/k3s-deployment/logging.yaml
```

### b. Deploy Database and Application
```bash
kubectl apply -f deployment/k3s-deployment/postgres-deployment.yaml
./deployment/deploy-latest.sh <your-dockerhub-username>
kubectl apply -f deployment/k3s-deployment/cloud-app-hpa.yaml
```

---

## 3. Verify Everything is Running

- **Check pods:**
  ```bash
  kubectl get pods -A
  ```
  All pods should be `Running` or `Completed`.

- **Check services:**
  ```bash
  kubectl get svc -A
  ```
  Note the `NodePort` values for Prometheus (30090), Grafana (30300), and Loki (31000).

- **Access the app:**
  - Open [http://localhost:30000](http://localhost:30000) (as configured in cloud-app-deployment.yaml)

- **Access monitoring/logging UIs:**
  - Prometheus: [http://localhost:30090](http://localhost:30090)
  - Grafana: [http://localhost:30300](http://localhost:30300)

---

## 4. Test Autoscaling

- Simulate load on your app (e.g., with `ab` or `hey`).
- Watch pods scale up:
  ```bash
  kubectl get hpa -n cloud-app-ns
  kubectl get pods -n cloud-app-ns
  ```

---

## 5. Rollback Deployment

- To rollback to the previous version:
  ```bash
  ./deployment/rollback-deployment.sh
  ```

---

## 6. Troubleshooting
- If pods are not running, check logs:
  ```bash
  kubectl logs <pod-name> -n <namespace>
  ```
- If services are not accessible, check NodePort and firewall settings.

---

## 7. Clean Up
- To remove all resources:
  ```bash
  kubectl delete -f deployment/k3s-deployment/
  ```

---

**You’re all set!**

For further customization or issues, check your manifests and scripts in the `deployment/` folder.
