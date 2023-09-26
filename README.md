# Web-Chess-Infra

This is repository for infra of Web-Chess.

Defines microservices K8S structure.

## Development

Dependencies:

- Local K8S cluster
  - Docker: <https://www.docker.com/products/kubernetes/>
  - minikube: <https://minikube.sigs.k8s.io/docs/start/>
- Ingress Nginx: <https://kubernetes.github.io/ingress-nginx/>
- Skaffold: <https://skaffold.dev/>

The whole local cluster should be managed through skaffold. If properly configured, it will automatically provision and delete everything. Skaffold will also tail logs from all services.

Skaffold yaml expects microservices local repositories to be place in the same folder as infra.

Use `skaffold dev` for starting the local K8S cluster.
