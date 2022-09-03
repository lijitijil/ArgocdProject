kubectl create namespace grafana
helm repo add grafana https://grafana.github.io/helm-charts
helm install grafana grafana/grafana -n grafana