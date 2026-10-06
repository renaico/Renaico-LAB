# Renaico-LAB

### Laboratorio personal de Infraestructura, Automatización, DevOps y Ciberseguridad

## Usuario Renaico
Hola soy el usuario renaico,  un profesional de infraestructura, redes y ciberseguridad con más de una década trabajando directamente con tecnología en entornos reales. Mi experiencia abarca redes, MikroTik, Linux, Windows Server, virtualización, Proxmox, VMware, almacenamiento, servidores, servicios web, VPN, routing, firewalls, monitoreo y soporte de infraestructura. Con los años mi foco se ha ido desplazando hacia la automatización, la seguridad y la administración de infraestructura mediante código. Me gusta entender cómo funcionan las cosas, resolver problemas y, cuando encuentro una tarea que se repite, buscar la forma de automatizarla. Renaico-LAB es el espacio donde llevo esa experiencia a un entorno propio para experimentar, equivocarme, reconstruir y documentar. Actualmente estoy integrando virtualización, Kubernetes, Talos Linux, almacenamiento, Ansible y próximamente Wazuh. No busca ser una infraestructura perfecta, sino un registro vivo de lo que sé hacer, lo que estoy aprendiendo y hacia dónde quiero llevar mi forma de trabajar.

**Renaico-LAB** es mi laboratorio personal orientado al diseño, implementación, administración y automatización de infraestructura tecnológica.

El proyecto nació como un entorno para reutilizar hardware y recursos de cómputo disponibles, pero ha evolucionado progresivamente hacia una plataforma de experimentación donde puedo construir, romper, recuperar, automatizar y documentar infraestructura de manera reproducible.

El objetivo no es simplemente mantener máquinas funcionando.

El objetivo es **convertir infraestructura en conocimiento reproducible**.

---

## Qué estoy construyendo

Renaico-LAB reúne distintas capas de infraestructura y operación:

```text
┌──────────────────────────────────────────────────────┐
│                    Renaico-LAB                       │
├──────────────────────────────────────────────────────┤
│                                                      │
│  Infraestructura                                     │
│  ├── Virtualización / Proxmox                        │
│  ├── Hardware reutilizado                            │
│  └── Inventario y documentación                      │
│                                                      │
│  Plataforma                                           │
│  ├── Talos Linux                                     │
│  ├── Kubernetes                                      │
│  └── TrueNAS / NFS                                  │
│                                                      │
│  Automatización                                       │
│  ├── Ansible                                         │
│  ├── Playbooks Linux                                 │
│  ├── Playbooks Windows                               │
│  └── PowerShell                                      │
│                                                      │
│  Seguridad                                            │
│  └── Wazuh                                           │
│      (siguiente etapa)                               │
│                                                      │
└──────────────────────────────────────────────────────┘
```

La arquitectura está en evolución permanente. Algunas tecnologías se encuentran implementadas, otras están en desarrollo y otras forman parte de futuras etapas del laboratorio.

---

## Principios del laboratorio

### Construir antes que teorizar

Las tecnologías incorporadas al LAB se estudian principalmente mediante implementación real.

La idea es enfrentar problemas reales de infraestructura, resolverlos y posteriormente documentar el procedimiento.

### Documentar el camino

La documentación no busca únicamente describir el estado final.

También registra decisiones, errores, diagnósticos, procedimientos de recuperación y lecciones aprendidas.

Un problema resuelto una vez puede convertirse posteriormente en un procedimiento reproducible.

### Automatizar lo repetitivo

Cuando una tarea puede transformarse en un procedimiento automatizado, se busca llevarla progresivamente hacia código.

Esto permite pasar de:

```text
"sé cómo hacerlo"
```

a:

```text
"puedo reproducirlo"
```

y posteriormente a:

```text
"puedo administrarlo de manera consistente"
```

### Experimentar de forma controlada

El LAB permite probar tecnologías y arquitecturas que posteriormente pueden convertirse en conocimiento aplicable a otros entornos.

No todo lo que se prueba termina formando parte de la arquitectura definitiva.

---

# Infraestructura

La primera capa del proyecto corresponde a la infraestructura física y virtual sobre la cual se construye el resto del laboratorio.

Aquí se mantienen inventarios de hardware y máquinas virtuales, documentación de la plataforma y procedimientos generales de administración.

La infraestructura también sirve como base para experimentar con distintas arquitecturas de virtualización, almacenamiento, redes y servicios.

## Kubernetes sobre Talos Linux

Una de las principales plataformas del LAB es un clúster Kubernetes construido sobre Talos Linux.

El clúster fue implementado sobre máquinas virtuales distribuidas entre distintos hosts de virtualización.

