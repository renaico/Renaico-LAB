#  Guía de Comandos de Verificación para Kubernetes

## Rol: DevOps Senior  Checklist de Diagnóstico

Esta guía reúne los comandos esenciales para **verificar, diagnosticar y depurar** cualquier despliegue en Kubernetes. Están organizados por categoría y son **genéricos** (reemplaza los placeholders `<...>` por tus valores reales).

---

##  Convenciones de Placeholders

| Placeholder        | Significado                             |
| ------------------ | --------------------------------------- |
| `<namespace>`    | Namespace objetivo                      |
| `<pod>`          | Nombre del Pod                          |
| `<deployment>`   | Nombre del Deployment                   |
| `<service>`      | Nombre del Service                      |
| `<pvc>`          | Nombre del PersistentVolumeClaim        |
| `<pv>`           | Nombre del PersistentVolume             |
| `<storageclass>` | Nombre del StorageClass                 |
| `<label>`        | Selector de etiqueta (ej:`app=miapp`) |
| `<node>`         | Nombre del nodo                         |

---

## 1 Verificación General del Clúster

### Estado de nodos y namespaces

```bash
# Nodos con IPs y versión
kubectl get nodes -o wide

# Namespaces existentes
kubectl get namespaces

# Todos los recursos de todos los namespaces
kubectl get all -A

# Recursos de un namespace específico
kubectl get all -n <namespace>

# Eventos ordenados por tiempo (¡clave para debugging!)
kubectl get events -n <namespace> --sort-by='.lastTimestamp'

# Eventos de todo el clúster
kubectl get events -A --sort-by='.lastTimestamp'
```

### Estado de salud del clúster

```bash
# Información del clúster
kubectl cluster-info

# API resources disponibles
kubectl api-resources

# Versión del servidor y cliente
kubectl version

# Uso de recursos por nodo
kubectl top nodes

# Uso de recursos por pod
kubectl top pods -n <namespace>
```

---

## 2 Verificación de Pods

### Listado y estado

```bash
# Pods con IP y nodo asignado
kubectl get pods -n <namespace> -o wide

# Pods de TODOS los namespaces (útil para ver todo)
kubectl get pods -A -o wide

# Pods filtrados por label
kubectl get pods -n <namespace> -l <label>

# Pods en formato YAML (para inspección completa)
kubectl get pod <pod> -n <namespace> -o yaml

# Pods ordenados por reinicios (para detectar CrashLoopBackOff)
kubectl get pods -n <namespace> --sort-by='.status.containerStatuses[0].restartCount'
```

### Monitoreo en tiempo real

```bash
# Watch: ver cambios en vivo
kubectl get pods -n <namespace> -w

# Watch con formato wide
kubectl get pods -n <namespace> -o wide -w
```

### Descripción detallada (LO MÁS IMPORTANTE para debugging)

```bash
# Describe completo del Pod (incluye eventos, probes, volumes)
kubectl describe pod <pod> -n <namespace>

# Describe filtrando solo los eventos (útil cuando el output es largo)
kubectl describe pod <pod> -n <namespace> | tail -30

# Describe por label (todos los pods de un deployment)
kubectl describe pod -n <namespace> -l <label>
```

---

## 3 Verificación de Logs

### Logs básicos

```bash
# Logs del Pod
kubectl logs <pod> -n <namespace>

# Logs en tiempo real (follow)
kubectl logs -f <pod> -n <namespace>

# Últimas N líneas
kubectl logs <pod> -n <namespace> --tail=50

# Logs de las últimas 2 horas
kubectl logs <pod> -n <namespace> --since=2h

# Logs desde un timestamp específico
kubectl logs <pod> -n <namespace> --since-time="2026-05-13T16:00:00Z"
```

### Logs por Deployment (más cómodo)

```bash
# Logs del deployment (elige un pod automáticamente)
kubectl logs -n <namespace> deployment/<deployment>

# Follow del deployment
kubectl logs -n <namespace> -f deployment/<deployment>

# Últimas 100 líneas del deployment
kubectl logs -n <namespace> deployment/<deployment> --tail=100
```

### Logs por label

```bash
# Logs de todos los pods con un label (requiere stern o kubetail)
kubectl logs -n <namespace> -l <label> --tail=50

# Con stern (herramienta externa recomendada)
stern <pod-prefix> -n <namespace>

# Con kubetail (otra alternativa)
kubetail <pod-prefix> -n <namespace>
```

