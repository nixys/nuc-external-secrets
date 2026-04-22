#!/usr/bin/env bash

set -o errexit
set -o nounset
set -o pipefail

ROOT_DIR="$(git rev-parse --show-toplevel)"
SCRIPT_DIR="${ROOT_DIR}/tests/e2e"
CLUSTER_CREATED=false
CLUSTER_NAME="${CLUSTER_NAME:-$(mktemp -u "nuc-external-secrets-e2e-XXXXXXXXXX" | tr "[:upper:]" "[:lower:]")}"
K8S_VERSION="${K8S_VERSION:-v1.31.0}"
ESO_VERSION="${ESO_VERSION:-0.20.4}"
ESO_NAMESPACE="${ESO_NAMESPACE:-external-secrets}"
ESO_RELEASE_NAME="${ESO_RELEASE_NAME:-external-secrets}"
E2E_NAMESPACE="${E2E_NAMESPACE:-nuc-external-secrets-e2e}"
RELEASE_NAME="${RELEASE_NAME:-nuc-external-secrets-e2e}"
VALUES_FILE="tests/e2e/values/install.values.yaml"

RED='[0;31m'
YELLOW='[0;33m'
RESET='[0m'

log_error() { echo -e "${RED}Error:${RESET} $1" >&2; }
log_info() { echo -e "$1"; }
log_warn() { echo -e "${YELLOW}Warning:${RESET} $1" >&2; }

show_help() {
  echo "Usage: $(basename "$0") [helm upgrade/install options]"
  echo ""
  echo "Create a kind cluster, install External Secrets Operator via the official Helm chart, and run Helm install/upgrade against the root chart."
  echo "Unknown arguments are passed through to 'helm upgrade --install'."
  echo ""
  echo "Environment overrides:"
  echo "  CLUSTER_NAME       Kind cluster name"
  echo "  K8S_VERSION        kindest/node tag"
  echo "  ESO_VERSION        External Secrets Operator Helm chart version"
  echo "  ESO_NAMESPACE      Namespace for the ESO installation"
  echo "  ESO_RELEASE_NAME   Helm release name for the ESO installation"
  echo "  E2E_NAMESPACE      Namespace used for this chart install"
  echo "  RELEASE_NAME       Helm release name for this chart install"
  echo ""
}

verify_prerequisites() {
  for bin in docker kind kubectl helm; do
    if ! command -v "${bin}" >/dev/null 2>&1; then
      log_error "${bin} is not installed"
      exit 1
    fi
  done
}

cleanup() {
  local exit_code=$?

  if [ "${exit_code}" -ne 0 ] && [ "${CLUSTER_CREATED}" = true ]; then
    dump_cluster_state || true
  fi

  log_info "Cleaning up resources"

  if [ "${CLUSTER_CREATED}" = true ]; then
    log_info "Removing kind cluster ${CLUSTER_NAME}"
    if kind get clusters | grep -q "${CLUSTER_NAME}"; then
      kind delete cluster --name="${CLUSTER_NAME}"
    else
      log_warn "kind cluster ${CLUSTER_NAME} not found"
    fi
  fi

  exit "${exit_code}"
}

dump_cluster_state() {
  log_warn "Dumping External Secrets resources from ${CLUSTER_NAME}"
  kubectl get crd \
    externalsecrets.external-secrets.io \
    secretstores.external-secrets.io \
    fakes.generators.external-secrets.io \
    passwords.generators.external-secrets.io \
    uuids.generators.external-secrets.io \
    clustergenerators.generators.external-secrets.io || true
  kubectl get \
    externalsecrets.external-secrets.io,secretstores.external-secrets.io,\
fakes.generators.external-secrets.io,passwords.generators.external-secrets.io,\
uuids.generators.external-secrets.io -A || true
  kubectl get clustergenerators.generators.external-secrets.io || true
  kubectl get pods -A || true
}

create_kind_cluster() {
  log_info "Creating kind cluster ${CLUSTER_NAME}"

  if kind get clusters | grep -q "${CLUSTER_NAME}"; then
    log_error "kind cluster ${CLUSTER_NAME} already exists"
    exit 1
  fi

  kind create cluster \
    --name="${CLUSTER_NAME}" \
    --config="${SCRIPT_DIR}/kind.yaml" \
    --image="kindest/node:${K8S_VERSION}" \
    --wait=60s

  CLUSTER_CREATED=true
  echo
}

install_eso() {
  log_info "Installing External Secrets Operator ${ESO_VERSION}"
  helm repo add external-secrets https://charts.external-secrets.io --force-update
  helm repo update

  kubectl get namespace "${ESO_NAMESPACE}" >/dev/null 2>&1 || kubectl create namespace "${ESO_NAMESPACE}"

  helm upgrade --install \
    "${ESO_RELEASE_NAME}" \
    external-secrets/external-secrets \
    --version "${ESO_VERSION}" \
    --namespace "${ESO_NAMESPACE}" \
    --set installCRDs=true \
    --wait \
    --timeout 300s

  kubectl wait --for=condition=Established --timeout=120s crd/externalsecrets.external-secrets.io
  kubectl wait --for=condition=Established --timeout=120s crd/secretstores.external-secrets.io
  kubectl wait --for=condition=Established --timeout=120s crd/fakes.generators.external-secrets.io
  kubectl wait --for=condition=Established --timeout=120s crd/passwords.generators.external-secrets.io
  kubectl wait --for=condition=Established --timeout=120s crd/uuids.generators.external-secrets.io
  kubectl wait --for=condition=Established --timeout=120s crd/clustergenerators.generators.external-secrets.io
  echo
}

ensure_namespace() {
  log_info "Ensuring namespace ${E2E_NAMESPACE} exists"
  kubectl get namespace "${E2E_NAMESPACE}" >/dev/null 2>&1 || kubectl create namespace "${E2E_NAMESPACE}"
  echo
}

install_chart() {
  local helm_args=(
    upgrade
    --install
    "${RELEASE_NAME}"
    "${ROOT_DIR}"
    --namespace "${E2E_NAMESPACE}"
    -f "${ROOT_DIR}/${VALUES_FILE}"
    --wait
    --timeout 300s
  )

  if [ "$#" -gt 0 ]; then
    helm_args+=("$@")
  fi

  log_info "Installing chart with Helm"
  helm "${helm_args[@]}"
  echo
}

verify_release_resources() {
  log_info "Verifying installed External Secrets resources"
  kubectl -n "${E2E_NAMESPACE}" get secretstore e2e-store
  kubectl -n "${E2E_NAMESPACE}" get externalsecret e2e-app-config
  kubectl -n "${E2E_NAMESPACE}" get fake e2e-static-data
  kubectl -n "${E2E_NAMESPACE}" get password e2e-app-password
  kubectl -n "${E2E_NAMESPACE}" get uuid e2e-request-id
  kubectl get clustergenerator e2e-shared-password
  echo
}

parse_args() {
  for arg in "$@"; do
    case "${arg}" in
      -h|--help)
        show_help
        exit 0
        ;;
    esac
  done
}

main() {
  parse_args "$@"
  verify_prerequisites

  trap cleanup EXIT

  create_kind_cluster
  install_eso
  ensure_namespace
  install_chart "$@"
  verify_release_resources

  log_info "End-to-end checks completed successfully"
}

main "$@"
