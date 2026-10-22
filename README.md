# CloudWatch Dashboards

A collection of ready-to-import Amazon CloudWatch dashboard templates for various AWS services.

> **Disclaimer:** This is an independent, community-maintained project and is not affiliated with, endorsed by, or sponsored by Amazon Web Services, Inc.

## Dashboards

| Service | Dashboard | Description |
|---|---|---|
| EKS | [`eks/eks-control-plane-dashboard.json`](eks/eks-control-plane-dashboard.json) | Amazon EKS control plane metrics (API server, etcd, scheduler, webhooks), plus node count / failed node count across clusters. The node charts require the CloudWatch Observability EKS add-on (Container Insights). |
| EKS | [`eks/eks-control-plane-dashboard-pinned.json`](eks/eks-control-plane-dashboard-pinned.json) | Same per-cluster charts for a **fixed list of clusters in one region**, with a single Cluster Name dropdown and no all-clusters overview. This is a template: generate your dashboard from it with a script — see [Using the pinned-cluster dashboard](#using-the-pinned-cluster-dashboard). |

**Which one should I use?**

- Want to see **all clusters** in a region and switch between them freely? Use `eks-control-plane-dashboard.json`. It works as-is: clusters are discovered automatically.
- Want a dashboard that lists **only specific clusters** (for example, just your production clusters)? Follow [Using the pinned-cluster dashboard](#using-the-pinned-cluster-dashboard).

## Usage

Choose **one** of the following methods to deploy a dashboard. Examples below use the EKS dashboard, but the same steps apply to any dashboard in this repo — just swap the file path. The pinned-cluster dashboard is the exception: see [Using the pinned-cluster dashboard](#using-the-pinned-cluster-dashboard).

CloudWatch dashboards are [global](https://docs.aws.amazon.com/AmazonCloudWatch/latest/monitoring/create_dashboard.html), so it does not matter which region your console or AWS CLI is set to when you deploy. The region the charts read data from is chosen inside the dashboard.

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

**Clusters not in `us-east-1`?**

The dashboard opens on `us-east-1`. You can switch with the **Region** dropdown at any time, but you have to do it every time you open the dashboard. To make it open on your region instead, generate a copy with the helper script (requires a clone of this repo and [`jq`](https://jqlang.org/)) and deploy that copy. For example, for Asia Pacific (Tokyo):

```bash
scripts/set-default-region.sh ap-northeast-1 > /tmp/eks-control-plane-dashboard.json
aws cloudwatch put-dashboard \
  --dashboard-name <your-dashboard-name> \
  --dashboard-body file:///tmp/eks-control-plane-dashboard.json
```

## Using the pinned-cluster dashboard

Do not deploy or edit `eks/eks-control-plane-dashboard-pinned.json` directly. It is a template with sample cluster names. A script fills in your region and clusters and writes a new file; the template stays untouched.

Requirements: a clone of this repo, the [AWS CLI](https://aws.amazon.com/cli/), and [`jq`](https://jqlang.org/).

The examples below use Asia Pacific (Tokyo). Replace `ap-northeast-1` with the region your clusters run in, in **both** step 1 and step 2.

**Step 1 — Find your cluster names**

```bash
aws eks list-clusters --region ap-northeast-1
```

```json
{
    "clusters": [
        "my-prod-cluster",
        "my-staging-cluster"
    ]
}
```

**Step 2 — Generate your dashboard**

Pass the region first, then the cluster names you want in the dropdown. The first cluster is selected by default.

```bash
scripts/pin-clusters.sh ap-northeast-1 my-prod-cluster my-staging-cluster > /tmp/eks-pinned-dashboard.json
```

**Step 3 — Deploy it**

```bash
aws cloudwatch put-dashboard \
  --dashboard-name <your-dashboard-name> \
  --dashboard-body file:///tmp/eks-pinned-dashboard.json
```

An output of `"DashboardValidationMessages": []` means the dashboard was saved.

**Step 4 — Use it**

Open the dashboard in the CloudWatch console and pick a cluster from the **Cluster Name** dropdown. Every chart shows that cluster only.

To add or remove clusters later, repeat steps 2 and 3 with the same `--dashboard-name`. The existing dashboard is replaced.

**Troubleshooting**

| Symptom | Fix |
|---|---|
| All charts are empty | A cluster name is misspelled, or the region passed to the script is not the one the clusters run in. Re-run steps 2 and 3 with the region and names from step 1. |
| Only Node Count / Failed Node Count are empty | Install the CloudWatch Observability EKS add-on (Container Insights) on that cluster. |
| Clusters are in several regions | Run steps 2 and 3 once per region, each with a different `--dashboard-name`. |

## Notes

- The `region` and `ClusterName` values written in each widget (`us-east-1`, `placeholder`) are placeholders. The dashboard variables at the top replace them in every widget at render time.
- The threshold lines on the HTTP 5XX and 429 charts (value `5`, per 5-minute period) are starting points only. Tune them to your workload.

## License

Licensed under the MIT License. See [LICENSE](LICENSE) for details.
