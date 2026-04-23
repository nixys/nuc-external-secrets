from __future__ import annotations

from dataclasses import dataclass
from pathlib import Path
from typing import Callable

from tests.smokes.steps import chart, helm, kubeconform, render, system


@dataclass
class SmokeContext:
    repo_root: Path
    workdir: Path
    chart_dir: Path
    render_dir: Path
    release_name: str
    namespace: str
    kubeconform_bin: str
    kubeconform_kubernetes_version: str
    kubeconform_schema_location: str
    kubeconform_skip_kinds: str

    @property
    def example_values(self) -> Path:
        return self.repo_root / "values.yaml.example"

    @property
    def rendering_contract_values(self) -> Path:
        return self.repo_root / "tests" / "smokes" / "fixtures" / "rendering-contract.values.yaml"

    @property
    def invalid_list_contract_values(self) -> Path:
        return self.repo_root / "tests" / "smokes" / "fixtures" / "invalid-list-contract.values.yaml"


def render_example(context: SmokeContext, output_name: str) -> tuple[Path, list[dict]]:
    helm.lint(
        context.chart_dir,
        values_file=context.example_values,
        workdir=context.workdir,
    )
    output_path = context.render_dir / output_name
    helm.template(
        context.chart_dir,
        release_name=context.release_name,
        namespace=context.namespace,
        values_file=context.example_values,
        output_path=output_path,
        workdir=context.workdir,
    )
    return output_path, render.load_documents(output_path)


def check_default_empty(context: SmokeContext) -> None:
    helm.lint(context.chart_dir, workdir=context.workdir)
    output_path = context.render_dir / "default-empty.yaml"
    helm.template(
        context.chart_dir,
        release_name=context.release_name,
        namespace=context.namespace,
        output_path=output_path,
        workdir=context.workdir,
    )
    documents = render.load_documents(output_path)
    render.assert_doc_count(documents, 0)


def check_schema_invalid_list_contract(context: SmokeContext) -> None:
    result = helm.lint(
        context.chart_dir,
        values_file=context.invalid_list_contract_values,
        workdir=context.workdir,
        check=False,
    )
    if result.returncode == 0:
        raise system.TestFailure(
            "helm lint unexpectedly succeeded for invalid list-based values"
        )

    combined_output = f"{result.stdout}\n{result.stderr}"
    if "externalSecrets" not in combined_output or "object" not in combined_output:
        raise system.TestFailure(
            "helm lint failed for invalid values, but the error does not mention the object-based map contract"
        )


