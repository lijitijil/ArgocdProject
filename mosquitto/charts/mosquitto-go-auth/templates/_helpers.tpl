{{/* vim: set filetype=mustache: */}}
{{/*
Expand the name of the chart.
*/}}
{{- define "mosquitto.name" -}}
{{- default .Chart.Name .Values.nameOverride | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{/*
Create a default fully qualified app name.
We truncate at 63 chars because some Kubernetes name fields are limited to this (by the DNS naming spec).
If release name contains chart name it will be used as a full name.
*/}}
{{- define "mosquitto.fullname" -}}
{{- if .Values.fullnameOverride -}}
{{- .Values.fullnameOverride | trunc 63 | trimSuffix "-" -}}
{{- else -}}
{{- $name := default .Chart.Name .Values.nameOverride -}}
{{- if contains $name .Release.Name -}}
{{- .Release.Name | trunc 63 | trimSuffix "-" -}}
{{- else -}}
{{- printf "%s-%s" .Release.Name $name | trunc 63 | trimSuffix "-" -}}
{{- end -}}
{{- end -}}
{{- end -}}

{{/*
Create chart name and version as used by the chart label.
*/}}
{{- define "mosquitto.chart" -}}
{{- printf "%s-%s" .Chart.Name .Chart.Version | replace "+" "_" | trunc 63 | trimSuffix "-" -}}
{{- end -}}

{{/*
Common labels
*/}}
{{- define "mosquitto.labels" -}}
app.kubernetes.io/name: mosquitto
app.kubernetes.io/instance: {{ .Release.Name }}
app.kubernetes.io/managed-by: {{ .Release.Service }}
helm.sh/chart: {{ include "mosquitto.chart" . }}
{{- end -}}

{{/*
Selector labels
*/}}
{{- define "mosquitto.selector" -}}
app.kubernetes.io/name: mosquitto
app.kubernetes.io/instance: {{ .Release.Name }}
{{- end -}}

{{/*
Create the name of the service account to use
*/}}
{{- define "mosquitto.serviceAccountName" -}}
{{- if .Values.serviceAccount.create -}}
    {{ default (include "mosquitto.fullname" .) .Values.serviceAccount.name }}
{{- else -}}
    {{ default "default" .Values.serviceAccount.name }}
{{- end -}}
{{- end -}}

{{/*
Creates a comma separated list of backends for the mosquitto auth plugin
*/}}
{{- define "mosquitto.auth.backends" -}}
{{- $outer := . -}}
{{- $backends := "auth_opt_backends" -}}
    {{- range $ids, $backend := tuple "files" "postgres" "mysql" "sqlite" "jwt" "http" "redis" "mongodb" "grpc" "javascript" -}}
    {{- $backendConfig := get $outer $backend -}}
        {{- if $backendConfig.enabled -}}
            {{- $backends = printf "%s %s," $backends $backend -}}
        {{- end -}}
    {{- end -}}
{{- $backends | trimSuffix "," -}}
{{- end -}}

{{/*
Creates a comma separated list of prefixes for backends of the mosquitto auth plugin
*/}}
{{- define "mosquitto.auth.prefixes" -}}
{{- $outer := . -}}
{{- $prefixes := "auth_opt_prefixes" -}}
    {{- range $ids, $backend := tuple "files" "postgres" "mysql" "sqlite" "jwt" "http" "redis" "mongodb" "grpc" "javascript" -}}
    {{- $backendConfig := get $outer $backend -}}
        {{- if $backendConfig.enabled -}}
            {{- $prefix := default $backend $backendConfig.prefix -}}
            {{- $prefixes = printf "%s %s," $prefixes $prefix -}}
        {{- end -}}
    {{- end -}}
{{- $prefixes | trimSuffix "," -}}
{{- end -}}

{{/*
Options for files backend
*/}}
{{- define "mosquitto.auth.files.config" -}}
##################################
# files backend                  #
##################################
auth_opt_files_password_path {{ .Values.auth.files.passwordPath }}
auth_opt_files_acl_path {{ .Values.auth.files.aclPath }}
{{- end -}}

{{- define "mosquitto.auth.jwt.jwtHost" -}}
{{ .Values.auth.jwt.jwtHost }}
{{- end -}}

{{- define "mosquitto.auth.jwt.jwtPgHost" -}}
{{ .Values.auth.jwt.jwtPgHost }}
{{- end -}}

{{- define "mosquitto.auth.jwt.jwtMysqlHost" -}}
{{ .Values.auth.jwt.jwtMysqlHost }}
{{- end -}}

{{/*
Options for jwt backend
*/}}
{{- define "mosquitto.auth.jwt.config" -}}
{{- $jwtConfig := .Values.auth.jwt -}}
##################################
# jwt backend                    #
##################################
auth_opt_jwt_mode {{ $jwtConfig.mode }}
# General options
{{ if $jwtConfig.parseToken -}}
auth_opt_jwt_parse_token {{ $jwtConfig.parseToken }}
{{- end }}
{{ if $jwtConfig.secret -}}
auth_opt_jwt_secret {{ $jwtConfig.secret }}
{{- end }}
{{ if $jwtConfig.userfield -}}
auth_opt_jwt_userfield {{ $jwtConfig.userfield }}
{{- end }}
{{ if $jwtConfig.skipUserExpiration -}}
auth_opt_jwt_skip_user_expiration {{ $jwtConfig.skipUserExpiration }}
{{- end }}
{{ if $jwtConfig.skipAclExpiration -}}
auth_opt_jwt_skip_acl_expiration {{ $jwtConfig.skipAclExpiration }}
{{- end }}
{{ if eq $jwtConfig.mode "remote" -}}
# remote mode options
{{- $jwtHostTemplate := default "mosquitto.auth.jwt.jwtHost" $jwtConfig.jwtHostTemplate }}
auth_opt_jwt_host {{ include $jwtHostTemplate . }}
auth_opt_jwt_port {{ $jwtConfig.jwtPort }}
auth_opt_jwt_getuser_uri {{ $jwtConfig.jwtGetuserUri }}
auth_opt_jwt_aclcheck_uri {{ $jwtConfig.jwtAclcheckUri }}
    {{ if $jwtConfig.jwtSuperuserUri -}}
auth_opt_jwt_superuser_uri {{ $jwtConfig.jwtSuperuserUri }}
    {{- end }}
    {{ if $jwtConfig.jwtWithTls -}}
auth_opt_jwt_with_tls {{ $jwtConfig.jwtWithTls }}
    {{- end }}
    {{ if $jwtConfig.jwtVerifyPeer -}}
auth_opt_jwt_verify_peer {{ $jwtConfig.jwtVerifyPeer }}
    {{- end }}
    {{ if $jwtConfig.jwtResponseMode -}}
auth_opt_jwt_response_mode {{ $jwtConfig.jwtResponseMode }}
    {{- end }}
    {{ if $jwtConfig.jwtParamsMode -}}
auth_opt_jwt_params_mode {{ $jwtConfig.jwtParamsMode }}
    {{- end }}
{{- end }}
{{ if eq $jwtConfig.mode "local" -}}
# local mode options
auth_opt_jwt_db {{ $jwtConfig.jwtDb }}
auth_opt_jwt_userquery {{ $jwtConfig.jwtUserquery }}
    {{ if eq $jwtConfig.jwtDb "postgres" -}}
{{- $jwtPgHostTemplate := default "mosquitto.auth.jwt.jwtPgHost" $jwtConfig.jwtPgHostTemplate }}
auth_opt_jwt_pg_host {{ include $jwtPgHostTemplate . }}
auth_opt_jwt_pg_port {{ $jwtConfig.jwtPgPort }}
auth_opt_jwt_pg_user {{ $jwtConfig.jwtPgUser }}
auth_opt_jwt_pg_password {{ $jwtConfig.jwtPgPassword }}
auth_opt_jwt_pg_dbname {{ $jwtConfig.jwtPgDbname }}
        {{ if $jwtConfig.jwtPgSslmode -}}
auth_opt_jwt_pg_sslmode {{ $jwtConfig.jwtPgSslmode }}
        {{- end }}
        {{ if $jwtConfig.jwtPgSslcert -}}
auth_opt_jwt_pg_sslcert {{ $jwtConfig.jwtPgSslcert }}
        {{- end }}
        {{ if $jwtConfig.jwtPgSslkey -}}
auth_opt_jwt_pg_sslkey {{ $jwtConfig.jwtPgSslkey }}
        {{- end }}
        {{ if $jwtConfig.jwtPgSslrootcert -}}
auth_opt_jwt_pg_sslrootcert {{ $jwtConfig.jwtPgSslrootcert }}
        {{- end }}
        {{ if $jwtConfig.jwtPgConnectTries -}}
auth_opt_jwt_pg_connect_tries {{ $jwtConfig.jwtPgConnectTries }}
        {{- end }}
    {{- end }}
    {{ if eq $jwtConfig.jwtDb "mysql" -}}
{{- $jwtMysqlHostTemplate := default "mosquitto.auth.jwt.jwtMysqlHost" .jwtMysqlHostTemplate }}
auth_opt_jwt_mysql_host {{ include $jwtMysqlHostTemplate . }}
auth_opt_jwt_mysql_port {{ $jwtConfig.jwtMysqlPort }}
auth_opt_jwt_mysql_user {{ $jwtConfig.jwtMysqlUser }}
auth_opt_jwt_mysql_password {{ $jwtConfig.jwtMysqlPassword }}
auth_opt_jwt_mysql_dbname {{ $jwtConfig.jwtMysqlDbname }}
        {{ if $jwtConfig.jwtMysqlSslmode -}}
auth_opt_jwt_mysql_sslmode {{ $jwtConfig.jwtMysqlSslmode }}
        {{- end }}
        {{ if $jwtConfig.jwtMysqlSslcert -}}
auth_opt_jwt_mysql_sslcert {{ $jwtConfig.jwtMysqlSslcert }}
        {{- end }}
        {{ if $jwtConfig.jwtMysqlSslkey -}}
auth_opt_jwt_mysql_sslkey {{ $jwtConfig.jwtMysqlSslkey }}
        {{- end }}
        {{ if $jwtConfig.jwtMysqlSslrootcert -}}
auth_opt_jwt_mysql_sslrootcert {{ $jwtConfig.jwtMysqlSslrootcert }}
        {{- end }}
        {{ if $jwtConfig.jwtMysqlProtocol -}}
auth_opt_jwt_mysql_protocol {{ $jwtConfig.jwtMysqlProtocol }}
        {{- end }}
        {{ if $jwtConfig.jwtMysqlSocket -}}
auth_opt_jwt_mysql_socket {{ $jwtConfig.jwtMysqlSocket }}
        {{- end }}
        {{ if $jwtConfig.jwtMysqlConnectTries -}}
auth_opt_jwt_mysql_connect_tries {{ $jwtConfig.jwtMysqlConnectTries }}
        {{- end }}
    {{- end }}
{{- end }}
{{ if eq $jwtConfig.mode "js" -}}
auth_opt_jwt_js_user_script_path {{ $jwtConfig.jwtJsUserScriptPath }}
auth_opt_jwt_js_superuser_script_path {{ $jwtConfig.jwtJsSuperuserScriptPath }}
auth_opt_jwt_js_acl_script_path {{ $jwtConfig.jwtJsAclScriptPath }}
        {{ if $jwtConfig.jwtJsStackDepthLimit -}}
auth_opt_jwt_js_stack_depth_limit {{ $jwtConfig.jwtJsStackDepthLimit }}
        {{- end }}
        {{ if $jwtConfig.jwtJsMsMaxDuration -}}
auth_opt_jwt_js_ms_max_duration {{ $jwtConfig.jwtJsMsMaxDuration }}
        {{- end }}
{{- end }}
{{ if eq $jwtConfig.mode "files" -}}
auth_opt_jwt_files_acl_path {{ $jwtConfig.jwtFilesAclPath }}
{{- end }}
{{- end -}}
