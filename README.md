# NUC External Secrets

[![Artifact Hub](https://img.shields.io/endpoint?url=https://artifacthub.io/badge/repository/nuc-external-secrets)](https://artifacthub.io/packages/search?repo=nuc-external-secrets)

Helm chart for rendering External Secrets Operator resources and generator CRs from declarative values.

The chart does not install External Secrets Operator CRDs or the operator itself. It renders the custom resources defined in [`config/crds/bases`](https://github.com/external-secrets/external-secrets/tree/main/config/crds/bases) and expects those CRDs to be available in the target cluster.

## Quick Start

Install the chart:

```bash
helm install nuc-external-secrets oci://registry.nixys.ru/nuc/nuc-external-secrets   --namespace external-secrets   --create-namespace
```

Install the local README generator hook:

```bash
pre-commit install
pre-commit install-hooks
```

## Supported Resources

- `ClusterExternalSecret`
- `ClusterPushSecret`
- `ClusterSecretStore`
- `ExternalSecret`
- `PushSecret`
- `SecretStore`
- `ACRAccessToken`
- `CloudsmithAccessToken`
- `ClusterGenerator`
- `ECRAuthorizationToken`
- `Fake`
- `GCRAccessToken`
- `GeneratorState`
- `GithubAccessToken`
- `Grafana`
- `MFA`
- `Password`
- `QuayAccessToken`
- `SSHKey`
- `STSSessionToken`
- `UUID`
- `VaultDynamicSecret`
- `Webhook`

## Values Model

The chart exposes one keyed map per supported resource kind. Each map entry becomes one rendered custom resource where the map key is used as `metadata.name`.

Every resource map uses the same generic contract:

- `namespace` for namespaced resources (ignored for cluster-scoped resources)
- `labels`
- `annotations`
- `apiVersion`
- `spec`
- `status`

Global controls:

- `nameOverride`
- `releasePrefix`
- `commonLabels`
- `commonAnnotations`
- `global`
- `apiVersions.*`

The values contract is validated by [values.schema.json](values.schema.json).

## Helm Values

This section is generated from [values.yaml](values.yaml) by `helm-docs`. Edit [values.yaml](values.yaml) comments or [docs/README.md.gotmpl](docs/README.md.gotmpl), then run `pre-commit run helm-docs --all-files` or `make docs`.

| Key | Type | Default | Description |
|-----|------|---------|-------------|
| acrAccessTokens | object | `{"__helm_docs_example__":{"annotations":{},"apiVersion":"generators.external-secrets.io/v1alpha1","labels":{},"namespace":"documentation-placeholder","spec":{"auth":{"managedIdentity":{"identityId":"documentation-placeholder"}},"registry":"registry.azurecr.io","scope":"repository:demo:pull"},"status":{}}}` | ACRAccessToken resources keyed by resource name. |
| acrAccessTokens.__helm_docs_example__.annotations | object | `{}` | Resource-specific annotations. |
| acrAccessTokens.__helm_docs_example__.apiVersion | string | `"generators.external-secrets.io/v1alpha1"` | Per-resource apiVersion override. |
| acrAccessTokens.__helm_docs_example__.labels | object | `{}` | Resource-specific labels. |
| acrAccessTokens.__helm_docs_example__.namespace | string | `"documentation-placeholder"` | Namespace for the ACRAccessToken resource. Defaults to the Helm release namespace. |
| acrAccessTokens.__helm_docs_example__.spec | object | `{"auth":{"managedIdentity":{"identityId":"documentation-placeholder"}},"registry":"registry.azurecr.io","scope":"repository:demo:pull"}` | Resource spec rendered as-is. |
| acrAccessTokens.__helm_docs_example__.status | object | `{}` | Optional resource status rendered as-is. |
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
| cloudsmithAccessTokens | object | `{"__helm_docs_example__":{"annotations":{},"apiVersion":"generators.external-secrets.io/v1alpha1","labels":{},"namespace":"documentation-placeholder","spec":{"apiUrl":"https://api.cloudsmith.io","orgSlug":"documentation-placeholder","serviceAccountRef":{"name":"documentation-placeholder"},"serviceSlug":"documentation-placeholder"},"status":{}}}` | CloudsmithAccessToken resources keyed by resource name. |
| cloudsmithAccessTokens.__helm_docs_example__.annotations | object | `{}` | Resource-specific annotations. |
| cloudsmithAccessTokens.__helm_docs_example__.apiVersion | string | `"generators.external-secrets.io/v1alpha1"` | Per-resource apiVersion override. |
| cloudsmithAccessTokens.__helm_docs_example__.labels | object | `{}` | Resource-specific labels. |
| cloudsmithAccessTokens.__helm_docs_example__.namespace | string | `"documentation-placeholder"` | Namespace for the CloudsmithAccessToken resource. Defaults to the Helm release namespace. |
| cloudsmithAccessTokens.__helm_docs_example__.spec | object | `{"apiUrl":"https://api.cloudsmith.io","orgSlug":"documentation-placeholder","serviceAccountRef":{"name":"documentation-placeholder"},"serviceSlug":"documentation-placeholder"}` | Resource spec rendered as-is. |
| cloudsmithAccessTokens.__helm_docs_example__.status | object | `{}` | Optional resource status rendered as-is. |
| clusterExternalSecrets | object | `{"__helm_docs_example__":{"annotations":{},"apiVersion":"external-secrets.io/v1","labels":{},"namespace":"documentation-placeholder","spec":{"externalSecretName":"documentation-placeholder","externalSecretSpec":{"data":[{"remoteRef":{"key":"apps/demo","property":"username"},"secretKey":"username"}],"refreshInterval":"1h","secretStoreRef":{"kind":"SecretStore","name":"documentation-placeholder"},"target":{"creationPolicy":"Owner","name":"documentation-placeholder"}},"namespaceSelectors":[{"matchLabels":{"tenant":"demo"}}]},"status":{"failedNamespaces":[]}}}` | ClusterExternalSecret resources keyed by resource name. |
| clusterExternalSecrets.__helm_docs_example__.annotations | object | `{}` | Resource-specific annotations. |
| clusterExternalSecrets.__helm_docs_example__.apiVersion | string | `"external-secrets.io/v1"` | Per-resource apiVersion override. |
| clusterExternalSecrets.__helm_docs_example__.labels | object | `{}` | Resource-specific labels. |
| clusterExternalSecrets.__helm_docs_example__.namespace | string | `"documentation-placeholder"` | Optional namespace field kept for contract symmetry. Ignored for cluster-scoped ClusterExternalSecret resources. |
| clusterExternalSecrets.__helm_docs_example__.spec | object | `{"externalSecretName":"documentation-placeholder","externalSecretSpec":{"data":[{"remoteRef":{"key":"apps/demo","property":"username"},"secretKey":"username"}],"refreshInterval":"1h","secretStoreRef":{"kind":"SecretStore","name":"documentation-placeholder"},"target":{"creationPolicy":"Owner","name":"documentation-placeholder"}},"namespaceSelectors":[{"matchLabels":{"tenant":"demo"}}]}` | Resource spec rendered as-is. |
| clusterExternalSecrets.__helm_docs_example__.status | object | `{"failedNamespaces":[]}` | Optional resource status rendered as-is. |
| clusterGenerators | object | `{"__helm_docs_example__":{"annotations":{},"apiVersion":"generators.external-secrets.io/v1alpha1","labels":{},"namespace":"documentation-placeholder","spec":{"generator":{"passwordSpec":{"digits":8,"length":32,"symbolCharacters":"!@#$%","symbols":4}}},"status":{}}}` | ClusterGenerator resources keyed by resource name. |
| clusterGenerators.__helm_docs_example__.annotations | object | `{}` | Resource-specific annotations. |
| clusterGenerators.__helm_docs_example__.apiVersion | string | `"generators.external-secrets.io/v1alpha1"` | Per-resource apiVersion override. |
| clusterGenerators.__helm_docs_example__.labels | object | `{}` | Resource-specific labels. |
| clusterGenerators.__helm_docs_example__.namespace | string | `"documentation-placeholder"` | Optional namespace field kept for contract symmetry. Ignored for cluster-scoped ClusterGenerator resources. |
| clusterGenerators.__helm_docs_example__.spec | object | `{"generator":{"passwordSpec":{"digits":8,"length":32,"symbolCharacters":"!@#$%","symbols":4}}}` | Resource spec rendered as-is. |
| clusterGenerators.__helm_docs_example__.status | object | `{}` | Optional resource status rendered as-is. |
| clusterPushSecrets | object | `{"__helm_docs_example__":{"annotations":{},"apiVersion":"external-secrets.io/v1alpha1","labels":{},"namespace":"documentation-placeholder","spec":{"namespaceSelectors":[{"matchLabels":{"tenant":"demo"}}],"pushSecretSpec":{"data":[{"match":{"secretKey":"token"},"remoteRef":{"remoteKey":"providers/demo"}}],"refreshInterval":"1h","secretStoreRefs":[{"kind":"SecretStore","name":"documentation-placeholder"}],"selector":{"secret":{"name":"documentation-placeholder"}}}},"status":{"failedNamespaces":[]}}}` | ClusterPushSecret resources keyed by resource name. |
| clusterPushSecrets.__helm_docs_example__.annotations | object | `{}` | Resource-specific annotations. |
| clusterPushSecrets.__helm_docs_example__.apiVersion | string | `"external-secrets.io/v1alpha1"` | Per-resource apiVersion override. |
| clusterPushSecrets.__helm_docs_example__.labels | object | `{}` | Resource-specific labels. |
| clusterPushSecrets.__helm_docs_example__.namespace | string | `"documentation-placeholder"` | Optional namespace field kept for contract symmetry. Ignored for cluster-scoped ClusterPushSecret resources. |
| clusterPushSecrets.__helm_docs_example__.spec | object | `{"namespaceSelectors":[{"matchLabels":{"tenant":"demo"}}],"pushSecretSpec":{"data":[{"match":{"secretKey":"token"},"remoteRef":{"remoteKey":"providers/demo"}}],"refreshInterval":"1h","secretStoreRefs":[{"kind":"SecretStore","name":"documentation-placeholder"}],"selector":{"secret":{"name":"documentation-placeholder"}}}}` | Resource spec rendered as-is. |
| clusterPushSecrets.__helm_docs_example__.status | object | `{"failedNamespaces":[]}` | Optional resource status rendered as-is. |
| clusterSecretStores | object | `{"__helm_docs_example__":{"annotations":{},"apiVersion":"external-secrets.io/v1","labels":{},"namespace":"documentation-placeholder","spec":{"provider":{"webhook":{"result":{"jsonPath":"$.data"},"url":"https://provider.example/api"}},"retrySettings":{"maxRetries":3,"retryInterval":"10s"}},"status":{"conditions":[{"status":"True","type":"Ready"}]}}}` | ClusterSecretStore resources keyed by resource name. |
| clusterSecretStores.__helm_docs_example__.annotations | object | `{}` | Resource-specific annotations. |
| clusterSecretStores.__helm_docs_example__.apiVersion | string | `"external-secrets.io/v1"` | Per-resource apiVersion override. |
| clusterSecretStores.__helm_docs_example__.labels | object | `{}` | Resource-specific labels. |
| clusterSecretStores.__helm_docs_example__.namespace | string | `"documentation-placeholder"` | Optional namespace field kept for contract symmetry. Ignored for cluster-scoped ClusterSecretStore resources. |
| clusterSecretStores.__helm_docs_example__.spec | object | `{"provider":{"webhook":{"result":{"jsonPath":"$.data"},"url":"https://provider.example/api"}},"retrySettings":{"maxRetries":3,"retryInterval":"10s"}}` | Resource spec rendered as-is. |
| clusterSecretStores.__helm_docs_example__.status | object | `{"conditions":[{"status":"True","type":"Ready"}]}` | Optional resource status rendered as-is. |
| commonAnnotations | object | `{}` | Extra annotations applied to every rendered resource. |
| commonLabels | object | `{}` | Extra labels applied to every rendered resource. |
| ecrAuthorizationTokens | object | `{"__helm_docs_example__":{"annotations":{},"apiVersion":"generators.external-secrets.io/v1alpha1","labels":{},"namespace":"documentation-placeholder","spec":{"auth":{"jwt":{"serviceAccountRef":{"name":"documentation-placeholder"}}},"region":"eu-central-1","scope":"private"},"status":{}}}` | ECRAuthorizationToken resources keyed by resource name. |
| ecrAuthorizationTokens.__helm_docs_example__.annotations | object | `{}` | Resource-specific annotations. |
| ecrAuthorizationTokens.__helm_docs_example__.apiVersion | string | `"generators.external-secrets.io/v1alpha1"` | Per-resource apiVersion override. |
| ecrAuthorizationTokens.__helm_docs_example__.labels | object | `{}` | Resource-specific labels. |
| ecrAuthorizationTokens.__helm_docs_example__.namespace | string | `"documentation-placeholder"` | Namespace for the ECRAuthorizationToken resource. Defaults to the Helm release namespace. |
| ecrAuthorizationTokens.__helm_docs_example__.spec | object | `{"auth":{"jwt":{"serviceAccountRef":{"name":"documentation-placeholder"}}},"region":"eu-central-1","scope":"private"}` | Resource spec rendered as-is. |
| ecrAuthorizationTokens.__helm_docs_example__.status | object | `{}` | Optional resource status rendered as-is. |
| enabled | bool | `true` |  |
| externalSecrets | object | `{"__helm_docs_example__":{"annotations":{},"apiVersion":"external-secrets.io/v1","labels":{},"namespace":"documentation-placeholder","spec":{"data":[{"remoteRef":{"key":"apps/demo","property":"username"},"secretKey":"username"}],"refreshInterval":"1h","secretStoreRef":{"kind":"SecretStore","name":"documentation-placeholder"},"target":{"creationPolicy":"Owner","name":"documentation-placeholder"}},"status":{"conditions":[{"status":"True","type":"Ready"}]}}}` | ExternalSecret resources keyed by resource name. |
| externalSecrets.__helm_docs_example__.annotations | object | `{}` | Resource-specific annotations. |
| externalSecrets.__helm_docs_example__.apiVersion | string | `"external-secrets.io/v1"` | Per-resource apiVersion override. |
| externalSecrets.__helm_docs_example__.labels | object | `{}` | Resource-specific labels. |
| externalSecrets.__helm_docs_example__.namespace | string | `"documentation-placeholder"` | Namespace for the ExternalSecret resource. Defaults to the Helm release namespace. |
| externalSecrets.__helm_docs_example__.spec | object | `{"data":[{"remoteRef":{"key":"apps/demo","property":"username"},"secretKey":"username"}],"refreshInterval":"1h","secretStoreRef":{"kind":"SecretStore","name":"documentation-placeholder"},"target":{"creationPolicy":"Owner","name":"documentation-placeholder"}}` | Resource spec rendered as-is. |
| externalSecrets.__helm_docs_example__.status | object | `{"conditions":[{"status":"True","type":"Ready"}]}` | Optional resource status rendered as-is. |
| fakes | object | `{"__helm_docs_example__":{"annotations":{},"apiVersion":"generators.external-secrets.io/v1alpha1","labels":{},"namespace":"documentation-placeholder","spec":{"data":{"password":"documentation-placeholder","username":"documentation-placeholder"}},"status":{}}}` | Fake resources keyed by resource name. |
| fakes.__helm_docs_example__.annotations | object | `{}` | Resource-specific annotations. |
| fakes.__helm_docs_example__.apiVersion | string | `"generators.external-secrets.io/v1alpha1"` | Per-resource apiVersion override. |
| fakes.__helm_docs_example__.labels | object | `{}` | Resource-specific labels. |
| fakes.__helm_docs_example__.namespace | string | `"documentation-placeholder"` | Namespace for the Fake resource. Defaults to the Helm release namespace. |
| fakes.__helm_docs_example__.spec | object | `{"data":{"password":"documentation-placeholder","username":"documentation-placeholder"}}` | Resource spec rendered as-is. |
| fakes.__helm_docs_example__.status | object | `{}` | Optional resource status rendered as-is. |
| gcrAccessTokens | object | `{"__helm_docs_example__":{"annotations":{},"apiVersion":"generators.external-secrets.io/v1alpha1","labels":{},"namespace":"documentation-placeholder","spec":{"auth":{"workloadIdentity":{"clusterLocation":"documentation-placeholder","clusterName":"documentation-placeholder","serviceAccountRef":{"name":"documentation-placeholder"}}},"projectID":"documentation-placeholder"},"status":{}}}` | GCRAccessToken resources keyed by resource name. |
| gcrAccessTokens.__helm_docs_example__.annotations | object | `{}` | Resource-specific annotations. |
| gcrAccessTokens.__helm_docs_example__.apiVersion | string | `"generators.external-secrets.io/v1alpha1"` | Per-resource apiVersion override. |
| gcrAccessTokens.__helm_docs_example__.labels | object | `{}` | Resource-specific labels. |
| gcrAccessTokens.__helm_docs_example__.namespace | string | `"documentation-placeholder"` | Namespace for the GCRAccessToken resource. Defaults to the Helm release namespace. |
| gcrAccessTokens.__helm_docs_example__.spec | object | `{"auth":{"workloadIdentity":{"clusterLocation":"documentation-placeholder","clusterName":"documentation-placeholder","serviceAccountRef":{"name":"documentation-placeholder"}}},"projectID":"documentation-placeholder"}` | Resource spec rendered as-is. |
| gcrAccessTokens.__helm_docs_example__.status | object | `{}` | Optional resource status rendered as-is. |
| generatorStates | object | `{"__helm_docs_example__":{"annotations":{},"apiVersion":"generators.external-secrets.io/v1alpha1","labels":{},"namespace":"documentation-placeholder","spec":{"generatorRef":{"apiVersion":"generators.external-secrets.io/v1alpha1","kind":"Password","name":"documentation-placeholder"}},"status":{"conditions":[{"status":"True","type":"Ready"}]}}}` | GeneratorState resources keyed by resource name. |
| generatorStates.__helm_docs_example__.annotations | object | `{}` | Resource-specific annotations. |
| generatorStates.__helm_docs_example__.apiVersion | string | `"generators.external-secrets.io/v1alpha1"` | Per-resource apiVersion override. |
| generatorStates.__helm_docs_example__.labels | object | `{}` | Resource-specific labels. |
| generatorStates.__helm_docs_example__.namespace | string | `"documentation-placeholder"` | Namespace for the GeneratorState resource. Defaults to the Helm release namespace. |
| generatorStates.__helm_docs_example__.spec | object | `{"generatorRef":{"apiVersion":"generators.external-secrets.io/v1alpha1","kind":"Password","name":"documentation-placeholder"}}` | Resource spec rendered as-is. |
| generatorStates.__helm_docs_example__.status | object | `{"conditions":[{"status":"True","type":"Ready"}]}` | Optional resource status rendered as-is. |
| githubAccessTokens | object | `{"__helm_docs_example__":{"annotations":{},"apiVersion":"generators.external-secrets.io/v1alpha1","labels":{},"namespace":"documentation-placeholder","spec":{"appID":"12345","auth":{"privateKey":{"key":"privateKey","name":"documentation-placeholder"}},"installID":"67890","url":"https://api.github.com"},"status":{}}}` | GithubAccessToken resources keyed by resource name. |
| githubAccessTokens.__helm_docs_example__.annotations | object | `{}` | Resource-specific annotations. |
| githubAccessTokens.__helm_docs_example__.apiVersion | string | `"generators.external-secrets.io/v1alpha1"` | Per-resource apiVersion override. |
| githubAccessTokens.__helm_docs_example__.labels | object | `{}` | Resource-specific labels. |
| githubAccessTokens.__helm_docs_example__.namespace | string | `"documentation-placeholder"` | Namespace for the GithubAccessToken resource. Defaults to the Helm release namespace. |
| githubAccessTokens.__helm_docs_example__.spec | object | `{"appID":"12345","auth":{"privateKey":{"key":"privateKey","name":"documentation-placeholder"}},"installID":"67890","url":"https://api.github.com"}` | Resource spec rendered as-is. |
| githubAccessTokens.__helm_docs_example__.status | object | `{}` | Optional resource status rendered as-is. |
| global | object | `{}` | Arbitrary global values available to tpl-rendered strings. |
| grafanas | object | `{"__helm_docs_example__":{"annotations":{},"apiVersion":"generators.external-secrets.io/v1alpha1","labels":{},"namespace":"documentation-placeholder","spec":{"auth":{"token":{"key":"token","name":"documentation-placeholder"}},"orgId":1,"url":"https://grafana.example"},"status":{}}}` | Grafana resources keyed by resource name. |
| grafanas.__helm_docs_example__.annotations | object | `{}` | Resource-specific annotations. |
| grafanas.__helm_docs_example__.apiVersion | string | `"generators.external-secrets.io/v1alpha1"` | Per-resource apiVersion override. |
| grafanas.__helm_docs_example__.labels | object | `{}` | Resource-specific labels. |
| grafanas.__helm_docs_example__.namespace | string | `"documentation-placeholder"` | Namespace for the Grafana resource. Defaults to the Helm release namespace. |
| grafanas.__helm_docs_example__.spec | object | `{"auth":{"token":{"key":"token","name":"documentation-placeholder"}},"orgId":1,"url":"https://grafana.example"}` | Resource spec rendered as-is. |
| grafanas.__helm_docs_example__.status | object | `{}` | Optional resource status rendered as-is. |
| mfas | object | `{"__helm_docs_example__":{"annotations":{},"apiVersion":"generators.external-secrets.io/v1alpha1","labels":{},"namespace":"documentation-placeholder","spec":{"accountName":"documentation-placeholder","digits":6,"issuer":"documentation-placeholder","period":30},"status":{}}}` | MFA resources keyed by resource name. |
| mfas.__helm_docs_example__.annotations | object | `{}` | Resource-specific annotations. |
| mfas.__helm_docs_example__.apiVersion | string | `"generators.external-secrets.io/v1alpha1"` | Per-resource apiVersion override. |
| mfas.__helm_docs_example__.labels | object | `{}` | Resource-specific labels. |
| mfas.__helm_docs_example__.namespace | string | `"documentation-placeholder"` | Namespace for the MFA resource. Defaults to the Helm release namespace. |
| mfas.__helm_docs_example__.spec | object | `{"accountName":"documentation-placeholder","digits":6,"issuer":"documentation-placeholder","period":30}` | Resource spec rendered as-is. |
| mfas.__helm_docs_example__.status | object | `{}` | Optional resource status rendered as-is. |
| nameOverride | string | `""` | Override the generated base name if needed. |
| passwords | object | `{"__helm_docs_example__":{"annotations":{},"apiVersion":"generators.external-secrets.io/v1alpha1","labels":{},"namespace":"documentation-placeholder","spec":{"digits":8,"length":32,"symbolCharacters":"!@#$%","symbols":4},"status":{}}}` | Password resources keyed by resource name. |
| passwords.__helm_docs_example__.annotations | object | `{}` | Resource-specific annotations. |
| passwords.__helm_docs_example__.apiVersion | string | `"generators.external-secrets.io/v1alpha1"` | Per-resource apiVersion override. |
| passwords.__helm_docs_example__.labels | object | `{}` | Resource-specific labels. |
| passwords.__helm_docs_example__.namespace | string | `"documentation-placeholder"` | Namespace for the Password resource. Defaults to the Helm release namespace. |
| passwords.__helm_docs_example__.spec | object | `{"digits":8,"length":32,"symbolCharacters":"!@#$%","symbols":4}` | Resource spec rendered as-is. |
| passwords.__helm_docs_example__.status | object | `{}` | Optional resource status rendered as-is. |
| pushSecrets | object | `{"__helm_docs_example__":{"annotations":{},"apiVersion":"external-secrets.io/v1alpha1","labels":{},"namespace":"documentation-placeholder","spec":{"data":[{"match":{"secretKey":"token"},"remoteRef":{"remoteKey":"providers/demo"}}],"refreshInterval":"1h","secretStoreRefs":[{"kind":"SecretStore","name":"documentation-placeholder"}],"selector":{"secret":{"name":"documentation-placeholder"}}},"status":{"conditions":[{"status":"True","type":"Ready"}]}}}` | PushSecret resources keyed by resource name. |
| pushSecrets.__helm_docs_example__.annotations | object | `{}` | Resource-specific annotations. |
| pushSecrets.__helm_docs_example__.apiVersion | string | `"external-secrets.io/v1alpha1"` | Per-resource apiVersion override. |
| pushSecrets.__helm_docs_example__.labels | object | `{}` | Resource-specific labels. |
| pushSecrets.__helm_docs_example__.namespace | string | `"documentation-placeholder"` | Namespace for the PushSecret resource. Defaults to the Helm release namespace. |
| pushSecrets.__helm_docs_example__.spec | object | `{"data":[{"match":{"secretKey":"token"},"remoteRef":{"remoteKey":"providers/demo"}}],"refreshInterval":"1h","secretStoreRefs":[{"kind":"SecretStore","name":"documentation-placeholder"}],"selector":{"secret":{"name":"documentation-placeholder"}}}` | Resource spec rendered as-is. |
| pushSecrets.__helm_docs_example__.status | object | `{"conditions":[{"status":"True","type":"Ready"}]}` | Optional resource status rendered as-is. |
| quayAccessTokens | object | `{"__helm_docs_example__":{"annotations":{},"apiVersion":"generators.external-secrets.io/v1alpha1","labels":{},"namespace":"documentation-placeholder","spec":{"auth":{"robotAccount":{"key":"token","name":"documentation-placeholder"}},"repository":"documentation-placeholder","url":"https://quay.io"},"status":{}}}` | QuayAccessToken resources keyed by resource name. |
| quayAccessTokens.__helm_docs_example__.annotations | object | `{}` | Resource-specific annotations. |
| quayAccessTokens.__helm_docs_example__.apiVersion | string | `"generators.external-secrets.io/v1alpha1"` | Per-resource apiVersion override. |
| quayAccessTokens.__helm_docs_example__.labels | object | `{}` | Resource-specific labels. |
| quayAccessTokens.__helm_docs_example__.namespace | string | `"documentation-placeholder"` | Namespace for the QuayAccessToken resource. Defaults to the Helm release namespace. |
| quayAccessTokens.__helm_docs_example__.spec | object | `{"auth":{"robotAccount":{"key":"token","name":"documentation-placeholder"}},"repository":"documentation-placeholder","url":"https://quay.io"}` | Resource spec rendered as-is. |
| quayAccessTokens.__helm_docs_example__.status | object | `{}` | Optional resource status rendered as-is. |
| releasePrefix | string | `""` | Optional release prefix used for generated names. |
| secretStores | object | `{"__helm_docs_example__":{"annotations":{},"apiVersion":"external-secrets.io/v1","labels":{},"namespace":"documentation-placeholder","spec":{"provider":{"webhook":{"result":{"jsonPath":"$.data"},"url":"https://provider.example/api"}},"retrySettings":{"maxRetries":3,"retryInterval":"10s"}},"status":{"conditions":[{"status":"True","type":"Ready"}]}}}` | SecretStore resources keyed by resource name. |
| secretStores.__helm_docs_example__.annotations | object | `{}` | Resource-specific annotations. |
| secretStores.__helm_docs_example__.apiVersion | string | `"external-secrets.io/v1"` | Per-resource apiVersion override. |
| secretStores.__helm_docs_example__.labels | object | `{}` | Resource-specific labels. |
| secretStores.__helm_docs_example__.namespace | string | `"documentation-placeholder"` | Namespace for the SecretStore resource. Defaults to the Helm release namespace. |
| secretStores.__helm_docs_example__.spec | object | `{"provider":{"webhook":{"result":{"jsonPath":"$.data"},"url":"https://provider.example/api"}},"retrySettings":{"maxRetries":3,"retryInterval":"10s"}}` | Resource spec rendered as-is. |
| secretStores.__helm_docs_example__.status | object | `{"conditions":[{"status":"True","type":"Ready"}]}` | Optional resource status rendered as-is. |
| sshKeys | object | `{"__helm_docs_example__":{"annotations":{},"apiVersion":"generators.external-secrets.io/v1alpha1","labels":{},"namespace":"documentation-placeholder","spec":{"algorithm":"rsa","comment":"documentation-placeholder","length":4096},"status":{}}}` | SSHKey resources keyed by resource name. |
| sshKeys.__helm_docs_example__.annotations | object | `{}` | Resource-specific annotations. |
| sshKeys.__helm_docs_example__.apiVersion | string | `"generators.external-secrets.io/v1alpha1"` | Per-resource apiVersion override. |
| sshKeys.__helm_docs_example__.labels | object | `{}` | Resource-specific labels. |
| sshKeys.__helm_docs_example__.namespace | string | `"documentation-placeholder"` | Namespace for the SSHKey resource. Defaults to the Helm release namespace. |
| sshKeys.__helm_docs_example__.spec | object | `{"algorithm":"rsa","comment":"documentation-placeholder","length":4096}` | Resource spec rendered as-is. |
| sshKeys.__helm_docs_example__.status | object | `{}` | Optional resource status rendered as-is. |
| stsSessionTokens | object | `{"__helm_docs_example__":{"annotations":{},"apiVersion":"generators.external-secrets.io/v1alpha1","labels":{},"namespace":"documentation-placeholder","spec":{"auth":{"jwt":{"serviceAccountRef":{"name":"documentation-placeholder"}}},"region":"eu-central-1","role":"arn:aws:iam::111111111111:role/demo"},"status":{}}}` | STSSessionToken resources keyed by resource name. |
| stsSessionTokens.__helm_docs_example__.annotations | object | `{}` | Resource-specific annotations. |
| stsSessionTokens.__helm_docs_example__.apiVersion | string | `"generators.external-secrets.io/v1alpha1"` | Per-resource apiVersion override. |
| stsSessionTokens.__helm_docs_example__.labels | object | `{}` | Resource-specific labels. |
| stsSessionTokens.__helm_docs_example__.namespace | string | `"documentation-placeholder"` | Namespace for the STSSessionToken resource. Defaults to the Helm release namespace. |
| stsSessionTokens.__helm_docs_example__.spec | object | `{"auth":{"jwt":{"serviceAccountRef":{"name":"documentation-placeholder"}}},"region":"eu-central-1","role":"arn:aws:iam::111111111111:role/demo"}` | Resource spec rendered as-is. |
| stsSessionTokens.__helm_docs_example__.status | object | `{}` | Optional resource status rendered as-is. |
| uuids | object | `{"__helm_docs_example__":{"annotations":{},"apiVersion":"generators.external-secrets.io/v1alpha1","labels":{},"namespace":"documentation-placeholder","spec":{"version":4},"status":{}}}` | UUID resources keyed by resource name. |
| uuids.__helm_docs_example__.annotations | object | `{}` | Resource-specific annotations. |
| uuids.__helm_docs_example__.apiVersion | string | `"generators.external-secrets.io/v1alpha1"` | Per-resource apiVersion override. |
| uuids.__helm_docs_example__.labels | object | `{}` | Resource-specific labels. |
| uuids.__helm_docs_example__.namespace | string | `"documentation-placeholder"` | Namespace for the UUID resource. Defaults to the Helm release namespace. |
| uuids.__helm_docs_example__.spec | object | `{"version":4}` | Resource spec rendered as-is. |
| uuids.__helm_docs_example__.status | object | `{}` | Optional resource status rendered as-is. |
| vaultDynamicSecrets | object | `{"__helm_docs_example__":{"annotations":{},"apiVersion":"generators.external-secrets.io/v1alpha1","labels":{},"namespace":"documentation-placeholder","spec":{"path":"database/creds/demo","provider":{"auth":{"kubernetes":{"role":"documentation-placeholder"}},"server":"https://vault.example:8200"}},"status":{}}}` | VaultDynamicSecret resources keyed by resource name. |
| vaultDynamicSecrets.__helm_docs_example__.annotations | object | `{}` | Resource-specific annotations. |
| vaultDynamicSecrets.__helm_docs_example__.apiVersion | string | `"generators.external-secrets.io/v1alpha1"` | Per-resource apiVersion override. |
| vaultDynamicSecrets.__helm_docs_example__.labels | object | `{}` | Resource-specific labels. |
| vaultDynamicSecrets.__helm_docs_example__.namespace | string | `"documentation-placeholder"` | Namespace for the VaultDynamicSecret resource. Defaults to the Helm release namespace. |
| vaultDynamicSecrets.__helm_docs_example__.spec | object | `{"path":"database/creds/demo","provider":{"auth":{"kubernetes":{"role":"documentation-placeholder"}},"server":"https://vault.example:8200"}}` | Resource spec rendered as-is. |
| vaultDynamicSecrets.__helm_docs_example__.status | object | `{}` | Optional resource status rendered as-is. |
| webhooks | object | `{"__helm_docs_example__":{"annotations":{},"apiVersion":"generators.external-secrets.io/v1alpha1","labels":{},"namespace":"documentation-placeholder","spec":{"method":"GET","result":{"jsonPath":"$.token"},"url":"https://generator.example/token"},"status":{}}}` | Webhook resources keyed by resource name. |
| webhooks.__helm_docs_example__.annotations | object | `{}` | Resource-specific annotations. |
| webhooks.__helm_docs_example__.apiVersion | string | `"generators.external-secrets.io/v1alpha1"` | Per-resource apiVersion override. |
| webhooks.__helm_docs_example__.labels | object | `{}` | Resource-specific labels. |
| webhooks.__helm_docs_example__.namespace | string | `"documentation-placeholder"` | Namespace for the Webhook resource. Defaults to the Helm release namespace. |
| webhooks.__helm_docs_example__.spec | object | `{"method":"GET","result":{"jsonPath":"$.token"},"url":"https://generator.example/token"}` | Resource spec rendered as-is. |
| webhooks.__helm_docs_example__.status | object | `{}` | Optional resource status rendered as-is. |

## Included Values Files

- [values.yaml](values.yaml): minimal defaults that render no resources.
- [values.yaml.example](values.yaml.example): example values covering every supported resource kind.

## Testing

Representative local commands:

```bash
helm lint . -f values.yaml.example
helm template {chart_name} . -f values.yaml.example
helm unittest -f 'tests/units/*_test.yaml' .
sh tests/units/backward_compatibility_test.sh
python3 tests/smokes/run/smoke.py
make test-smoke-fast
```
