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
    render.assert_doc_count(documents, 7)
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

    store = render.select_document(
        documents,
        kind="ClusterSecretStore",
        name=f"{context.release_name}-vault",
    )
    render.assert_path(store, "apiVersion", "external-secrets.io/v1")
    render.assert_path_missing(store, "metadata.namespace")
    render.assert_path(store, "spec.provider.vault.server", "https://vault.example.com")

    secret = render.select_document(
        documents,
        kind="ExternalSecret",
        name=f"{context.release_name}-simple-app",
    )
    render.assert_path(secret, "metadata.namespace", context.namespace)
    render.assert_path(secret, "metadata.labels.env", "prod")
    render.assert_path(secret, 'metadata.annotations["test/generator"]', "smoke")
    render.assert_path(secret, "spec.refreshInterval", "1h")
    render.assert_path(secret, "spec.secretStoreRef.name", "vault")
    render.assert_path(secret, "spec.data[0].remoteRef.key", "kv/prod/simple-app")

    push_secret = render.select_document(
        documents,
        kind="PushSecret",
        name=f"{context.release_name}-sync-creds",
    )
    render.assert_path(push_secret, "metadata.namespace", context.namespace)
    render.assert_path(push_secret, "spec.deletionPolicy", "Delete")
    render.assert_path(push_secret, "spec.secretStoreRefs[0].name", "vault")


def check_example_render(context: SmokeContext) -> None:
    _, documents = render_example(context, "example-render.yaml")
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

    secret = render.select_document(
        documents,
        kind="ExternalSecret",
        name="external-secrets-app-config",
    )
    render.assert_path(secret, "metadata.namespace", "app")
    render.assert_path(secret, "spec.secretStoreRef.name", "external-secrets-tenant-store")
    render.assert_path(secret, 'spec.target.template.metadata.labels["synced-by"]', "eso")

    store = render.select_document(
        documents,
        kind="ClusterSecretStore",
        name="external-secrets-tenant-store",
    )
    render.assert_path_missing(store, "metadata.namespace")
    render.assert_path(store, "spec.provider.webhook.url", "https://eso-provider.example/api/secrets")

    push_secret = render.select_document(
        documents,
        kind="PushSecret",
        name="external-secrets-app-push",
    )
    render.assert_path(push_secret, "spec.deletionPolicy", "Delete")
    render.assert_path(push_secret, "spec.secretStoreRefs[0].name", "external-secrets-tenant-store")


def check_example_kubeconform(context: SmokeContext) -> None:
    output_path, documents = render_example(context, "example-kubeconform.yaml")
    render.assert_doc_count(documents, 6)

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
