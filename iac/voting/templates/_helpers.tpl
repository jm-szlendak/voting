{{/*
Expand the name of the chart.
*/}}
{{- define "voting.name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Create a default fully qualified app name.
We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
If release name contains chart name it will be used as a full name.
*/}}
{{- define "voting.fullname" -}}
{{- if .Values.fullnameOverride }}
{{- .Values.fullnameOverride | trunc 63 | trimSuffix "-" }}
{{- else }}
{{- $name := default .Chart.Name .Values.nameOverride }}
{{- if contains $name .Release.Name }}
{{- .Release.Name | trunc 63 | trimSuffix "-" }}
{{- else }}
{{- printf "%s-%s" .Release.Name $name | trunc 63 | trimSuffix "-" }}
{{- end }}
{{- end }}
{{- end }}

{{/*
Create chart name and version as used by the chart label.
*/}}
{{- define "voting.chart" -}}
{{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" }}
{{- end }}

{{/*
Common labels
*/}}
{{- define "voting.labels" -}}
helm.sh/chart: {{ include "voting.chart" . }}
{{ include "voting.selectorLabels" . }}
{{- if .Chart.AppVersion }}
app.kubernetes.io/version: {{ .Chart.AppVersion | quote }}
{{- end }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
{{- end }}

{{/*
Selector labels
*/}}
{{- define "voting.selectorLabels" -}}
app.kubernetes.io/name: {{ include "voting.name" . }}
app.kubernetes.io/instance: {{ .Release.Name }}
{{- end }}

{{/*
Create the name of the service account to use
*/}}
{{- define "voting.serviceAccountName" -}}
{{- if .Values.serviceAccount.create }}
{{- default (include "voting.fullname" .) .Values.serviceAccount.name }}
{{- else }}
{{- default "default" .Values.serviceAccount.name }}
{{- end }}
{{- end }}

{{/*
Expand the name of the chart.
*/}}
{{- define "voting.postgresql.secrets" -}}
{{- .Release.Name }}-postgresql
{{- end }}

{{/*
Expand the name of the chart.
*/}}
{{- define "voting.postgresql.host" -}}
{{- .Release.Name }}-postgresql
{{- end }}
{{/*
Expand the name of the chart.
*/}}
{{- define "voting.redis.secrets" -}}
{{- .Release.Name }}-redis
{{- end }}


{{/*
Expand the name of the chart.
*/}}
{{- define "voting.redis.host" -}}
{{- .Release.Name }}-redis-master
{{- end }}


{{/*
Expand the image
*/}}
{{- define "voting.image" -}}
{{- $registryUrl := .Values.global.image.registryUrl -}}
{{- $repository := .Values.image.repository -}}
{{- $tag := .Values.global.image.tag | default "latest" -}}
{{- printf "%s/%s:%s" $registryUrl $repository $tag -}}
{{- end }}