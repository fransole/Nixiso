# Self-Hosted GitHub Runner Setup for Nixiso

This guide will help you set up a self-hosted GitHub Actions runner on your NixOS system to build the ISO images automatically.

## Prerequisites

### System Requirements

**Minimum:**
- 2 CPU cores
- 8GB RAM
- 50GB free disk space
- NixOS with flakes enabled

**Recommended:**
- 4+ CPU cores
- 16GB RAM
- 100GB SSD storage
- Fast internet connection

**Expected Build Times:**
- First build: 60-90 minutes (downloads and builds all dependencies)
- Subsequent builds: 20-40 minutes (with Nix cache)

---

## Setup Methods

You have two options for setting up the runner:

### Option 1: Using github-nix-ci Module (Recommended)

This is the easiest and most NixOS-native way to set up GitHub runners.

#### Step 1: Generate GitHub Personal Access Token

1. Go to GitHub Settings → Developer settings → Personal access tokens → Fine-grained tokens
2. Click "Generate new token"
3. Configure token:
   - **Token name**: `nixiso-runner`
   - **Expiration**: 90 days (or custom)
   - **Repository access**: Select "Only select repositories" → Choose `nixiso`
   - **Permissions**:
     - Actions: Read and write
     - Contents: Read
     - Metadata: Read (automatically included)
4. Click "Generate token" and copy the token value

#### Step 2: Store Token Securely

Create a secure location for the token:

```bash
sudo mkdir -p /var/lib/secrets
echo "YOUR_GITHUB_TOKEN_HERE" | sudo tee /var/lib/secrets/github-runner-token
sudo chmod 600 /var/lib/secrets/github-runner-token
sudo chown root:root /var/lib/secrets/github-runner-token
```

#### Step 3: Add github-nix-ci to Your Flake

Add to your system's `flake.nix` inputs:

```nix
inputs.github-nix-ci.url = "github:juspay/github-nix-ci";
```

#### Step 4: Configure Runner in configuration.nix

Add this to your NixOS configuration:

```nix
{ inputs, ... }: {
  imports = [
    inputs.github-nix-ci.nixosModules.default
  ];

  services.github-nix-ci = {
    age.secretsDir = "/var/lib/secrets";

    runners.nixiso-builder = {
      owner = "fransole";  # Your GitHub username
      repo = "nixiso";
      num = 1;
      tokenFile = "/var/lib/secrets/github-runner-token";
      labels = [ "self-hosted" "nixos" "x86_64-linux" ];
    };
  };
}
```

#### Step 5: Rebuild Your System

```bash
sudo nixos-rebuild switch
```

#### Step 6: Verify Runner is Active

1. Go to your GitHub repository: `https://github.com/fransole/nixiso`
2. Navigate to Settings → Actions → Runners
3. You should see your runner listed as "Idle" with a green dot

---

### Option 2: Manual Setup (Alternative)

If you prefer manual setup or the github-nix-ci module doesn't work for you:

#### Step 1: Navigate to Repository Settings

1. Go to `https://github.com/fransole/nixiso`
2. Click Settings → Actions → Runners
3. Click "New self-hosted runner"
4. Select Linux as OS and x86_64 as architecture

#### Step 2: Download and Install Runner

Follow the commands shown on GitHub, but adapt for NixOS:

```bash
# Create runner directory
mkdir -p ~/actions-runner && cd ~/actions-runner

# Download the runner (check GitHub for latest version)
curl -o actions-runner-linux-x64-2.311.0.tar.gz -L \
  https://github.com/actions/runner/releases/download/v2.311.0/actions-runner-linux-x64-2.311.0.tar.gz

# Extract
tar xzf ./actions-runner-linux-x64-2.311.0.tar.gz

# Configure the runner (use the token from GitHub page)
./config.sh --url https://github.com/fransole/nixiso --token YOUR_TOKEN_HERE

# Install as systemd service
sudo ./svc.sh install
sudo ./svc.sh start
```

#### Step 3: Verify Runner

Check status:
```bash
sudo ./svc.sh status
```

Go to GitHub Settings → Actions → Runners and verify it shows as "Idle"

---

## Post-Setup Configuration

### Binary Cache Configuration

To speed up builds, ensure your runner has access to Nix binary caches:

