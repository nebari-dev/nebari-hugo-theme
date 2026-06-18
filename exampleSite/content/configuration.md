+++
title = 'Configuration'
description = "Full values reference for the llm-serving Nebari software pack Helm chart."
+++

This page documents every top-level key in the `values.yaml` for the `llm-serving` pack. Override any value by passing `--set key=value` to `helm install/upgrade`, or by providing a custom `values.yaml`.

## Top-level keys

| Key | Type | Default | Description |
| --- | --- | --- | --- |
| `replicaCount` | int | `1` | Number of serving replicas |
| `image.repository` | string | `ghcr.io/nebari-dev/llm-serving` | Container image |
| `image.tag` | string | `""` (chart appVersion) | Image tag override |
| `resources.limits.cpu` | string | `"4"` | CPU limit per pod |
| `resources.limits.memory` | string | `"16Gi"` | Memory limit per pod |
| `storage.modelCache.size` | string | `"20Gi"` | PVC size for model weights |
| `nebariApp.enabled` | bool | `true` | Register with NebariApp CRD |
| `nebariApp.hostname` | string | `""` | Ingress hostname (required) |

## Model configuration

```yaml
model:
  id: "mistralai/Mistral-7B-Instruct-v0.2"
  dtype: "bfloat16"
  maxModelLen: 8192
  quantization: ""       # awq | gptq | leave blank for none
  tensorParallelSize: 1  # set to number of GPUs for multi-GPU
```

## Autoscaling

```yaml
autoscaling:
  enabled: false
  minReplicas: 1
  maxReplicas: 4
  targetCPUUtilizationPercentage: 70
```

## NebariApp integration

When `nebariApp.enabled` is `true`, the chart creates a `NebariApp` custom resource that registers the service on the JupyterHub landing page:

```yaml
nebariApp:
  enabled: true
  hostname: llm.example.nebari.dev
  displayName: "LLM Serving"
  description: "OpenAI-compatible inference endpoint"
  logoURL: ""
```
