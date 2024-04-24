
# Create new resource named "issuer_cluster" with thouse params
resource "digitalocean_kubernetes_cluster" "issuer_cluster" {
  name    = "issuer-node-cluster"
  region  = "nyc1"        # We can use other values, check from digital ocean api docs
  version = "1.29.1-do.0" # Get latest version => doctl kubernetes options versions

  node_pool {
    name       = "default-pool"
    size       = "s-4vcpu-8gb"
    node_count = 3
  }
}

data "digitalocean_kubernetes_cluster" "cluster_data" {
  name = digitalocean_kubernetes_cluster.issuer_cluster.name
}

provider "kubernetes" {
  host                   = data.digitalocean_kubernetes_cluster.cluster_data.endpoint
  token                  = data.digitalocean_kubernetes_cluster.cluster_data.kube_config[0].token
  cluster_ca_certificate = base64decode(data.digitalocean_kubernetes_cluster.cluster_data.kube_config[0].cluster_ca_certificate)
}

provider "kubectl" {
  host                   = data.digitalocean_kubernetes_cluster.cluster_data.endpoint
  token                  = data.digitalocean_kubernetes_cluster.cluster_data.kube_config[0].token
  cluster_ca_certificate = base64decode(data.digitalocean_kubernetes_cluster.cluster_data.kube_config[0].cluster_ca_certificate)
}

# Set helm to workj with my cluster
provider "helm" {
  kubernetes {
    host                   = data.digitalocean_kubernetes_cluster.cluster_data.endpoint
    token                  = data.digitalocean_kubernetes_cluster.cluster_data.kube_config[0].token
    cluster_ca_certificate = base64decode(data.digitalocean_kubernetes_cluster.cluster_data.kube_config[0].cluster_ca_certificate)
  }
}

resource "helm_release" "ingress_nginx" {
  depends_on = [digitalocean_kubernetes_cluster.issuer_cluster]
  name       = "ingress-nginx"
  repository = "https://kubernetes.github.io/ingress-nginx"
  chart      = "ingress-nginx"
  version    = "4.10.0"
  # values = [
  #   "${file("values.yaml")}"
  # ]
}

module "cert_manager" {
  depends_on = [digitalocean_kubernetes_cluster.issuer_cluster]
  source  = "terraform-iaac/cert-manager/kubernetes"
  version = "2.6.3"
  cluster_issuer_email                   = "email"
  cluster_issuer_name                    = "cert-manager-global" #Used for annotation
  certificates = {
    "nginx-certificate" = {
      dns_names = [var.domain_name, var.app_domain_name, var.api_domain_name] # Define which domains will be validated
    }
  }
}