```nix
nix.settings = {
  substituters = [
    "https://cache.nixos.org"
    "https://nix-community.cachix.org"
    "https://cache.numtide.com"
  ];
  trusted-public-keys = [
    "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
    "niks3.numtide.com-1:DTx8wZduET09hRmMtKdQDxNNthLQETkc/yaX7M4qK0g="
  ];
  experimental-features = [ "nix-command" "flakes" ];
};
```

### Disk Space Management

ISO builds can consume significant disk space. Set up automatic garbage collection:

```nix
nix.gc = {
  automatic = true;
  dates = "weekly";
  options = "--delete-older-than 7d";
};

nix.settings.auto-optimise-store = true;
```

### Runner Labels

The workflow is configured to use `runs-on: self-hosted`. Ensure your runner has the appropriate labels:
- `self-hosted` (automatically added)
- `nixos` (optional, for clarity)
- `x86_64-linux` (optional, for clarity)

---

## Testing the Setup

### Trigger a Manual Build

1. Go to your repository on GitHub
2. Click Actions → Build NixOS Live ISO
3. Click "Run workflow" → Select branch "main"
4. Check "upload_artifact" if desired
5. Click "Run workflow"

### Monitor Build Progress

1. Click on the running workflow
2. Click on "build-iso" job
3. Watch the build logs

### Expected Output

- Build time: 20-60 minutes
- ISO size: 2-3GB
- Result: ISO file uploaded as artifact or released

---

## Troubleshooting

### Runner Not Appearing in GitHub

**Check runner status:**
```bash
# For github-nix-ci
sudo systemctl status github-nix-ci-nixiso-builder

# For manual setup
cd ~/actions-runner && sudo ./svc.sh status
```

**Check logs:**
```bash
# For github-nix-ci
sudo journalctl -u github-nix-ci-nixiso-builder -f

# For manual setup
cd ~/actions-runner && cat _diag/Worker_*.log
```

### Build Fails with "out of memory"

Increase available RAM or add swap:

```nix
swapDevices = [{
  device = "/var/swapfile";
  size = 8192;  # 8GB swap
}];
```

### Build Fails with "disk space"

Clean up Nix store:

```bash
nix-collect-garbage -d
sudo nix-collect-garbage -d
```

### Token Expired

Regenerate token on GitHub and update:

```bash
echo "NEW_TOKEN_HERE" | sudo tee /var/lib/secrets/github-runner-token
sudo systemctl restart github-nix-ci-nixiso-builder
```

---

## Security Considerations

### Token Security

- Store tokens in `/var/lib/secrets/` with `600` permissions
- Use fine-grained tokens with minimal permissions
- Set expiration dates (90 days recommended)
- Rotate tokens regularly

### Runner Isolation

- Run on a dedicated machine or VM if possible
- Don't run on your primary workstation
- Monitor resource usage
- Review workflow logs regularly

### Network Security

- Ensure runner has outbound internet access
- Firewall isn't required for outbound connections
- No inbound connections needed

---

## Maintenance

### Regular Tasks

**Weekly:**
- Check runner is active in GitHub Settings
- Monitor disk space usage
- Review build logs for errors

**Monthly:**
- Update flake inputs: `nix flake update`
- Test a manual build
- Check token expiration

**Quarterly:**
- Review and update NixOS system
- Regenerate GitHub token
- Clean up old artifacts/releases

### Updating the Runner

**For github-nix-ci:**
```bash
# Update flake input
nix flake lock --update-input github-nix-ci

# Rebuild
sudo nixos-rebuild switch
```

**For manual setup:**
```bash
cd ~/actions-runner
sudo ./svc.sh stop
./config.sh remove
# Download new version and reconfigure
sudo ./svc.sh install
sudo ./svc.sh start
```

---

## Additional Resources

- [github-nix-ci Documentation](https://github.com/juspay/github-nix-ci)
- [GitHub Actions Self-Hosted Runners](https://docs.github.com/en/actions/hosting-your-own-runners)
- [NixOS Manual](https://nixos.org/manual/nixos/stable/)
- [Nix Flakes Documentation](https://nixos.wiki/wiki/Flakes)

---

## Need Help?

If you encounter issues:
1. Check the troubleshooting section above
2. Review runner logs
3. Open an issue in the nixiso repository
4. Check NixOS Discourse or Matrix for community help
