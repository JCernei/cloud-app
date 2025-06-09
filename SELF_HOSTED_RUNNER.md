# Setting Up a Self-Hosted GitHub Runner

This guide explains how to set up a self-hosted GitHub Actions runner on your local machine, which can access your local Kubernetes cluster directly.

## Benefits of a Self-Hosted Runner
- Direct access to your local Kubernetes cluster
- No need to expose your Kubernetes API to the internet
- No need for complex VPN or tunneling solutions
- Full control over the runner environment

## Setup Instructions

### Step 1: Create a Runner in GitHub
1. Go to your GitHub repository
2. Click on "Settings" > "Actions" > "Runners"
3. Click "New self-hosted runner"
4. Select your operating system (Linux)

### Step 2: Download and Configure the Runner

GitHub will display commands similar to these (copy the actual commands from GitHub):

```bash
# Download the runner package
mkdir actions-runner && cd actions-runner
curl -o actions-runner-linux-x64-2.310.2.tar.gz -L https://github.com/actions/runner/releases/download/v2.310.2/actions-runner-linux-x64-2.310.2.tar.gz
tar xzf ./actions-runner-linux-x64-2.310.2.tar.gz

# Configure the runner
./config.sh --url https://github.com/YOUR-USERNAME/cloud-app --token YOUR_TOKEN
```

### Step 3: Install and Start the Runner as a Service

```bash
# Install the runner as a service
sudo ./svc.sh install

# Start the runner service
sudo ./svc.sh start
```

### Step 4: Update Your GitHub Actions Workflow

Update your workflow to use the self-hosted runner by modifying the `.github/workflows/docker-build-push.yml` file:

```yaml
jobs:
  build-and-push:
    runs-on: self-hosted  # Use this instead of ubuntu-latest
    steps:
      # ... existing steps ...
```

## Maintaining Your Self-Hosted Runner

### Checking the Status
```bash
cd actions-runner
sudo ./svc.sh status
```

### Updating the Runner
```bash
cd actions-runner
sudo ./svc.sh stop
./config.sh remove --token YOUR_TOKEN
# Download the new version and configure again
sudo ./svc.sh install
sudo ./svc.sh start
```

### Security Considerations
- The runner has access to your local environment
- It can access your local Kubernetes cluster and potentially sensitive information
- Only enable it for repositories you trust
- Consider running it in a container or VM for better isolation

## Troubleshooting

If your workflow is not running on the self-hosted runner:
- Ensure the runner is online (check the status in GitHub)
- Make sure the workflow specifies `runs-on: self-hosted`
- Check the runner logs: `cd actions-runner && tail -f _diag/*.log`
