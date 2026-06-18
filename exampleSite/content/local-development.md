+++
title = 'Local Development'
description = "Develop and test Nebari software packs locally before deploying to a cluster."
+++

You can develop and iterate on a Nebari software pack without a full Nebari cluster by using a local Kubernetes environment. This guide covers the recommended local workflow.

## Tooling

Install the following before starting:

- [Docker Desktop](https://www.docker.com/products/docker-desktop/) or [Rancher Desktop](https://rancherdesktop.io/)
- [kind](https://kind.sigs.k8s.io/) or [k3d](https://k3d.io/) for lightweight clusters
- `helm` v3.10+
- `nebari-pack` CLI (optional but recommended)

## Spin up a local cluster

```bash
# kind
kind create cluster --name pack-dev

# k3d (lighter, faster)
k3d cluster create pack-dev --agents 2
```

## Mount the chart under development

Use a local chart path instead of the registry:

```bash
helm install llm-serving ./charts/llm-serving \
  --namespace nebari-llm \
  --create-namespace \
  --values dev-values.yaml
```

## Hot-reload template changes

While iterating on Helm templates, use `helm upgrade` with `--atomic` to roll back automatically on failure:

```bash
helm upgrade llm-serving ./charts/llm-serving \
  --namespace nebari-llm \
  --values dev-values.yaml \
  --atomic
```

## Running tests locally

The pack ships with a suite of chart-level tests:

```bash
helm test llm-serving -n nebari-llm
```

Unit-test templates with `helm unittest`:

```bash
helm unittest charts/llm-serving
```

## Tear down

```bash
kind delete cluster --name pack-dev
# or
k3d cluster delete pack-dev
```
