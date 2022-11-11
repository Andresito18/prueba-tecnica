git clone https://github.com/kubernetes/charts
cd charts
git checkout efdcffe0b6973111ec6e5e83136ea74cdbe6527d
sleep 3
helm install -f ~/prometheus-values.yml ~/charts/stable/prometheus --name prometheus --namespace prometheus

cd ~/
git clone https://github.com/kubernetes/charts

helm install -f ~/grafana-values.yml ~/charts/stable/grafana --name grafana --namespace grafana


kubectl apply -f deploy/*