# infra/monitoring.tf
resource "docker_image" "prometheus" {
  name         = "prom/prometheus:latest"
  keep_locally = true
}

resource "docker_container" "prometheus" {
  name    = "prometheus"
  image   = docker_image.prometheus.image_id
  restart = "unless-stopped"
  networks_advanced { name = docker_network.cicd.name }
  ports {
    internal = 9090
    external = 9090
  }
  upload {
    file   = "/etc/prometheus/prometheus.yml"
    source = abspath("${path.module}/../monitoring/prometheus.yml")
  }
  upload {
    file   = "/etc/prometheus/alerts.yml"
    source = abspath("${path.module}/../monitoring/alerts.yml")
  }
}

resource "docker_image" "grafana" {
  name         = "grafana/grafana:latest"
  keep_locally = true
}

resource "docker_container" "grafana" {
  name    = "grafana"
  image   = docker_image.grafana.image_id
  restart = "unless-stopped"
  networks_advanced { name = docker_network.cicd.name }
  ports {
    internal = 3000
    external = 3000
  }
  env = ["GF_SECURITY_ADMIN_PASSWORD=admin"]
}
