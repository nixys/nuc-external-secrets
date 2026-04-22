# NUC External Secrets

[![Artifact Hub](https://img.shields.io/endpoint?url=https://artifacthub.io/badge/repository/nuc-external-secrets)](https://artifacthub.io/packages/search?repo=nuc-external-secrets)

Helm chart for rendering [External Secrets Operator](https://external-secrets.io/) (ESO) custom resources from declarative values.

The chart **does not install ESO or its CRDs**. Install the operator separately (for example, via the official `external-secrets/external-secrets` chart) and use this chart to declaratively manage the operator's CRD instances.

## Quick Start

```bash
helm install nuc-external-secrets oci://registry.nixys.ru/nuc/nuc-external-secrets \
  --namespace external-secrets \
  --create-namespace \
  -f my-values.yaml
```

## Supported Resources

### Core resources (`external-secrets.io`)

| Kind | Scope | Values key | Default apiVersion |
| ---- | ----- | ---------- | ------------------ |
| `ExternalSecret` | Namespaced | `externalSecrets` | `external-secrets.io/v1` |
| `ClusterExternalSecret` | Cluster | `clusterExternalSecrets` | `external-secrets.io/v1` |
| `SecretStore` | Namespaced | `secretStores` | `external-secrets.io/v1` |
| `ClusterSecretStore` | Cluster | `clusterSecretStores` | `external-secrets.io/v1` |
| `PushSecret` | Namespaced | `pushSecrets` | `external-secrets.io/v1alpha1` |
| `ClusterPushSecret` | Cluster | `clusterPushSecrets` | `external-secrets.io/v1alpha1` |

### Generator resources (`generators.external-secrets.io`)

| Kind | Scope | Values key | Default apiVersion |
| ---- | ----- | ---------- | ------------------ |
| `ACRAccessToken` | Namespaced | `acrAccessTokens` | `generators.external-secrets.io/v1alpha1` |
| `CloudsmithAccessToken` | Namespaced | `cloudsmithAccessTokens` | `generators.external-secrets.io/v1alpha1` |
| `ClusterGenerator` | Cluster | `clusterGenerators` | `generators.external-secrets.io/v1alpha1` |
| `ECRAuthorizationToken` | Namespaced | `ecrAuthorizationTokens` | `generators.external-secrets.io/v1alpha1` |
| `Fake` | Namespaced | `fakes` | `generators.external-secrets.io/v1alpha1` |
| `GCRAccessToken` | Namespaced | `gcrAccessTokens` | `generators.external-secrets.io/v1alpha1` |
| `GeneratorState` | Namespaced | `generatorStates` | `generators.external-secrets.io/v1alpha1` |
| `GithubAccessToken` | Namespaced | `githubAccessTokens` | `generators.external-secrets.io/v1alpha1` |
| `Grafana` | Namespaced | `grafanas` | `generators.external-secrets.io/v1alpha1` |
| `MFA` | Namespaced | `mfas` | `generators.external-secrets.io/v1alpha1` |
| `Password` | Namespaced | `passwords` | `generators.external-secrets.io/v1alpha1` |
| `QuayAccessToken` | Namespaced | `quayAccessTokens` | `generators.external-secrets.io/v1alpha1` |
| `SSHKey` | Namespaced | `sshKeys` | `generators.external-secrets.io/v1alpha1` |
| `STSSessionToken` | Namespaced | `stsSessionTokens` | `generators.external-secrets.io/v1alpha1` |
| `UUID` | Namespaced | `uuids` | `generators.external-secrets.io/v1alpha1` |
| `VaultDynamicSecret` | Namespaced | `vaultDynamicSecrets` | `generators.external-secrets.io/v1alpha1` |
| `Webhook` | Namespaced | `webhooks` | `generators.external-secrets.io/v1alpha1` |

## Values Model

Every resource kind has:

- a **dedicated plural map** (see _Values key_ column above) keyed by resource name;
- an **`apiVersions.<kindCamel>`** default that each entry can override via its `apiVersion` field;
- a **`generic.<kindCamel>`** block that is merged into each item's `spec` before rendering
  (per-item `spec` fields always win).

Each map entry supports these optional fields:

| Field | Purpose |
| ----- | ------- |
| `namespace` | Target namespace (namespaced kinds only; defaults to release namespace) |
| `labels` | Extra labels, merged over chart labels and `commonLabels` |
| `annotations` | Extra annotations, merged over `commonAnnotations` |
| `apiVersion` | Per-resource apiVersion override |
| `spec` | Resource spec rendered as-is, merged on top of `generic.<kindCamel>` |
| `status` | Optional raw status (for fixtures and synthetic manifests) |
| `enabled` | If `false`, the entry is skipped |

Setting a map entry to `null` suppresses an inherited lower-precedence default (standard Nixys subchart convention).

Global controls: `nameOverride`, `releasePrefix`, `commonLabels`, `commonAnnotations`, `global`, `apiVersions.*`.

The values contract is validated by [values.schema.json](values.schema.json).

## The `generic:` Block

`generic.<kindCamel>` holds cross-item `spec` defaults merged into every resource of the matching kind via Helm's `mustMergeOverwrite`. Per-item `spec` always wins.

Practical notes:

- Use for scalar and map fields (`refreshInterval`, `secretStoreRef`, `target.*`, `deletionPolicy`, `length`, …).
- **Arrays are not merged.** `data`, `dataFrom`, `secretStoreRefs`, and similar lists are replaced wholesale by the item's own value; put array fields in the item, not in `generic`.

## Usage

### Standalone

```bash
helm install my-secrets ./nuc-external-secrets -n apps -f my-values.yaml
```

### As a subchart of `nxs-universal-chart`

```yaml
# Chart.yaml
dependencies:
  - name: nuc-external-secrets
    version: ">=1.0.0"
    repository: oci://registry.nixys.ru/nuc
    condition: nuc-external-secrets.enabled
```

```yaml
# values.yaml
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

### Generator example

Generate a random password and reference it from an ExternalSecret:

```yaml
passwords:
  app-password:
    spec:
      length: 32
      digits: 8
      symbols: 4
      symbolCharacters: "-_$@"
      noUpper: false

externalSecrets:
  app-secrets:
    spec:
      refreshInterval: 1h
      sourceRef:
        generatorRef:
          apiVersion: generators.external-secrets.io/v1alpha1
          kind: Password
          name: <release-name>-app-password
      target:
        creationPolicy: Owner
```

## Resource Names

Every rendered resource gets `metadata.name = <releaseName>-<mapKey>` by default. To decouple names from the release name, set `releasePrefix` — then `metadata.name = <releasePrefix>-<mapKey>`.

## Helm Values

This section is generated from [values.yaml](values.yaml) by `helm-docs`. Edit [values.yaml](values.yaml) comments or [docs/README.md.gotmpl](docs/README.md.gotmpl), then run `pre-commit run helm-docs --all-files` or `make docs`.

| Key | Type | Default | Description |
|-----|------|---------|-------------|
| acrAccessTokens | object | {} | ACRAccessToken resources keyed by resource name. |
| apiVersions.acrAccessToken | string | `"generators.external-secrets.io/v1alpha1"` | Default apiVersion for ACRAccessToken resources. |
| apiVersions.cloudsmithAccessToken | string | `"generators.external-secrets.io/v1alpha1"` | Default apiVersion for CloudsmithAccessToken resources. |
| apiVersions.clusterExternalSecret | string | `"external-secrets.io/v1"` | Default apiVersion for ClusterExternalSecret resources. |
| apiVersions.clusterGenerator | string | `"generators.external-secrets.io/v1alpha1"` | Default apiVersion for ClusterGenerator resources. |
| apiVersions.clusterPushSecret | string | `"external-secrets.io/v1alpha1"` | Default apiVersion for ClusterPushSecret resources. |
| apiVersions.clusterSecretStore | string | `"external-secrets.io/v1"` | Default apiVersion for ClusterSecretStore resources. |
| apiVersions.ecrAuthorizationToken | string | `"generators.external-secrets.io/v1alpha1"` | Default apiVersion for ECRAuthorizationToken resources. |
| apiVersions.externalSecret | string | `"external-secrets.io/v1"` | Default apiVersion for ExternalSecret resources. |
| apiVersions.fake | string | `"generators.external-secrets.io/v1alpha1"` | Default apiVersion for Fake resources. |
| apiVersions.gcrAccessToken | string | `"generators.external-secrets.io/v1alpha1"` | Default apiVersion for GCRAccessToken resources. |
| apiVersions.generatorState | string | `"generators.external-secrets.io/v1alpha1"` | Default apiVersion for GeneratorState resources. |
| apiVersions.githubAccessToken | string | `"generators.external-secrets.io/v1alpha1"` | Default apiVersion for GithubAccessToken resources. |
| apiVersions.grafana | string | `"generators.external-secrets.io/v1alpha1"` | Default apiVersion for Grafana resources. |
| apiVersions.mfa | string | `"generators.external-secrets.io/v1alpha1"` | Default apiVersion for MFA resources. |
| apiVersions.password | string | `"generators.external-secrets.io/v1alpha1"` | Default apiVersion for Password resources. |
| apiVersions.pushSecret | string | `"external-secrets.io/v1alpha1"` | Default apiVersion for PushSecret resources. |
| apiVersions.quayAccessToken | string | `"generators.external-secrets.io/v1alpha1"` | Default apiVersion for QuayAccessToken resources. |
| apiVersions.secretStore | string | `"external-secrets.io/v1"` | Default apiVersion for SecretStore resources. |
| apiVersions.sshKey | string | `"generators.external-secrets.io/v1alpha1"` | Default apiVersion for SSHKey resources. |
| apiVersions.stsSessionToken | string | `"generators.external-secrets.io/v1alpha1"` | Default apiVersion for STSSessionToken resources. |
| apiVersions.uuid | string | `"generators.external-secrets.io/v1alpha1"` | Default apiVersion for UUID resources. |
| apiVersions.vaultDynamicSecret | string | `"generators.external-secrets.io/v1alpha1"` | Default apiVersion for VaultDynamicSecret resources. |
| apiVersions.webhook | string | `"generators.external-secrets.io/v1alpha1"` | Default apiVersion for Webhook resources. |
| cloudsmithAccessTokens | object | {} | CloudsmithAccessToken resources keyed by resource name. |
| clusterExternalSecrets | object | {} | ClusterExternalSecret resources keyed by resource name. |
| clusterExternalSecrets.__helm_docs_example__.labels | object | `{}` | Cluster-scoped: namespace is ignored. |
| clusterGenerators | object | {} | ClusterGenerator resources keyed by resource name. |
| clusterPushSecrets | object | {} | ClusterPushSecret resources keyed by resource name. |
| clusterSecretStores | object | {} | ClusterSecretStore resources keyed by resource name. |
| commonAnnotations | object | `{}` | Extra annotations applied to every rendered resource. |
| commonLabels | object | `{}` | Extra labels applied to every rendered resource. |
| ecrAuthorizationTokens | object | {} | ECRAuthorizationToken resources keyed by resource name. |
| enabled | bool | `true` | Enable nuc-external-secrets chart rendering. |
| externalSecrets | object | {} | ExternalSecret resources keyed by resource name. |
| externalSecrets.__helm_docs_example__.annotations | object | `{}` | Resource-specific annotations. |
| externalSecrets.__helm_docs_example__.apiVersion | string | apiVersions.externalSecret | Per-resource apiVersion override. |
| externalSecrets.__helm_docs_example__.labels | object | `{}` | Resource-specific labels. |
| externalSecrets.__helm_docs_example__.namespace | string | release namespace | Namespace for the ExternalSecret. Defaults to the Helm release namespace. |
| externalSecrets.__helm_docs_example__.spec | object | `{}` | Resource spec rendered as-is, merged on top of generic.externalSecret. |
| externalSecrets.__helm_docs_example__.status | object | `{}` | Optional resource status rendered as-is. |
| fakes | object | {} | Fake resources keyed by resource name. |
| gcrAccessTokens | object | {} | GCRAccessToken resources keyed by resource name. |
| generatorStates | object | {} | GeneratorState resources keyed by resource name. |
| generic.acrAccessToken | object | `{}` | Default spec fragment merged into every ACRAccessToken. |
| generic.cloudsmithAccessToken | object | `{}` | Default spec fragment merged into every CloudsmithAccessToken. |
| generic.clusterExternalSecret | object | `{}` | Default spec fragment merged into every ClusterExternalSecret. |
| generic.clusterGenerator | object | `{}` | Default spec fragment merged into every ClusterGenerator. |
| generic.clusterPushSecret | object | `{}` | Default spec fragment merged into every ClusterPushSecret. |
| generic.clusterSecretStore | object | `{}` | Default spec fragment merged into every ClusterSecretStore. |
| generic.ecrAuthorizationToken | object | `{}` | Default spec fragment merged into every ECRAuthorizationToken. |
| generic.externalSecret | object | `{}` | Default spec fragment merged into every ExternalSecret. |
| generic.fake | object | `{}` | Default spec fragment merged into every Fake. |
| generic.gcrAccessToken | object | `{}` | Default spec fragment merged into every GCRAccessToken. |
| generic.generatorState | object | `{}` | Default spec fragment merged into every GeneratorState. |
| generic.githubAccessToken | object | `{}` | Default spec fragment merged into every GithubAccessToken. |
| generic.grafana | object | `{}` | Default spec fragment merged into every Grafana. |
| generic.mfa | object | `{}` | Default spec fragment merged into every MFA. |
| generic.password | object | `{}` | Default spec fragment merged into every Password. |
| generic.pushSecret | object | `{}` | Default spec fragment merged into every PushSecret. |
| generic.quayAccessToken | object | `{}` | Default spec fragment merged into every QuayAccessToken. |
| generic.secretStore | object | `{}` | Default spec fragment merged into every SecretStore. |
| generic.sshKey | object | `{}` | Default spec fragment merged into every SSHKey. |
| generic.stsSessionToken | object | `{}` | Default spec fragment merged into every STSSessionToken. |
| generic.uuid | object | `{}` | Default spec fragment merged into every UUID. |
| generic.vaultDynamicSecret | object | `{}` | Default spec fragment merged into every VaultDynamicSecret. |
| generic.webhook | object | `{}` | Default spec fragment merged into every Webhook. |
| githubAccessTokens | object | {} | GithubAccessToken resources keyed by resource name. |
| global | object | `{}` | Compatibility values inherited from umbrella charts. Accepted but ignored by this chart. |
| grafanas | object | {} | Grafana resources keyed by resource name. |
| mfas | object | {} | MFA resources keyed by resource name. |
| nameOverride | string | `""` | Override the default chart label name if needed. |
| passwords | object | {} | Password resources keyed by resource name. |
| pushSecrets | object | {} | PushSecret resources keyed by resource name. |
| quayAccessTokens | object | {} | QuayAccessToken resources keyed by resource name. |
| releasePrefix | string | `""` | Optional release prefix used for generated names. |
| secretStores | object | {} | SecretStore resources keyed by resource name. |
| sshKeys | object | {} | SSHKey resources keyed by resource name. |
| stsSessionTokens | object | {} | STSSessionToken resources keyed by resource name. |
| uuids | object | {} | UUID resources keyed by resource name. |
| vaultDynamicSecrets | object | {} | VaultDynamicSecret resources keyed by resource name. |
| webhooks | object | {} | Webhook resources keyed by resource name. |

## Included Values Files

- [values.yaml](values.yaml): minimal defaults that render no resources.
- [values.yaml.example](values.yaml.example): example values covering the core resource kinds.

## Testing

```bash
helm lint . -f values.yaml.example
helm template my-release . -f values.yaml.example
helm unittest -f 'tests/units/*_test.yaml' .
sh tests/units/backward_compatibility_test.sh
python3 tests/smokes/run/smoke.py
make test-smoke-fast
```
