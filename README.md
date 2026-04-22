# nuc-external-secrets

Helm chart for rendering [External Secrets Operator](https://external-secrets.io/) (ESO) custom resources.
Follows the [Nixys Universal Chart](https://github.com/nixys/nxs-universal-chart) subchart conventions
(`nuc-*`): pass-through `spec:` per item, per-kind `apiVersions:` overrides, `commonLabels`/`commonAnnotations`.

The chart **does not install the ESO operator**. Install the operator separately
(for example, via the official `external-secrets/external-secrets` chart) and use this chart to
declaratively manage the operator's CRD instances (`ExternalSecret`, `SecretStore`, etc.).

## Supported resources

| Kind                  | Scope       | Default apiVersion                    |
| --------------------- | ----------- | ------------------------------------- |
| `ExternalSecret`      | Namespaced  | `external-secrets.io/v1`              |
| `ClusterExternalSecret` | Cluster   | `external-secrets.io/v1`              |
| `SecretStore`         | Namespaced  | `external-secrets.io/v1`              |
| `ClusterSecretStore`  | Cluster     | `external-secrets.io/v1`              |
| `PushSecret`          | Namespaced  | `external-secrets.io/v1alpha1`         |
| `ClusterPushSecret`   | Cluster     | `external-secrets.io/v1alpha1`         |

Generators under `generators.external-secrets.io` are out of scope for the `1.0.x` line and may be
added in a future minor.

Tested against ESO `2.3.0` (`appVersion: "2.3.0"`).

## Values model

Every resource kind has:

- a dedicated plural map (`externalSecrets`, `clusterExternalSecrets`, `secretStores`,
  `clusterSecretStores`, `pushSecrets`, `clusterPushSecrets`) keyed by resource name;
- an `apiVersions.<kindCamel>` default that each entry can override via its `apiVersion` field;
- a `generic.<kindCamel>` block that is merged into each item's `spec` before rendering
  (per-item `spec` fields win).

Each map entry supports these optional fields:

| Field         | Purpose                                                               |
| ------------- | --------------------------------------------------------------------- |
| `namespace`   | Target namespace (namespaced kinds only; defaults to release namespace) |
| `labels`      | Extra labels, merged over chart labels and `commonLabels`             |
| `annotations` | Extra annotations, merged over `commonAnnotations`                    |
| `apiVersion`  | Override for a single resource                                        |
| `spec`        | Resource spec rendered as-is, merged on top of `generic.<kindCamel>`  |
| `status`      | Optional raw status (for fixtures and synthetic manifests)            |
| `enabled`     | If `false`, the entry is skipped                                      |

## The `generic:` block

`generic.<kindCamel>` holds cross-item `spec` defaults that are merged into every resource of the
matching kind via Helm's `mustMergeOverwrite` (per-item `spec` always wins).

Practical notes:

- Use this for scalar and map fields (`refreshInterval`, `secretStoreRef`, `target.*`,
  `target.template`, `deletionPolicy`, and so on).
- **Arrays are not merged.** `data`, `dataFrom`, `secretStoreRefs`, and similar lists are replaced
  wholesale if the item provides its own; only put array fields in the item, not in `generic`.
- The name and spirit follow the umbrella `nxs-universal-chart` `generic:` block. In the umbrella
  `generic:` is flat (labels, pod defaults, hook defaults, ...), while here it is keyed per-kind
  because this subchart renders several CRD kinds with different spec shapes.

## Usage

### Standalone

```bash
helm install my-secrets ./nuc-external-secrets -n apps -f my-values.yaml
```

### As a subchart of `nxs-universal-chart`

```yaml
# nxs-universal-chart Chart.yaml
dependencies:
  - name: nuc-external-secrets
    version: 1.0.0
    repository: oci://registry.nixys.ru/nuc
    condition: nuc-external-secrets.enabled
```

In the application values file the subchart is addressed by its chart name:

```yaml
# --- nxs-universal-chart parent values (deployment, ingress, etc.)
deployments:
  my-app:
    image: ghcr.io/example/my-app:1.2.3
    envSecrets:
      - secretName: my-app-secrets    # consumed by ESO-managed Secret

# --- nuc-external-secrets subchart values
nuc-external-secrets:
  enabled: true
  generic:
    externalSecret:
      refreshInterval: 1h
      secretStoreRef:
        name: vault
        kind: ClusterSecretStore
      target:
        creationPolicy: Owner
  externalSecrets:
    my-app-secrets:
      spec:
        data:
          - secretKey: DB_PASS
            remoteRef:
              key: kv/prod/my-app
              property: password
```

### Minimum item

With `generic.externalSecret` supplying `secretStoreRef` and other common fields, the shortest
ExternalSecret you can write is:

```yaml
externalSecrets:
  my-app-secrets:
    spec:
      data:
        - secretKey: DB_PASS
          remoteRef:
            key: kv/prod/my-app
            property: password
```

## Resource names

Every rendered resource gets `metadata.name = <releaseName>-<mapKey>` by default (same convention as
other `nuc-*` charts). To make names predictable and decoupled from the release name, set
`releasePrefix` — then `metadata.name = <releasePrefix>-<mapKey>`.

Keep this in mind when wiring cross-resource references: if `clusterSecretStores.vault` is
rendered here, its actual `metadata.name` will be `<releaseName>-vault`, and
`generic.externalSecret.secretStoreRef.name` must match that. In most real deployments the
`ClusterSecretStore` is a cluster-wide singleton installed separately from app charts, so consumers
reference it by its literal name without this chart's prefixing getting involved.

## Suppressing a default resource

Setting a map entry to `null` in a higher-precedence values file removes the lower-precedence
default. This is the standard Nixys subchart convention.

```yaml
externalSecrets:
  inherited-from-defaults: null
```

## Compatibility

| Chart version | ESO versions covered |
| ------------- | -------------------- |
| `1.0.x`       | ESO `0.10+` and `2.x` (CRDs under `external-secrets.io/v1`, PushSecret `v1beta1`) |

## Development

The `1.0.0` line ships without a full test harness (the Nixys `nuc-*` template with
`helm-unittest`, `kubeconform` smokes, and `kind` e2e) in the interest of landing a working
chart first. Each piece is tracked as a follow-up in `docs/TESTS.MD`.
