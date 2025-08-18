terraform {
  required_providers {
    helm = {
      source  = "hashicorp/helm"
      version = "3.0.2"
    }
    kubernetes = {
      source  = "hashicorp/kubernetes"
      version = "2.38.0"
    }
  }
}

resource "helm_release" "this" {
  name             = "rancher"
  repository       = "https://releases.rancher.com/server-charts/latest"
  chart            = "rancher"
  version          = "2.12.0"
  namespace        = "cattle-system"
  create_namespace = true

  set = [
    {
      name  = "ingress.ingressClassName"
      value = "nginx"
    },
    {
      name  = "hostname"
      value = "rancher.mottacode.com"
    },
    {
      name  = "tls"
      value = "external"
    },
    {
      name  = "bootstrapPassword"
      value = var.bootstrap_password
    },
    {
      name  = "replicas"
      value = 1
    },
    {
      name  = "startupProbe.periodSeconds"
      value = 10
    },
    {
      name  = "startupProbe.failureThreshold"
      value = 60
    },
    {
      name  = "readinessProbe.initialDelaySeconds"
      value = 60
    },
    {
      name  = "livenessProbe.initialDelaySeconds"
      value = 60
    }
  ]
}
