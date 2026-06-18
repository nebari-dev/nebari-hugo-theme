+++
title = 'Quickstart'
description = "Get a Nebari software pack running in under ten minutes."
+++

This guide walks you through deploying a sample Nebari software pack on an existing Nebari cluster. By the end you will have a running service accessible from the JupyterHub interface.

## Prerequisites

Before you begin, confirm you have:

- A running Nebari cluster (v0.4.3 or later)
- `kubectl` configured to reach the cluster
- `helm` v3.10 or later installed locally
- Cluster-admin or namespace-admin privileges

## Deploy the pack

Add the Nebari pack registry and install the chart:

```bash
helm repo add nebari-packs https://nebari-dev.github.io/nebari-packs
helm repo update

helm install my-llm-pack nebari-packs/llm-serving \
  --namespace nebari-llm \
  --create-namespace \
  --values my-values.yaml
```

Watch the rollout until all pods are `Running`:

```bash
kubectl rollout status deployment/my-llm-pack -n nebari-llm
```

## Verify the deployment

Once the pods are healthy, open JupyterHub and look for the new tile in the Services section. Click it to open the API playground.

You can also hit the health endpoint directly:

```bash
curl https://<your-nebari-host>/my-llm-pack/healthz
# {"status":"ok"}
```

## Next steps

- Read the [Installation](../installation/) guide for production-ready configuration options.
- See [Configuration](../configuration/) for the full values reference.
