# Alternative Approaches for CI/CD with Local Kubernetes

## Option 1: Self-Hosted GitHub Runner (Recommended)

For local Kubernetes clusters, a self-hosted GitHub Actions runner is the simplest and most secure approach. 

**Follow the instructions in `SELF_HOSTED_RUNNER.md` for setup.**

With this approach:
- The runner runs on your local machine
- It has direct access to your local Kubernetes cluster
- No need to expose your Kubernetes API to the internet
- No need to configure Kubernetes config secrets

## Option 2: Kubernetes Config as Secret (Alternative)

### Step 1: Get Your Kubernetes Config

Run the following command to get your kubeconfig:

```bash
cat ~/.kube/config
```

### Step 2: Encode the Config as Base64

```bash
cat ~/.kube/config | base64 -w 0
```

Copy the output (a long base64 string).

### Step 3: Add the Secret to GitHub Repository

1. Go to your GitHub repository
2. Click on "Settings" > "Secrets and variables" > "Actions"
3. Click "New repository secret"
4. Name: `KUBE_CONFIG_DATA`
5. Value: Paste the base64-encoded kubeconfig
6. Click "Add secret"

### Step 4: Verify Network Access

Since GitHub Actions runners are external to your network, your Kubernetes API server needs to be accessible from the internet. This can be done by:

1. Exposing your Kubernetes API server securely with proper authentication
2. Using a VPN or secure tunnel
3. Using a self-hosted GitHub runner within your network

For local development, consider using a self-hosted runner or a secure tunneling service like ngrok or inlets.

### Step 5: Testing Access

After adding the secret, the next GitHub Actions workflow run will attempt to use this configuration to deploy to your Kubernetes cluster.

If you encounter connection issues, check:
- Network connectivity between GitHub Actions and your cluster
- Authentication tokens and certificates are still valid
- API server is accessible from outside your network

### Security Considerations

- The `KUBE_CONFIG_DATA` secret gives complete access to your cluster
- Consider using a restricted service account with limited permissions
- Rotate credentials periodically
- Monitor GitHub Actions logs for any unauthorized access attempts
