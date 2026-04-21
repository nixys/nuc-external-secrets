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
{{- $annotations := mustMergeOverwrite (dict) ($root.Values.commonAnnotations | default dict) ($item.annotations | default dict) -}}
{{- toYaml $annotations -}}
{{- end -}}

{{- define "nuc-external-secrets.renderMetadata" -}}
{{- $root := .root -}}
{{- $item := .item | default dict -}}
metadata:
  name: {{ .name }}
{{- if .namespaced }}
  namespace: {{ default $root.Release.Namespace $item.namespace }}
{{- end }}
  labels:
{{ include "nuc-external-secrets.resourceLabels" (dict "root" $root "item" $item) | nindent 4 }}
  annotations:
{{ include "nuc-external-secrets.resourceAnnotations" (dict "root" $root "item" $item) | nindent 4 }}
{{- end -}}

{{- define "nuc-external-secrets.renderGenericResource" -}}
{{- $root := .root -}}
{{- $name := .name -}}
{{- $item := .item | default dict -}}
{{- $tplContext := include "nuc-external-secrets.tplContext" $root | fromYaml -}}
---
apiVersion: {{ default .defaultApiVersion $item.apiVersion }}
kind: {{ .kind }}
{{ include "nuc-external-secrets.renderMetadata" (dict "root" $root "item" $item "name" $name "namespaced" .namespaced) }}
{{- with $item.spec }}
spec:
{{ include "nuc-external-secrets.tplvalues.render" (dict "value" . "context" $tplContext) | nindent 2 }}
{{- end }}
{{- with $item.status }}
status:
{{ include "nuc-external-secrets.tplvalues.render" (dict "value" . "context" $tplContext) | nindent 2 }}
{{- end }}
{{- end -}}

{{- define "nuc-external-secrets.renderGenericResources" -}}
{{- if .root.Values.enabled }}
{{- $collection := .collection | default dict -}}
{{- range $name := keys $collection | sortAlpha }}
{{- $item := get $collection $name -}}
{{- if and (ne $name "__helm_docs_example__") $item }}
{{ include "nuc-external-secrets.renderGenericResource" (dict
  "root" $.root
  "name" $name
  "item" $item
  "kind" $.kind
  "defaultApiVersion" $.defaultApiVersion
  "namespaced" $.namespaced
) }}
{{- end }}
{{- end }}
{{- end }}
{{- end -}}
