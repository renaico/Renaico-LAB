# 🛡️ Plataforma DevSecOps on Talos Linux & Kubernetes

[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)
[![Kubernetes](https://img.shields.io/badge/Kubernetes-1.30-blue)](https://kubernetes.io)
[![Talos](https://img.shields.io/badge/Talos-1.7-green)](https://www.talos.dev)
[![Security Scan](https://github.com/yourusername/talos-k8s-devsecops/actions/workflows/security-scan.yml/badge.svg)](https://github.com/renaico/talos-k8s-devsecops/actions)

## 📋 Descripción

Infraestructura Kubernetes hardening con **Talos Linux** (sistema operativo inmutable y API-only), **almacenamiento persistente** via CSI (Rook/Ceph/Longhorn), y **DevSecOps pipeline** con seguridad integrada en todas las capas.

### 🎯 Objetivos
- Cluster Kubernetes altamente seguro sin acceso SSH
- Storage persistente resiliente con backups automáticos
- CI/CD con escaneo de vulnerabilidades, SBOM y políticas OPA
- Monitoreo de runtime con Falco y cumplimiento CIS benchmarks

### 🏗️ Componentes principales
| Capa | Tecnología |
|------|-------------|
| OS | Talos Linux (inmutable, sin SSH ni shell) |
| Orquestación | Kubernetes (kubeadm + Talos bootstrap) |
| Storage | Rook/Ceph (o Longhorn) + CSI snapshots |
| Seguridad | Falco, OPA/Gatekeeper, Trivy, Vault |
| Observabilidad | Prometheus + Grafana + Loki |
| CI/CD | GitLab CI / GitHub Actions |

## 🚀 Inicio rápido

### Requisitos previos
```bash
# Herramientas necesarias
talosctl version  # v1.7+
kubectl version   # v1.30+
helm version      # v3.14+
terraform version # v1.7+