Actualmente la documentación contempla un clúster de ocho máquinas Talos, incluyendo el nodo Control Plane y los workers. El proceso de implementación está documentado desde la preparación de las máquinas hasta la configuración, bootstrap y obtención del `kubeconfig`.

[Implementación del clúster](01_Infraestructura/Cluster%20Implementation.md)

Talos permite experimentar con una arquitectura Kubernetes basada en un sistema operativo minimalista e inmutable, administrado mediante herramientas específicas como `talosctl`.

---

# Almacenamiento

El laboratorio utiliza TrueNAS como parte de la infraestructura de almacenamiento.

El almacenamiento NFS se utiliza para proporcionar persistencia a servicios desplegados sobre Kubernetes.

Esto permite experimentar con la relación entre:

```text
TrueNAS
   │
   └── NFS
        │
        └── Kubernetes Storage
              │
              └── Persistent Volumes / PVC
```

La persistencia es especialmente relevante para servicios que necesitan sobrevivir a la recreación o migración de workloads.

---

# Administración de Kubernetes

El LAB mantiene documentación operacional para administrar y diagnosticar el clúster.

Entre otros procedimientos se documentan:

* configuración de `talosctl`
* bootstrap del clúster
* administración de nodos
* generación y utilización de `kubeconfig`
* revisión de workloads
* diagnóstico de pods
* análisis de eventos
* revisión de recursos
* procedimientos de limpieza
* recuperación ante problemas de despliegue

[Guía de administración](01_Infraestructura/Guia%20de%20Administracion.md)

[Guía de acción para Kubernetes](01_Infraestructura/kubernetes_guia_de_accion.md)

[Guía de limpieza general](01_Infraestructura/Guia_de_Limpieza_General.md)

La documentación de operación es considerada parte de la infraestructura y no un elemento separado de ella.

---

# Automatización con Ansible

Actualmente una de las principales líneas de desarrollo del LAB es Ansible.

El objetivo es pasar progresivamente desde la administración manual de máquinas hacia una infraestructura donde las tareas recurrentes puedan ser definidas y ejecutadas mediante playbooks.

El entorno de Ansible está desplegado dentro del propio laboratorio y utiliza almacenamiento persistente mediante NFS.

La arquitectura actual contempla un nodo de control basado en un workload de Kubernetes:

```text
Kubernetes
    │
    └── namespace: ansible
          │
          └── ansible-runner
                 │
                 └── Persistent Storage
                        │
                        └── TrueNAS / NFS
```

[Construcción del ambiente Ansible](03_Apps/03-1-Ansible/Contruccion%20del%20ambiente.md)

[Despliegue del controlador Ansible](03_Apps/03-1-Ansible/Deploy_Ansible_controller.md)

---

## Administración de Windows

Uno de los primeros objetivos de automatización es la administración de máquinas Windows.

El LAB utiliza WinRM/SSH según el escenario y mantiene proyectos de Ansible específicos para experimentar con tareas habituales de administración.

Actualmente existen playbooks para:

* verificación de conectividad
* recopilación de información del sistema
* administración de usuarios
* instalación de actualizaciones
* aplicación de actualizaciones de seguridad y críticas
* administración de definiciones
* automatización de tareas de mantenimiento

Ejemplos:

[site.yml](03_Apps/03-1-Ansible/Projects-playbooks/Windows/site.yml)

[testuser.yml](03_Apps/03-1-Ansible/Projects-playbooks/Windows/testuser.yml)

[winupdates.yml](03_Apps/03-1-Ansible/Projects-playbooks/Windows/winupdates.yml)

---

## Incorporación de equipos Windows a Ansible

También se está desarrollando el proceso de incorporación de máquinas Windows al sistema de automatización.

El script `deliver-ssh-key.ps1` permite automatizar parte del proceso de preparación de un equipo Windows para su administración mediante SSH.

Esto forma parte de una idea más amplia:

```text
Equipo nuevo
     │
     ▼
Preparación
     │
     ▼
Acceso automatizado
     │
     ▼
Ansible
     │
     ├── Usuarios
     ├── Firewall
     ├── Actualizaciones
     └── Configuración
```

[How to deploy key](03_Apps/03-1-Ansible/How_to_deploy_key.md)

[deliver-ssh-key.ps1](03_Apps/03-1-Ansible/deliver-ssh-key.ps1)

---

# Administración Linux

La automatización no está limitada a Windows.

También se están construyendo procedimientos para administrar sistemas Linux y servicios asociados al almacenamiento NFS.

Esto permite utilizar Ansible como una capa común de administración sobre sistemas heterogéneos.

[ansible-ubuntu-nfs.yaml](03_Apps/03-1-Ansible/ansible-ubuntu-nfs.yaml)

---

# Infraestructura como código y configuración reproducible

