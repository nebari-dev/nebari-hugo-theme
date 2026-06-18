+++
title = 'Shared Storage'
description = "Configure shared persistent storage for model weights and data in a Nebari software pack."
+++

Model weights can be large. Loading them from object storage on every pod restart is slow. This guide explains how to attach shared persistent storage so weights are cached on the cluster and reused across pod restarts and replicas.

## Storage classes

Nebari clusters typically expose two storage classes:

| Class | Access mode | Use case |
| --- | --- | --- |
| `standard` | `ReadWriteOnce` | Single-replica deployments |
| `nebari-shared` | `ReadWriteMany` | Multi-replica, shared model cache |

Use `nebari-shared` for the model volume so all replicas read from the same cached weights.

## Configuring the PVC in values

```yaml
storage:
  modelCache:
    enabled: true
    storageClass: nebari-shared
    size: 50Gi
    accessMode: ReadWriteMany
    mountPath: /models
```

## Pre-populating the cache

Use a Kubernetes `Job` to download weights once before the main workload starts:

```bash
kubectl apply -f - <<EOF
apiVersion: batch/v1
kind: Job
metadata:
  name: model-prefetch
  namespace: nebari-llm
spec:
  template:
    spec:
      containers:
      - name: fetch
        image: ghcr.io/nebari-dev/model-fetch:latest
        env:
        - name: MODEL_ID
          value: "mistralai/Mistral-7B-Instruct-v0.2"
        volumeMounts:
        - name: model-cache
          mountPath: /models
      volumes:
      - name: model-cache
        persistentVolumeClaim:
          claimName: llm-serving-model-cache
      restartPolicy: OnFailure
EOF
```

## Verifying the mount

```bash
kubectl exec -n nebari-llm deploy/llm-serving -- ls /models
```

You should see the model directory once the prefetch job completes.
