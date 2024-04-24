# NAMESPACE
resource "kubernetes_namespace" "kubernetes_dashboard" {
  metadata {
    name = "kubernetes-dashboard"
  }
}

# SERVICE ACCOUNT
resource "kubernetes_service_account" "admin_user" {
  metadata {
    name      = "admin-user"
    namespace = kubernetes_namespace.kubernetes_dashboard.metadata[0].name
  }
}

# BIND ROLE
resource "kubernetes_cluster_role_binding" "admin_user" {
  metadata {
    name = "admin-user"
  }

  role_ref {
    api_group = "rbac.authorization.k8s.io"
    kind      = "ClusterRole"
    name      = "cluster-admin"
  }

  subject {
    kind      = "ServiceAccount"
    name      = kubernetes_service_account.admin_user.metadata[0].name
    namespace = kubernetes_service_account.admin_user.metadata[0].namespace
  }
}

# DASHBOARD
resource "helm_release" "kubernetes_dashboard" {
  depends_on = [
    kubernetes_service_account.admin_user,
    kubernetes_cluster_role_binding.admin_user
  ]

  lifecycle {
    create_before_destroy = true
  }

  name       = "kubernetes-dashboard"
  repository = "https://kubernetes.github.io/dashboard/"
  chart      = "kubernetes-dashboard"
  version    = "7.0.0"
  namespace = kubernetes_namespace.kubernetes_dashboard.metadata[0].name

  set {
    name  = "ingress.enabled"
    value = "false"
  }

}