+++
title = 'Architecture'
description = "How the llm-serving Nebari software pack fits into a Nebari cluster."
+++

This page describes the runtime architecture of the `llm-serving` pack: how it wires into Nebari's authentication, ingress, and service-discovery layers.

## High-level overview

The pack deploys three workloads inside the `nebari-llm` namespace:

1. **Inference server** - a vLLM process that loads the model and exposes an OpenAI-compatible HTTP API.
2. **Key manager** - a small sidecar that mints short-lived API keys scoped to the requesting JupyterHub user.
3. **Proxy** - an Envoy instance that authenticates requests via Keycloak and routes them to the inference server.

```
JupyterHub user
      |
      | HTTPS (Keycloak JWT)
      v
  [Nebari ingress]
      |
      v
  [Envoy proxy]  <--- validates JWT with Keycloak
      |
      v
  [vLLM server]  <--- /v1/chat/completions
      |
      v
  [GPU node]
```

## Authentication flow

All requests must carry a valid Keycloak JWT. The Envoy proxy validates the token on every request; no token reaches the inference server unauthenticated.

```yaml
# envoy filter (excerpt from values.yaml)
auth:
  provider: keycloak
  realm: nebari
  clientId: llm-serving
  requiredRoles:
    - llm-user
```

{{< callout type="note" >}}
Users who are not in the `llm-user` Keycloak role will receive a `403 Forbidden` before their request reaches the GPU. Assign roles in the Keycloak admin console under **Clients > llm-serving > Roles**.
{{< /callout >}}

## Ingress and routing

The pack creates an `Ingress` resource that attaches to the same Nginx controller Nebari uses for JupyterHub. The path prefix is configurable:

```yaml
ingress:
  pathPrefix: /llm-serving
  annotations:
    nginx.ingress.kubernetes.io/proxy-read-timeout: "600"
    nginx.ingress.kubernetes.io/proxy-send-timeout: "600"
```

{{< callout type="warning" >}}
The default proxy timeouts (60 s) are too short for large model responses. Always override them as shown above, or streaming completions will be cut off mid-response.
{{< /callout >}}

## NebariApp CRD integration

When `nebariApp.enabled = true` the chart creates a `NebariApp` custom resource. Nebari's controller watches for these and injects a tile into the JupyterHub service panel automatically - no manual JupyterHub configuration needed.

```yaml
apiVersion: nebari.dev/v1alpha1
kind: NebariApp
metadata:
  name: llm-serving
  namespace: nebari-llm
spec:
  displayName: "LLM Serving"
  description: "OpenAI-compatible inference"
  url: "https://llm.example.nebari.dev"
  healthCheck:
    path: /healthz
    expectedStatus: 200
```

## GPU scheduling

The inference server pod requests GPU resources via standard Kubernetes extended resources. Nebari's GPU node pool uses the NVIDIA device plugin to advertise `nvidia.com/gpu` capacity.

```yaml
resources:
  limits:
    nvidia.com/gpu: 1
    memory: 40Gi
  requests:
    nvidia.com/gpu: 1
    memory: 40Gi
```

{{< callout type="tip" title="Multi-GPU serving" >}}
Set `model.tensorParallelSize` to the number of GPUs and increase `resources.limits.nvidia.com/gpu` to match. vLLM splits the model across devices using tensor parallelism automatically.
{{< /callout >}}

## Persistence and model loading

Model weights are stored on a `ReadWriteMany` PVC so all replicas share the same cache. On first start the init container downloads the weights from Hugging Face Hub; subsequent starts skip the download if the cache directory is present.

See [Shared Storage](../shared-storage/) for PVC configuration details.