### Logs anteriores (tras un reinicio)

```bash
# Logs del contenedor ANTES del último reinicio (crítico para CrashLoopBackOff)
kubectl logs <pod> -n <namespace> --previous

# Alias: --previous = -p
kubectl logs <pod> -n <namespace> -p
```

### Logs de contenedores múltiples

```bash
# Si el Pod tiene varios contenedores, especifica cuál
kubectl logs <pod> -n <namespace> -c <container-name>

# Ver los contenedores del Pod primero
kubectl get pod <pod> -n <namespace> -o jsonpath='{.spec.containers[*].name}'
```

---

## 4 Verificación de Deployments

```bash
# Listar deployments
kubectl get deployments -n <namespace>

# Estado detallado del deployment
kubectl describe deployment <deployment> -n <namespace>

# Historial de rollouts
kubectl rollout history deployment/<deployment> -n <namespace>

# Estado del rollout actual
kubectl rollout status deployment/<deployment> -n <namespace>

# ReplicaSets asociados al deployment (útil para ver versiones)
kubectl get replicasets -n <namespace> -l <label>
```

### Logs del controlador de deployments

```bash
# Ver eventos relacionados con el deployment
kubectl describe deployment <deployment> -n <namespace> | tail -20
```

---

## 5 Verificación de Services y Networking

```bash
# Listar services
kubectl get services -n <namespace>

# Detalles del service
kubectl describe service <service> -n <namespace>

# Endpoints (¿está el service apuntando a algún pod)
kubectl get endpoints -n <namespace>

# Endpoints del service específico
kubectl get endpoints <service> -n <namespace> -o yaml

# Ver si el selector del service coincide con algún pod
kubectl get pods -n <namespace> --show-labels

# Probar conectividad desde dentro del clúster
kubectl run -it --rm debug --image=alpine --restart=Never -n <namespace> -- sh
# Dentro: wget -qO- http://<service>:<port>
```

### NodePort e Ingress

```bash
# Ver NodePorts asignados
kubectl get svc -n <namespace> -o wide

# Detalles del NodePort
kubectl describe svc <service> -n <namespace>

# Ingress
kubectl get ingress -n <namespace>
kubectl describe ingress <ingress> -n <namespace>
```

---

## 6 Verificación de Almacenamiento (Storage)

### PersistentVolumeClaims (PVC)

```bash
# PVCs de un namespace
kubectl get pvc -n <namespace>

# PVCs de TODOS los namespaces
kubectl get pvc -A

# Detalles del PVC (incluye eventos de provisionamiento)
kubectl describe pvc <pvc> -n <namespace>

# PVC en YAML
kubectl get pvc <pvc> -n <namespace> -o yaml

# Monitorear hasta que se bindee
kubectl get pvc <pvc> -n <namespace> -w
```

### PersistentVolumes (PV)

```bash
# PVs del clúster (recurso de clúster, sin namespace)
kubectl get pv

# Detalles del PV
kubectl describe pv <pv>

# PV en formato YAML
kubectl get pv <pv> -o yaml

# Ver qué PVC está usando un PV
kubectl get pv <pv> -o jsonpath='{.spec.claimRef.name}'

# Ver qué PV usa un PVC
kubectl get pvc <pvc> -n <namespace> -o jsonpath='{.spec.volumeName}'
```

### StorageClasses

```bash
# Listar StorageClasses
kubectl get storageclass

# Alias corto
kubectl get sc

# Detalles del StorageClass
kubectl describe storageclass <storageclass>

# Ver el provisioner asociado
kubectl get storageclass <storageclass> -o yaml | grep provisioner
```

### Verificación de montaje NFS dentro del Pod

```bash
# Ver los mounts dentro del Pod
kubectl exec <pod> -n <namespace> -- mount | grep nfs

# Ver contenido del volumen montado
kubectl exec <pod> -n <namespace> -- ls -la /<mount-path>

# Verificar permisos de escritura
kubectl exec <pod> -n <namespace> -- touch /<mount-path>/test-file

# Ver el tamaño y uso del volumen
kubectl exec <pod> -n <namespace> -- df -h /<mount-path>
```

---

## 7 Acceso y Ejecución dentro de Pods

