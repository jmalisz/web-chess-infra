# Web-Chess-Infra

This is repository for infra of Web-Chess.

Defines GCP resources and K8S structure.

Available in only one region to reduce costs.

## Development

Dependencies:

- Local K8S cluster
  - Docker: <https://www.docker.com/products/kubernetes/>
  - minikube: <https://minikube.sigs.k8s.io/docs/start/>
- Ingress Nginx: <https://kubernetes.github.io/ingress-nginx/>
- NATS: <https://github.com/nats-io/k8s/tree/main/helm/charts/nats>
- Skaffold: <https://skaffold.dev/>

The whole local cluster should be managed through skaffold. If properly configured, it will automatically provision and delete everything. Skaffold will also tail logs from all services.

Skaffold yaml expects microservices local repositories to be place in the same folder as infra.

Use `skaffold dev` for starting the local K8S cluster.

## Production

Repository is connected to <https://spacelift.io/>, which executes the infrastructure changes based on PRs.
