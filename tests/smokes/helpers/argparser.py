import argparse
from pathlib import Path


SCENARIO_CHOICES = [
    "all",
    "default-empty",
    "schema-invalid-list-contract",
    "rendering-contract",
    "example-render",
    "example-kubeconform",
]

DEFAULT_KUBECONFORM_KUBERNETES_VERSION = "1.35.0"


def build_parser() -> argparse.ArgumentParser:
    repo_root = Path(__file__).resolve().parents[3]
    default_kubeconform_schema_location = str(
        repo_root
        / "tests"
        / "smokes"
        / "schemas"
        / "{{.ResourceKind}}-{{.Group}}-{{.ResourceAPIVersion}}.json"
    )
    parser = argparse.ArgumentParser(
        description="Run smoke tests for the nuc-vault-secret-operator chart."
    )
    parser.add_argument(
        "--chart-dir",
        default=str(repo_root),
        help="Path to the chart repository root.",
    )
    parser.add_argument(
        "--release-name",
        default="smoke",
        help="Release name used for rendered manifests.",
    )
    parser.add_argument(
        "--namespace",
        default="smoke",
        help="Namespace used for rendered namespaced resources.",
    )
    parser.add_argument(
        "--scenario",
        action="append",
        choices=SCENARIO_CHOICES,
        help="Scenario to run. May be specified multiple times. Defaults to all.",
    )
    parser.add_argument(
        "--workdir",
        default=None,
        help="Optional existing directory for staged chart and rendered manifests.",
    )
    parser.add_argument(
        "--keep-workdir",
        action="store_true",
        help="Keep the staged work directory after the run.",
    )
    parser.add_argument(
        "--kubeconform-bin",
        default="kubeconform",
        help="Path to the kubeconform binary used by the example-kubeconform scenario.",
    )
    parser.add_argument(
        "--kubeconform-kubernetes-version",
        default=DEFAULT_KUBECONFORM_KUBERNETES_VERSION,
        help="Kubernetes version passed to kubeconform.",
    )
    parser.add_argument(
        "--kubeconform-schema-location",
        default=default_kubeconform_schema_location,
        help="Schema location template passed to kubeconform for custom resources.",
    )
    parser.add_argument(
        "--kubeconform-skip-kinds",
        default="",
        help="Comma-separated kinds or GVKs skipped by kubeconform.",
    )
    return parser
