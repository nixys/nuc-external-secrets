{{/*
Base chart name. Defaults to .Release.Name for subchart usage; nameOverride wins.
*/}}
{{- define "nuc-external-secrets.name" -}}
{{- default .Release.Name .Values.nameOverride | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{/*
Chart label value "name-version" for helm.sh/chart.
*/}}
{{- define "nuc-external-secrets.chart" -}}
{{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{/*
Resource fullname. Call with (dict "context" $root "name" <mapKey>).
If name is empty, returns base chart name.
If releasePrefix is set, produces "<releasePrefix>-<name>"; otherwise "<chartName>-<name>".
*/}}
{{- define "nuc-external-secrets.fullname" -}}
{{- $ctx := .context -}}
{{- $name := .name | default "" -}}
{{- if not $name -}}
{{- include "nuc-external-secrets.name" $ctx -}}
{{- else -}}
  {{- if $ctx.Values.releasePrefix -}}
  {{- printf "%s-%s" $ctx.Values.releasePrefix $name | trunc 63 | trimAll "-" -}}
  {{- else -}}
  {{- printf "%s-%s" (include "nuc-external-secrets.name" $ctx) $name | trunc 63 | trimSuffix "-" -}}
  {{- end -}}
{{- end -}}
{{- end -}}

{{/*
Standard chart labels.
*/}}
{{- define "nuc-external-secrets.labels" -}}
app.kubernetes.io/name: {{ include "nuc-external-secrets.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
helm.sh/chart: {{ include "nuc-external-secrets.chart" . }}
{{- if .Chart.AppVersion }}
app.kubernetes.io/version: {{ .Chart.AppVersion | quote }}
{{- end }}
{{- end -}}

{{/*
Render tpl values consistently: plain strings get tpl'd, structured values
are yaml-serialized and then tpl'd. Call with (dict "value" <v> "context" $root).
*/}}
{{- define "nuc-external-secrets.tplvalues.render" -}}
{{- if typeIs "string" .value -}}
{{- tpl .value .context -}}
{{- else -}}
{{- tpl (.value | toYaml) .context -}}
{{- end -}}
{{- end -}}

{{/*
tplContext: clone the root context and merge .Values.global into .Values so that
tpl expressions can reference umbrella-provided globals the same way as local values.
*/}}
{{- define "nuc-external-secrets.tplContext" -}}
{{- $tplContext := deepCopy . -}}
{{- if .Values.global -}}
{{- $_ := set $tplContext "Values" (mergeOverwrite (deepCopy .Values.global) .Values) -}}
{{- end -}}
{{- $tplContext | toYaml -}}
{{- end -}}

{{/*
Final labels for a rendered resource: chart labels + commonLabels + per-item labels.
Item labels win. Call with (dict "root" $root "item" <item>).
*/}}
{{- define "nuc-external-secrets.resourceLabels" -}}
{{- $root := .root -}}
{{- $item := .item | default dict -}}
{{- $labels := mustMergeOverwrite (dict) (include "nuc-external-secrets.labels" $root | fromYaml) ($root.Values.commonLabels | default dict) ($item.labels | default dict) -}}
{{- toYaml $labels -}}
{{- end -}}

{{/*
Final annotations for a rendered resource: commonAnnotations + per-item annotations.
Item annotations win. Call with (dict "root" $root "item" <item>).
*/}}
{{- define "nuc-external-secrets.resourceAnnotations" -}}
{{- $root := .root -}}
{{- $item := .item | default dict -}}
{{- $ann := mustMergeOverwrite (dict) ($root.Values.commonAnnotations | default dict) ($item.annotations | default dict) -}}
{{- toYaml $ann -}}
{{- end -}}

{{/*
Effective spec for a resource: generic.<kind> merged under item.spec (item wins).
Arrays are replaced by item, not merged — per Helm mustMergeOverwrite semantics.
Call with (dict "root" $root "item" <item> "kind" "<kindCamelCase>").
*/}}
{{- define "nuc-external-secrets.mergedSpec" -}}
{{- $root := .root -}}
{{- $item := .item | default dict -}}
{{- $kind := .kind -}}
{{- $generic := dict -}}
{{- if and $root.Values.generic (hasKey $root.Values.generic $kind) -}}
{{- $generic = deepCopy (index $root.Values.generic $kind) -}}
{{- end -}}
{{- $itemSpec := deepCopy ($item.spec | default dict) -}}
{{- $merged := mustMergeOverwrite $generic $itemSpec -}}
{{- toYaml $merged -}}
{{- end -}}

{{/*
Is this a real item (not the helm-docs placeholder, not nil, not enabled=false)?
Call with <itemValue>.
*/}}
{{- define "nuc-external-secrets.isActiveItem" -}}
{{- $item := . -}}
{{- if $item -}}
{{- if hasKey $item "enabled" -}}
{{- if $item.enabled -}}true{{- end -}}
{{- else -}}
true
{{- end -}}
{{- end -}}
{{- end -}}

{{/*
Common metadata block for a namespaced resource.
Call with (dict "root" $root "name" <mapKey> "item" <item>).
*/}}
{{- define "nuc-external-secrets.namespacedMetadata" -}}
{{- $root := .root -}}
{{- $item := .item | default dict -}}
{{- $name := .name -}}
name: {{ include "nuc-external-secrets.fullname" (dict "context" $root "name" $name) }}
namespace: {{ $item.namespace | default $root.Release.Namespace }}
labels:
  {{- include "nuc-external-secrets.resourceLabels" (dict "root" $root "item" $item) | nindent 2 }}
{{- $ann := include "nuc-external-secrets.resourceAnnotations" (dict "root" $root "item" $item) | trim }}
{{- if and $ann (ne $ann "{}") }}
annotations:
  {{- $ann | nindent 2 }}
{{- end }}
{{- end -}}

{{/*
Common metadata block for a cluster-scoped resource (no namespace).
Call with (dict "root" $root "name" <mapKey> "item" <item>).
*/}}
{{- define "nuc-external-secrets.clusterMetadata" -}}
{{- $root := .root -}}
{{- $item := .item | default dict -}}
{{- $name := .name -}}
name: {{ include "nuc-external-secrets.fullname" (dict "context" $root "name" $name) }}
labels:
  {{- include "nuc-external-secrets.resourceLabels" (dict "root" $root "item" $item) | nindent 2 }}
{{- $ann := include "nuc-external-secrets.resourceAnnotations" (dict "root" $root "item" $item) | trim }}
{{- if and $ann (ne $ann "{}") }}
annotations:
  {{- $ann | nindent 2 }}
{{- end }}
{{- end -}}

{{/*
Render a single namespaced resource. Call with:
  (dict "root" $root "name" <key> "item" <item> "kind" <ESO Kind> "apiVersionKey" <kindCamel>)
*/}}
{{- define "nuc-external-secrets.renderNamespacedResource" -}}
{{- $root := .root -}}
{{- $item := .item -}}
{{- $name := .name -}}
{{- $kind := .kind -}}
{{- $apiKey := .apiVersionKey -}}
{{- $apiVersion := $item.apiVersion | default (index $root.Values.apiVersions $apiKey) -}}
apiVersion: {{ $apiVersion }}
kind: {{ $kind }}
metadata:
  {{- include "nuc-external-secrets.namespacedMetadata" (dict "root" $root "name" $name "item" $item) | nindent 2 }}
spec:
  {{- include "nuc-external-secrets.mergedSpec" (dict "root" $root "item" $item "kind" $apiKey) | nindent 2 }}
{{- with $item.status }}
status:
  {{- toYaml . | nindent 2 }}
{{- end }}
{{- end -}}

{{/*
Render a single cluster-scoped resource. Same args as renderNamespacedResource.
*/}}
{{- define "nuc-external-secrets.renderClusterResource" -}}
{{- $root := .root -}}
{{- $item := .item -}}
{{- $name := .name -}}
{{- $kind := .kind -}}
{{- $apiKey := .apiVersionKey -}}
{{- $apiVersion := $item.apiVersion | default (index $root.Values.apiVersions $apiKey) -}}
apiVersion: {{ $apiVersion }}
kind: {{ $kind }}
metadata:
  {{- include "nuc-external-secrets.clusterMetadata" (dict "root" $root "name" $name "item" $item) | nindent 2 }}
spec:
  {{- include "nuc-external-secrets.mergedSpec" (dict "root" $root "item" $item "kind" $apiKey) | nindent 2 }}
{{- with $item.status }}
status:
  {{- toYaml . | nindent 2 }}
{{- end }}
{{- end -}}
