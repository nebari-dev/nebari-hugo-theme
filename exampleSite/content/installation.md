+++
title = 'Installation'
description = "Full installation instructions for Nebari software packs, including prerequisites and cluster configuration."
+++

This page covers production-grade installation of a Nebari software pack. For a faster path, see [Quickstart](../quickstart/).

## System requirements

| Component | Minimum | Recommended |
| --- | --- | --- |
| Kubernetes | 1.26 | 1.29+ |
| Nebari | 0.4.3 | latest |
| Helm | 3.10 | 3.14+ |
| Node RAM | 8 GB | 32 GB+ (GPU) |
| Storage | 20 GB PVC | 100 GB PVC |

## Pre-flight checks

Run the Nebari pack preflight script to validate cluster readiness:

```bash
curl -sSL https://raw.githubusercontent.com/nebari-dev/nebari-packs/main/scripts/preflight.sh | bash
```

The script checks:
- Kubernetes version compatibility
- Required CRDs (`NebariApp`, `NebariSecret`) are installed
- Storage class availability
- GPU node pool presence (if applicable)

## Helm installation

### Minimal install

```bash
helm install llm-serving nebari-packs/llm-serving \
  --namespace nebari-llm \
  --create-namespace
```

### With a custom values file

```bash
helm install llm-serving nebari-packs/llm-serving \
  --namespace nebari-llm \
  --create-namespace \
  --values values.yaml \
  --wait
```

## Post-install verification

```bash
kubectl get nebariapp -n nebari-llm
kubectl get pods -n nebari-llm
```

All pods should reach `Running` status within a few minutes. If a pod stays in `Pending`, check node resources with `kubectl describe pod <pod-name> -n nebari-llm`.

## Uninstalling

```bash
helm uninstall llm-serving -n nebari-llm
kubectl delete namespace nebari-llm
```

> Deleting the namespace removes all persistent volume claims. Back up any model weights or configuration before uninstalling.