```bash
# Shell interactivo (bash)
kubectl exec -it <pod> -n <namespace> -- /bin/bash

# Shell si no hay bash (sh)
kubectl exec -it <pod> -n <namespace> -- /bin/sh

# Ejecutar comando específico
kubectl exec <pod> -n <namespace> -- <comando>

# Con contenedor específico
kubectl exec -it <pod> -n <namespace> -c <container> -- /bin/bash

# Ver procesos corriendo
kubectl exec <pod> -n <namespace> -- ps aux

# Ver puertos escuchando
kubectl exec <pod> -n <namespace> -- ss -tlnp

# Ver variables de entorno
kubectl exec <pod> -n <namespace> -- env
```

### Port-Forward (acceso local a servicios del clúster)

```bash
# Redirigir un puerto local al Pod
kubectl port-forward -n <namespace> pod/<pod> <local-port>:<remote-port>

# Redirigir al Service
kubectl port-forward -n <namespace> svc/<service> <local-port>:<remote-port>

# Redirigir al Deployment
kubectl port-forward -n <namespace> deployment/<deployment> <local-port>:<remote-port>

# Ejemplo: acceder a SSH de un Pod
kubectl port-forward -n <namespace> pod/<pod> 2222:22
# Luego: ssh -p 2222 user@localhost
```

---

## 8 Verificación de ConfigMaps y Secrets

```bash
# Listar ConfigMaps
kubectl get configmaps -n <namespace>

# Ver contenido de un ConfigMap
kubectl describe configmap <configmap> -n <namespace>

# Ver YAML del ConfigMap
kubectl get configmap <configmap> -n <namespace> -o yaml

# Listar Secrets
kubectl get secrets -n <namespace>

# Ver contenido de un Secret (decodificado)
kubectl get secret <secret> -n <namespace> -o jsonpath='{.data}' | jq
kubectl get secret <secret> -n <namespace> -o jsonpath='{.data.<key>}' | base64 -d
```

---

## 9 Verificación de Probes (Liveness/Readiness/Startup)

```bash
# Ver los probes definidos en el Pod
kubectl get pod <pod> -n <namespace> -o yaml | grep -A 10 "Probe"

# Ver eventos de fallo de probes
kubectl describe pod <pod> -n <namespace> | grep -i "probe\|unhealthy"

# Ver reinicios por fallo de liveness
kubectl get pods -n <namespace> -o wide --sort-by='.status.containerStatuses[0].restartCount'
```

---

##  Verificación de Helm (si aplica)

```bash
# Listar releases
helm list -A

# Listar releases en un namespace
helm list -n <namespace>

# Estado de un release
helm status <release> -n <namespace>

# Historial de un release
helm history <release> -n <namespace>

# Valores usados en un release
helm get values <release> -n <namespace>

# Manifiestos generados por un release
helm get manifest <release> -n <namespace>

# Ver qué recursos gestiona un release
kubectl get all -n <namespace> -l app.kubernetes.io/managed-by=Helm
```

---

## 11 Comandos de Limpieza y Reset (uso cuidadoso)

```bash
# Eliminar un Pod (será recreado por su controlador)
kubectl delete pod <pod> -n <namespace>

# Forzar eliminación de un Pod atascado
kubectl delete pod <pod> -n <namespace> --force --grace-period=0

# Eliminar un Deployment
kubectl delete deployment <deployment> -n <namespace>

# Eliminar un Service
kubectl delete service <service> -n <namespace>

# Eliminar un PVC
kubectl delete pvc <pvc> -n <namespace>

# Eliminar un PV (recurso de clúster)
kubectl delete pv <pv>

# Eliminar un namespace completo (¡cuidado!)
kubectl delete namespace <namespace>

# Reiniciar un Deployment (rolling restart)
kubectl rollout restart deployment/<deployment> -n <namespace>

# Deshacer un rollout
kubectl rollout undo deployment/<deployment> -n <namespace>

# Forzar eliminación de un namespace atascado
kubectl get namespace <namespace> -o json | \
  jq '.spec.finalizers = []' | \
  kubectl replace --raw "/api/v1/namespaces/<namespace>/finalize" -f -
```

---

## 12 Comandos Útiles para Documentación

