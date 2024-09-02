provider "google" {
  project = "web-chess-425815"
  region  = "europe-central2"
}

module "label" {
  source  = "cloudposse/label/null"
  version = "0.25.0"

  namespace   = "web-chess"
  stage       = "prod"
  name        = "gke"
  environment = "europe-central2"
  attributes  = ["public"]

  id_length_limit = 40

  context = module.this.context
}

resource "google_compute_address" "default" {
  name = module.label.id
}

resource "google_dns_managed_zone" "default" {
  name = module.label.id

  dns_name = "${var.domain}."
}

resource "google_dns_record_set" "a" {
  name = google_dns_managed_zone.default.dns_name

  managed_zone = google_dns_managed_zone.default.name
  type         = "A"
  ttl          = 30

  rrdatas = [google_compute_address.default.address]
}

resource "google_dns_record_set" "cname" {
  name = join(".", compact(["www", google_dns_record_set.a.name]))

  managed_zone = google_dns_managed_zone.default.name
  type         = "CNAME"
  ttl          = 30

  rrdatas = [google_dns_record_set.a.name]
}

resource "google_container_cluster" "default" {
  name = module.label.id

  location                 = module.label.environment
  node_locations           = ["${module.label.environment}-a"]
  deletion_protection      = false
  remove_default_node_pool = true
  initial_node_count       = 1

  ip_allocation_policy {}
}

resource "google_container_node_pool" "default" {
  name    = module.label.id
  cluster = google_container_cluster.default.id

  node_config {
    preemptible  = true
    machine_type = "e2-medium"
    disk_size_gb = 20
  }

  autoscaling {
    min_node_count = 0
    max_node_count = 10
  }

  lifecycle {
    ignore_changes = [
      initial_node_count,
      node_count,
      node_config,
      node_locations
    ]
  }

  depends_on = [google_container_cluster.default]
}

# Configure kubernetes provider with Oauth2 access token.
# https://registry.terraform.io/providers/hashicorp/google/latest/docs/data-sources/client_config
# This fetches a new token, which will expire in 1 hour.
data "google_client_config" "default" {
  depends_on = [google_container_cluster.default]
}

provider "helm" {
  kubernetes {
    host  = "https://${google_container_cluster.default.endpoint}"
    token = data.google_client_config.default.access_token
    cluster_ca_certificate = base64decode(
      google_container_cluster.default.master_auth[0].cluster_ca_certificate,
    )
  }
}

resource "helm_release" "ingress_nginx" {
  name = module.label.namespace

  repository = "https://kubernetes.github.io/ingress-nginx"
  chart      = "ingress-nginx"
  namespace  = "ingress-nginx"
  version    = "4.10.1"

  create_namespace = true

  set {
    name  = "controller.service.loadBalancerIP"
    value = google_compute_address.default.address
  }
}

resource "helm_release" "certificate_manager" {
  name = module.label.namespace

  repository = "https://charts.jetstack.io"
  chart      = "cert-manager"
  namespace  = "cert-manager"
  version    = "1.14.5"

  create_namespace = true

  set {
    name  = "startupapicheck.timeout"
    value = "5m"
  }
  set {
    name  = "global.leaderElection.namespace"
    value = "cert-manager"
  }
  set {
    name  = "installCRDs"
    value = "true"
  }
}

resource "helm_release" "nats" {
  name = "nats"

  repository = "https://nats-io.github.io/k8s/helm/charts/"
  chart      = "nats"
  version    = "1.1.12"
}

