{{- define "nuc-external-secrets.name" -}}
{{- default .Release.Name .Values.nameOverride | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{- define "nuc-external-secrets.chart" -}}
{{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{- define "nuc-external-secrets.fullname" -}}
{{- if .name -}}
{{- if .context.Values.releasePrefix -}}
{{- printf "%s-%s" .context.Values.releasePrefix .name | trunc 63 | trimAll "-" -}}
{{- else -}}
{{- printf "%s-%s" (include "nuc-external-secrets.name" .context) .name | trunc 63 | trimSuffix "-" -}}
{{- end -}}
{{- else -}}
{{- include "nuc-external-secrets.name" .context -}}
{{- end -}}
{{- end -}}

{{- define "nuc-external-secrets.labels" -}}
app.kubernetes.io/name: {{ include "nuc-external-secrets.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
helm.sh/chart: {{ include "nuc-external-secrets.chart" . }}
{{- if .Chart.AppVersion }}
app.kubernetes.io/version: {{ .Chart.AppVersion | quote }}
{{- end }}
{{- end -}}

{{- define "nuc-external-secrets.hookAnnotations" -}}
helm.sh/hook: pre-install,pre-upgrade
helm.sh/hook-weight: "1"
helm.sh/hook-delete-policy: before-hook-creation
{{- end -}}

{{- define "nuc-external-secrets.tplvalues.render" -}}
{{- if typeIs "string" .value -}}
{{- tpl .value .context -}}
{{- else -}}
{{- tpl (.value | toYaml) .context -}}
{{- end -}}
{{- end -}}

{{- define "nuc-external-secrets.tplContext" -}}
{{- $tplContext := deepCopy . -}}
{{- if .Values.global -}}
{{- $_ := set $tplContext "Values" (mergeOverwrite (deepCopy .Values.global) .Values) -}}
{{- end -}}
{{- $tplContext | toYaml -}}
{{- end -}}

{{- define "nuc-external-secrets.resourceLabels" -}}
{{- $root := .root -}}
{{- $item := .item | default dict -}}
{{- $labels := mustMergeOverwrite (dict) (include "nuc-external-secrets.labels" $root | fromYaml) ($root.Values.commonLabels | default dict) ($item.labels | default dict) -}}
{{- toYaml $labels -}}
{{- end -}}

{{- define "nuc-external-secrets.resourceAnnotations" -}}
{{- $root := .root -}}
{{- $item := .item | default dict -}}
{{- $annotations := mustMergeOverwrite (dict) (include "nuc-external-secrets.hookAnnotations" $root | fromYaml) ($root.Values.commonAnnotations | default dict) ($item.annotations | default dict) -}}
{{- toYaml $annotations -}}
{{- end -}}

{{- define "nuc-external-secrets.renderMetadata" -}}
{{- $root := .root -}}
{{- $item := .item | default dict -}}
{{- $clusterScoped := .clusterScoped -}}
metadata:
  name: {{ .name }}
  {{- if not $clusterScoped }}
  namespace: {{ default $root.Release.Namespace $item.namespace }}
  {{- end }}
  labels:
{{ include "nuc-external-secrets.resourceLabels" (dict "root" $root "item" $item) | nindent 4 }}
  annotations:
{{ include "nuc-external-secrets.resourceAnnotations" (dict "root" $root "item" $item) | nindent 4 }}
{{- end -}}

{{/*
Merged spec = generic.<kindCamel> + item.spec (item wins). Arrays replace wholesale.
Call with (dict "root" $root "item" $item "kindCamel" "externalSecret").
*/}}
{{- define "nuc-external-secrets.mergedSpec" -}}
{{- $root := .root -}}
{{- $item := .item | default dict -}}
{{- $kindCamel := .kindCamel -}}
{{- $generic := dict -}}
{{- if and $root.Values.generic (hasKey $root.Values.generic $kindCamel) -}}
{{- $generic = deepCopy (index $root.Values.generic $kindCamel) -}}
{{- end -}}
{{- $itemSpec := deepCopy ($item.spec | default dict) -}}
{{- $merged := mustMergeOverwrite $generic $itemSpec -}}
{{- toYaml $merged -}}
{{- end -}}

{{/*
Render a single resource (namespaced or cluster-scoped). Call with:
  (dict "root" $root "name" <mapKey> "item" <item>
        "kind" "ExternalSecret" "kindCamel" "externalSecret"
        "clusterScoped" false)
*/}}
{{- define "nuc-external-secrets.renderResource" -}}
{{- $root := .root -}}
{{- $name := .name -}}
{{- $item := .item | default dict -}}
{{- $kind := .kind -}}
{{- $kindCamel := .kindCamel -}}
{{- $clusterScoped := .clusterScoped -}}
{{- $tplContext := include "nuc-external-secrets.tplContext" $root | fromYaml -}}
{{- $apiVersion := $item.apiVersion | default (index $root.Values.apiVersions $kindCamel) -}}
---
apiVersion: {{ $apiVersion }}
kind: {{ $kind }}
{{ include "nuc-external-secrets.renderMetadata" (dict "root" $root "item" $item "name" $name "clusterScoped" $clusterScoped) }}
spec:
{{ include "nuc-external-secrets.tplvalues.render" (dict "value" (include "nuc-external-secrets.mergedSpec" (dict "root" $root "item" $item "kindCamel" $kindCamel) | fromYaml) "context" $tplContext) | nindent 2 }}
{{- with $item.status }}
status:
{{ include "nuc-external-secrets.tplvalues.render" (dict "value" . "context" $tplContext) | nindent 2 }}
{{- end }}
{{- end -}}

{{/*
Render every active item in a resource collection. Call with:
  (dict "root" $ "collection" .Values.externalSecrets "kind" "ExternalSecret"
        "kindCamel" "externalSecret" "clusterScoped" false)
Placeholder entries and null/enabled-false items are skipped.
*/}}
{{- define "nuc-external-secrets.renderResources" -}}
{{- $collection := .collection | default dict -}}
{{- range $name := keys $collection | sortAlpha }}
{{- $item := get $collection $name -}}
{{- if ne $name "__helm_docs_example__" -}}
{{- $active := true -}}
{{- if not $item -}}{{- $active = false -}}{{- end -}}
{{- if and $item (hasKey $item "enabled") (not $item.enabled) -}}{{- $active = false -}}{{- end -}}
{{- if $active }}
{{ include "nuc-external-secrets.renderResource" (dict
  "root" $.root
  "name" $name
  "item" $item
  "kind" $.kind
  "kindCamel" $.kindCamel
  "clusterScoped" $.clusterScoped
) }}
{{- end -}}
{{- end -}}
{{- end -}}
{{- end -}}