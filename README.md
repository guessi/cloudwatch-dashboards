# CloudWatch Dashboards

A collection of ready-to-import Amazon CloudWatch dashboard templates for various AWS services.

> **Disclaimer:** This is an independent, community-maintained project and is not affiliated with, endorsed by, or sponsored by Amazon Web Services, Inc.

## Dashboards

| Service | Dashboard | Description |
|---|---|---|
| EKS | [`eks/eks-control-plane-dashboard.json`](eks/eks-control-plane-dashboard.json) | Amazon EKS control plane metrics (API server, etcd). Covers control plane only — install the CloudWatch Observability EKS add-on for node/pod-level data. |

## Usage

Choose **one** of the following methods to deploy a dashboard. Examples below use the EKS dashboard, but the same steps apply to any dashboard in this repo — just swap the file path.

**1) Import via the CloudWatch console**

1. Open the [CloudWatch console](https://console.aws.amazon.com/cloudwatch/) → **Dashboards** → **Create dashboard**.
2. Choose a name, then select **Add widget** → cancel, and instead use the **Actions** menu → **View/edit source**.
3. Paste the contents of the desired dashboard JSON file and save.

**2) Deploy via the AWS CLI (after cloning this repo)**

```bash
aws cloudwatch put-dashboard \
  --dashboard-name <your-dashboard-name> \
  --dashboard-body file://eks/eks-control-plane-dashboard.json
```

**3) Deploy via the AWS CLI (without cloning the repo)**

```bash
curl -s https://raw.githubusercontent.com/guessi/cloudwatch-dashboards/main/eks/eks-control-plane-dashboard.json -o /tmp/eks-control-plane-dashboard.json && \
aws cloudwatch put-dashboard \
  --dashboard-name <your-dashboard-name> \
  --dashboard-body file:///tmp/eks-control-plane-dashboard.json
```

## License

Licensed under the MIT License. See [LICENSE](LICENSE) for details.
