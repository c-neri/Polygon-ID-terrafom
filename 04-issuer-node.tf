resource "helm_release" "issuer-node" {
  name      = "polygon-id-issuer"
  chart     = "./helm"
  namespace = "default"

  values = [
    file("./helm/values.yaml")
  ]

  set {
    name  = "issuerName"
    value = "myIssuer"
  }
  
  
  set {
    name  = "namespace"
    value = "default"
  }

  set {
    name  = "uiPassword"
    value = "password"
  }

  set {
    name  = "uidomain"
    value = var.domain_name
  }

  set {
    name  = "appdomain"
    value = var.app_domain_name
  }

  set {
    name  = "apidomain"
    value = var.api_domain_name
  }

  set {
    name  = "privateKey"
    value = ""
  }

}