def check_rendering_contract(context: SmokeContext) -> None:
    helm.lint(
        context.chart_dir,
        values_file=context.rendering_contract_values,
        workdir=context.workdir,
    )
    output_path = context.render_dir / "rendering-contract.yaml"
    helm.template(
        context.chart_dir,
        release_name=context.release_name,
        namespace=context.namespace,
        values_file=context.rendering_contract_values,
        output_path=output_path,
        workdir=context.workdir,
    )

    documents = render.load_documents(output_path)
    render.assert_doc_count(documents, 6)
    render.assert_kinds(
        documents,
        {
            "ExternalSecret",
            "ClusterExternalSecret",
            "SecretStore",
            "ClusterSecretStore",
            "PushSecret",
            "ClusterPushSecret",
        },
    )

    external_secret = render.select_document(
        documents, kind="ExternalSecret", name="merged-external-secret"
    )
    render.assert_path(external_secret, "apiVersion", "external-secrets.io/v1")
    render.assert_path(external_secret, "metadata.namespace", context.namespace)
    render.assert_path(
        external_secret,
        "metadata.labels[app.kubernetes.io/name]",
        "external-secrets-platform",
    )
    render.assert_path(external_secret, "metadata.labels.platform", "eso")
    render.assert_path(external_secret, "metadata.labels.component", "secret")
    render.assert_path(external_secret, "metadata.annotations.team", "platform")
    render.assert_path(external_secret, "metadata.annotations.note", "merged-secret")
    render.assert_path(external_secret, "spec.refreshInterval", "1h")
    render.assert_path(external_secret, "spec.secretStoreRef.name", "vault")
    render.assert_path(external_secret, "spec.secretStoreRef.kind", "ClusterSecretStore")
    render.assert_path(external_secret, "spec.target.creationPolicy", "Owner")
    render.assert_path(external_secret, "spec.data[0].secretKey", "DB_PASS")
    render.assert_path(external_secret, "spec.data[0].remoteRef.key", "kv/prod/app")
    render.assert_path(external_secret, "spec.data[0].remoteRef.property", "password")

    cluster_external_secret = render.select_document(
        documents,
        kind="ClusterExternalSecret",
        name="merged-cluster-external-secret",
    )
    render.assert_path(cluster_external_secret, "apiVersion", "external-secrets.io/v1")
    render.assert_path_missing(cluster_external_secret, "metadata.namespace")
    render.assert_path(
        cluster_external_secret,
        "spec.externalSecretName",
        "broadcast",
    )
    render.assert_path(
        cluster_external_secret,
        "spec.namespaceSelectors[0].matchLabels[pull-secrets]",
        "true",
    )
    render.assert_path(
        cluster_external_secret,
        "spec.externalSecretSpec.target.name",
        "broadcast",
    )

    secret_store = render.select_document(
        documents, kind="SecretStore", name="merged-secret-store"
    )
    render.assert_path(secret_store, "apiVersion", "external-secrets.io/v1")
    render.assert_path(secret_store, "metadata.namespace", "stores")
    render.assert_path(
        secret_store, "spec.provider.vault.server", "https://vault.example.com"
    )
    render.assert_path(
        secret_store, "spec.provider.vault.auth.kubernetes.role", "team-a"
    )

    cluster_secret_store = render.select_document(
        documents, kind="ClusterSecretStore", name="merged-cluster-secret-store"
    )
    render.assert_path(cluster_secret_store, "apiVersion", "external-secrets.io/v1")
    render.assert_path_missing(cluster_secret_store, "metadata.namespace")
    render.assert_path(
        cluster_secret_store, "spec.provider.vault.auth.kubernetes.role", "eso-default"
    )

    push_secret = render.select_document(
        documents, kind="PushSecret", name="merged-push-secret"
    )
    render.assert_path(push_secret, "apiVersion", "external-secrets.io/v1alpha1")
    render.assert_path(push_secret, "metadata.namespace", context.namespace)
    render.assert_path(push_secret, "spec.deletionPolicy", "Delete")
    render.assert_path(push_secret, "spec.refreshInterval", "1h")
    render.assert_path(push_secret, "spec.secretStoreRefs[0].name", "vault")
    render.assert_path(push_secret, "spec.selector.secret.name", "local-creds")
    render.assert_path(
        push_secret, "spec.data[0].match.secretKey", "password"
    )

    cluster_push_secret = render.select_document(
        documents, kind="ClusterPushSecret", name="merged-cluster-push-secret"
    )
    render.assert_path(cluster_push_secret, "apiVersion", "external-secrets.io/v1alpha1")
    render.assert_path_missing(cluster_push_secret, "metadata.namespace")
    render.assert_path(
        cluster_push_secret,
        "spec.pushSecretSpec.secretStoreRefs[0].name",
        "vault",
    )
    render.assert_path(
        cluster_push_secret,
        "spec.pushSecretSpec.selector.secret.name",
        "ca-cert",
    )


