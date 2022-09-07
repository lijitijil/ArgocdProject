{{/* vim: set filetype=mustache: */}}
{{/*
Expand the name of the chart.
*/}}
{{- define "mongodb.name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{- define "mongodb.labels.selector" -}}
app: {{ template "mongodb.name" . }}
group: {{ .Values.mongodb.labels.group }}
provider: {{ .Values.mongodb.labels.provider }}
{{- end -}}

{{- define "mongodb.labels.stakater" -}}
{{ template "mongodb.labels.selector" . }}
version: "{{ .Values.mongodb.labels.version }}"
{{- end -}}

{{- define "mongodb.labels.chart" -}}
chart: "{{ .Chart.Name }}-{{ .Chart.Version }}"
release: {{ .Release.Name | quote }}
heritage: {{ .Release.Service | quote }}
{{- end -}}