```bash
# Exportar recursos a YAML (para backup)
kubectl get all,pvc,configmap,secret -n <namespace> -o yaml > backup.yaml

# Ver todos los recursos de un namespace con tipos
kubectl api-resources --verbs=list --namespaced -o name | \
  xargs -n 1 kubectl get --show-kind --ignore-not-found -n <namespace>

# Ver todos los recursos de un namespace (incluye CRDs)
kubectl get all,cm,secret,sa,ingress,networkpolicy,pvc,endpoints -n <namespace>

# Ver YAML de un recurso específico
kubectl get <tipo> <nombre> -n <namespace> -o yaml

# Ver JSON de un recurso específico
kubectl get <tipo> <nombre> -n <namespace> -o json

# Ver solo un campo específico (jsonpath)
kubectl get pod <pod> -n <namespace> -o jsonpath='{.status.podIP}'

# Ver con columnas personalizadas
kubectl get pods -n <namespace> -o custom-columns=\
NAME:.metadata.name,\
STATUS:.status.phase,\
NODE:.spec.nodeName,\
IP:.status.podIP
```

---

## 13 Comandos de Red dentro del Clúster

```bash
# Pod de debug temporal (se elimina al salir)
kubectl run -it --rm debug --image=nicolaka/netshoot --restart=Never -n <namespace> -- bash

# Con nslookup, dig, curl, tcpdump, etc.
kubectl run -it --rm debug --image=alpine --restart=Never -n <namespace> -- sh
# Dentro: apk add --no-cache curl bind-tools

# Probar DNS interno
kubectl run -it --rm dnstest --image=busybox:1.28 --restart=Never -- nslookup kubernetes.default

# Probar conectividad a un service
kubectl run -it --rm curltest --image=curlimages/curl --restart=Never -n <namespace> -- \
  curl -v http://<service>.<namespace>.svc.cluster.local:<port>
```

---

##  Checklist Rápido de Diagnóstico

Cuando algo falla, sigue este orden:

### 1. Estado general

```bash
kubectl get pods -n <namespace> -o wide
kubectl get events -n <namespace> --sort-by='.lastTimestamp' | tail -20
```

### 2. Detalle del recurso problemático

```bash
kubectl describe pod <pod> -n <namespace>
```

### 3. Logs

```bash
kubectl logs <pod> -n <namespace> --tail=100
kubectl logs <pod> -n <namespace> --previous    # Si hubo reinicio
```

### 4. Estado interno

```bash
kubectl exec -it <pod> -n <namespace> -- /bin/sh
# Dentro: ps aux, ss -tlnp, ls -la, env
```

### 5. Networking

```bash
kubectl get svc -n <namespace>
kubectl get endpoints -n <namespace>
```

### 6. Storage

```bash
kubectl get pvc -n <namespace>
kubectl describe pvc <pvc> -n <namespace>
```

---

##  Herramientas Externas Recomendadas

| Herramienta                | Uso                                    |
| -------------------------- | -------------------------------------- |
| **k9s**              | TUI completa para gestionar Kubernetes |
| **stern**            | Logs multi-pod en tiempo real          |
| **kubetail**         | Alternativa a stern                    |
| **kubectx / kubens** | Cambiar contexto/namespace rápido     |
| **kubectl-neat**     | Limpiar YAMLs de metadatos             |
| **popeye**           | Auditoría de salud del clúster       |
| **kube-score**       | Análisis estático de manifiestos     |
| **helm-diff**        | Ver cambios antes de aplicar           |
| **kustomize**        | Gestión de overlays de configuración |

---

##  Reglas de Oro del DevOps en Kubernetes

1. **Siempre empieza por `get events`**  el 80% de los problemas se ven ahí.
2. **`describe` antes que `logs`**  te da el contexto (probes, volumes, scheduling).
3. **`--previous` en logs**  imprescindible para CrashLoopBackOff.
4. **`-w` (watch)**  para ver la evolución en tiempo real.
5. **`-o wide`**  siempre que quieras ver IPs y nodos.
6. **`-o yaml`**  cuando necesites el detalle completo del recurso.
7. **Documenta cada gotcha**  los errores que resuelves hoy son la doc que agradecerás mañana.

---

Esta guía cubre el **ciclo completo de verificación** en Kubernetes: desde el estado del clúster hasta el diagnóstico profundo de un Pod con problemas de storage, networking o probes.