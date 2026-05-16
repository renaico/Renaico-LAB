<!-- 
  README.md para el repositorio Renaico-LAB
  Repositorio de documentación y configuración del laboratorio DevSecOps personal.
  Incluye guías para Talos Linux, Kubernetes y buenas prácticas de seguridad.
-->

# 🛡️ Laboratorio DevSecOps HomeLab

<p align="center">
  <i>Infraestructura como Código | Kubernetes Hardening | Seguridad desde el Día 0</i>
  <br>
  <img src="https://img.shields.io/badge/Talos%20Linux-1.7-00AB58?logo=linux" alt="Talos Linux">
  <img src="https://img.shields.io/badge/Kubernetes-1.30-326CE5?logo=kubernetes" alt="Kubernetes">
  <img src="https://img.shields.io/badge/DevSecOps-Pipeline-FF6C37?logo=github-actions" alt="DevSecOps">
  <img src="https://img.shields.io/badge/Licencia-MIT-green" alt="MIT License">
</p>

Bienvenido al repositorio central de mi laboratorio personal de **DevSecOps**. Este proyecto documenta el proceso de construcción y operación de un clúster Kubernetes de producción en casa, utilizando **Talos Linux** para maximizar la seguridad, **Rook/Ceph** para almacenamiento persistente y herramientas de vanguardia en ciberseguridad.

El objetivo es tener un entorno reproducible, seguro y resiliente, aplicando las mejores prácticas de **Infraestructura como Código (IaC)** y una pipeline de **seguridad integrada**.

## 🎯 Objetivos del Proyecto

-   **Seguridad por diseño:** Desplegar un clúster Kubernetes inmutable y sin acceso SSH usando Talos Linux.
-   **Almacenamiento Resiliente:** Proveer persistencia de datos con CSI (Rook/Ceph) y backups automáticos.
-   **Pipeline DevSecOps:** Integrar análisis de vulnerabilidades (SAST), generación de SBOM y políticas OPA en el ciclo de vida.
-   **Observabilidad y Monitoreo:** Centralizar logs, métricas y trazas con el stack Prometheus, Grafana y Loki.
-   **Automatización total:** Poder recrear todo el entorno desde cero con scripts y archivos de configuración.

## 🏗️ Arquitectura y Componentes

La plataforma se compone de las siguientes capas tecnológicas:

| Capa | Tecnología | Propósito |
| :--- | :--- | :--- |
| **Sistema Operativo** | Talos Linux | OS minimalista, inmutable, gestionado por API. Sin SSH ni shell. |
| **Orquestación** | Kubernetes (kubeadm) | Gestión de contenedores y servicios. |
| **Almacenamiento** | Rook / Ceph | Almacenamiento persistente, block, file y object storage. |
| **Seguridad** | Falco, OPA/Gatekeeper, Trivy | Monitoreo de runtime, políticas de seguridad, escaneo de imágenes. |
| **Observabilidad** | Prometheus, Grafana, Loki | Métricas, dashboards y agregación de logs. |
| **CI/CD** | GitHub Actions | Automatización de pruebas y despliegues. |

## 📂 Estructura del Repositorio

Este repositorio está organizado para facilitar la navegación y el mantenimiento:

```text
Renaico-LAB/
├── readme.md                 # Este archivo. La guía principal.
├── Estructuracion.md         # Documento sobre la organización del LAB.
├── 01_Infraestructura/
│   ├── Guia Administracion.md  # Procedimientos diarios de gestión del clúster.
│   └── ...                     # Archivos Terraform, configuraciones Talos, etc.
├── 02_imagenes/              # Diagramas y capturas de pantalla.
│   └── ...                     # Recursos visuales para la documentación.
└── 03_Documentacion/         # (Opcional) Podrías crear esta carpeta en el futuro.
    └── ...                     # Guías específicas de seguridad, storage, etc.