El proyecto avanza progresivamente hacia un modelo donde la infraestructura y su operación puedan representarse mediante archivos versionados.

Esto incluye:

* manifiestos Kubernetes
* configuración de servicios
* inventarios
* playbooks
* scripts
* procedimientos
* documentación técnica

El objetivo no es alcanzar una abstracción perfecta desde el primer día.

La prioridad es transformar progresivamente el conocimiento operacional en artefactos versionables y reproducibles.

---

# Seguridad

La seguridad constituye una línea transversal del proyecto.

No se considera una etapa que deba agregarse únicamente al final, sino una característica que debe acompañar la construcción de infraestructura y automatización.

La siguiente etapa importante del LAB será la incorporación de **Wazuh**.

El objetivo será construir una plataforma de seguridad que permita experimentar con:

* agentes
* monitoreo de endpoints
* detección
* análisis de eventos
* integridad de archivos
* vulnerabilidades
* alertas
* centralización de información de seguridad

La implementación de Wazuh será desarrollada como una nueva etapa del laboratorio.

---

# Evolución del proyecto

Renaico-LAB no pretende permanecer estático.

La evolución actual puede resumirse de la siguiente manera:

```text
Hardware
   │
   ▼
Virtualización
   │
   ▼
Infraestructura
   │
   ▼
Kubernetes
   │
   ▼
Almacenamiento persistente
   │
   ▼
Ansible
   │
   ▼
Automatización
   │
   ▼
Wazuh
   │
   ▼
Seguridad y observabilidad
   │
   ▼
DevSecOps
```

Cada etapa se construye sobre la anterior.

El propósito final es disponer de un entorno donde infraestructura, automatización, operación y seguridad puedan trabajar como un sistema integrado.

---

# Estructura del repositorio

La estructura actual se organiza principalmente por grandes áreas:

```text
Renaico-LAB/
│
├── 01_Infraestructura/
│   ├── documentación de infraestructura
│   ├── inventarios
│   ├── hardware
│   ├── Kubernetes
│   ├── Talos
│   └── procedimientos operacionales
│
├── 02_Imagenes/
│   └── recursos visuales y evidencias
│
├── 03_Apps/
│   └── 03-1-Ansible/
│       ├── documentación
│       ├── manifests Kubernetes
│       ├── scripts
│       └── Projects-playbooks/
│           └── Windows/
│
└── README.md
```

La estructura puede cambiar a medida que el proyecto crece. La organización del repositorio es parte del propio proceso de diseño del LAB.

---

# Estado actual

### Implementado / operativo

* Infraestructura virtualizada para el laboratorio.
* Inventario de hardware y máquinas virtuales.
* Clúster Kubernetes sobre Talos Linux.
* Control Plane y nodos worker Talos.
* Administración mediante `talosctl`.
* Administración mediante `kubectl`.
* TrueNAS.
* Almacenamiento NFS.
* Persistencia mediante Kubernetes.
* Controlador Ansible desplegado sobre Kubernetes.
* Persistencia del entorno Ansible mediante NFS.
* Automatización inicial de sistemas Windows.
* Automatización inicial de sistemas Linux.
* Administración automatizada de usuarios.
* Automatización de Windows Update.
* Automatización de incorporación mediante SSH.
* Documentación operacional y procedimientos de recuperación.

### En desarrollo

* Consolidación de playbooks Ansible.
* Estandarización de proyectos e inventarios.
* Mayor automatización de infraestructura.
* Integración entre administración y seguridad.
* Implementación de Wazuh.

### Futuro

El roadmap del LAB seguirá evolucionando a medida que las necesidades y experimentos del proyecto lo requieran.

No todas las tecnologías previstas tienen necesariamente que terminar formando parte de la arquitectura final.

---

# Filosofía del proyecto

Renaico-LAB es un entorno de aprendizaje práctico.

Aquí los errores forman parte del proceso.

Una configuración que falla puede convertirse en:

```text
Error
  ↓
Diagnóstico
  ↓
Solución
  ↓
Documentación
  ↓
Automatización
  ↓
Conocimiento reproducible
```

El objetivo no es demostrar que una tecnología puede instalarse.

El objetivo es comprenderla suficientemente para poder **implementarla, administrarla, diagnosticarla, recuperarla y posteriormente automatizarla**.

---

## Objetivo a largo plazo

Construir progresivamente una plataforma personal de laboratorio que permita desarrollar y demostrar capacidades en:

**Infraestructura · Linux · Windows · Virtualización · Kubernetes · Automatización · Ansible · Redes · Almacenamiento · Ciberseguridad · DevOps · DevSecOps**

Renaico-LAB es, sobre todo, un registro vivo de ese proceso.

> **Build it. Break it. Understand it. Automate it. Secure it.**