def check_example_render(context: SmokeContext) -> None:
    _, documents = render_example(context, "example-render.yaml")
    render.assert_doc_count(documents, 8)
    render.assert_kinds(
        documents,
        {
            "ExternalSecret",
            "ClusterExternalSecret",
            "SecretStore",
            "ClusterSecretStore",
            "PushSecret",
            "ClusterPushSecret",
        },
    )

    app_one = render.select_document(
        documents, kind="ExternalSecret", name="app-one-secrets"
    )
    render.assert_path(app_one, "metadata.namespace", "apps")
    render.assert_path(app_one, "spec.refreshInterval", "1h")
    render.assert_path(app_one, "spec.secretStoreRef.name", "vault")
    render.assert_path(app_one, "spec.data[0].secretKey", "DB_PASS")
    render.assert_path(app_one, "spec.data[1].secretKey", "API_TOKEN")

    app_two = render.select_document(
        documents, kind="ExternalSecret", name="app-two-secrets"
    )
    render.assert_path(app_two, "spec.refreshInterval", "30m")
    render.assert_path(app_two, "spec.dataFrom[0].extract.key", "kv/prod/app-two")

    tls = render.select_document(documents, kind="ExternalSecret", name="tls-material")
    render.assert_path(tls, "spec.target.name", "app-one-tls")
    render.assert_path(tls, "spec.target.template.type", "kubernetes.io/tls")

    broadcast = render.select_document(
        documents, kind="ClusterExternalSecret", name="broadcast-registry-pull"
    )
    render.assert_path_missing(broadcast, "metadata.namespace")
    render.assert_path(
        broadcast,
        "spec.externalSecretSpec.target.template.type",
        "kubernetes.io/dockerconfigjson",
    )

    team_a = render.select_document(documents, kind="SecretStore", name="team-a")
    render.assert_path(team_a, "metadata.namespace", "apps")
    render.assert_path(
        team_a, "spec.provider.vault.auth.kubernetes.role", "team-a"
    )

    vault_store = render.select_document(
        documents, kind="ClusterSecretStore", name="vault"
    )
    render.assert_path_missing(vault_store, "metadata.namespace")

    sync = render.select_document(
        documents, kind="PushSecret", name="sync-generated-creds"
    )
    render.assert_path(sync, "spec.deletionPolicy", "Delete")
    render.assert_path(sync, "spec.secretStoreRefs[0].name", "vault")
    render.assert_path(sync, "spec.selector.secret.name", "local-generated")

    broadcast_ca = render.select_document(
        documents, kind="ClusterPushSecret", name="broadcast-ca"
    )
    render.assert_path_missing(broadcast_ca, "metadata.namespace")
    render.assert_path(
        broadcast_ca,
        "spec.pushSecretSpec.selector.secret.name",
        "ca-cert",
    )


def check_example_kubeconform(context: SmokeContext) -> None:
    output_path, documents = render_example(context, "example-kubeconform.yaml")
    render.assert_doc_count(documents, 8)

    payload = kubeconform.validate(
        manifest_path=output_path,
        kube_version=context.kubeconform_kubernetes_version,
        kubeconform_bin=context.kubeconform_bin,
        schema_location=context.kubeconform_schema_location,
        skip_kinds=context.kubeconform_skip_kinds,
    )
    summary = payload.get("summary", {})
    valid = summary.get("valid", 0)
    skipped = summary.get("skipped", 0)
    expected = len(documents)
    if valid != expected or skipped != 0:
        raise system.TestFailure(
            "kubeconform summary did not validate every rendered example resource: "
            f"valid={valid}, skipped={skipped}, expected={expected}"
        )


SCENARIOS: list[tuple[str, Callable[[SmokeContext], None]]] = [
    ("default-empty", check_default_empty),
    ("schema-invalid-list-contract", check_schema_invalid_list_contract),
    ("rendering-contract", check_rendering_contract),
    ("example-render", check_example_render),
    ("example-kubeconform", check_example_kubeconform),
]


def run_smoke_suite(args) -> int:
    scenario_map = dict(SCENARIOS)
    requested = args.scenario or ["all"]
    if "all" in requested:
        selected = [name for name, _ in SCENARIOS]
    else:
        selected = requested

    repo_root = Path(args.chart_dir).resolve()
    workdir, chart_dir = chart.stage_chart(repo_root, args.workdir)
    context = SmokeContext(
        repo_root=repo_root,
        workdir=workdir,
        chart_dir=chart_dir,
        render_dir=workdir / "rendered",
        release_name=args.release_name,
        namespace=args.namespace,
        kubeconform_bin=args.kubeconform_bin,
        kubeconform_kubernetes_version=args.kubeconform_kubernetes_version,
        kubeconform_schema_location=args.kubeconform_schema_location,
        kubeconform_skip_kinds=args.kubeconform_skip_kinds,
    )
    context.render_dir.mkdir(parents=True, exist_ok=True)

    failures: list[tuple[str, str]] = []
    try:
        for name in selected:
            system.log(f"=== scenario: {name} ===")
            try:
                scenario_map[name](context)
            except Exception as exc:
                failures.append((name, str(exc)))
                system.log(f"FAILED: {name}: {exc}")
            else:
                system.log(f"PASSED: {name}")
    finally:
        if args.keep_workdir:
            system.log(f"workdir kept at {workdir}")
        else:
            chart.cleanup(workdir)

    if failures:
        system.log("=== summary: failures ===")
        for name, message in failures:
            system.log(f"- {name}: {message}")
        return 1

    system.log("=== summary: all smoke scenarios passed ===")
    return 0