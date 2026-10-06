**purga completa y ordenada de todo el contenido del cluster si fuera necesaria limpieza**

***Se elimina todo lo relacionado con elementos atascados, dejando el cluster limpio para empezar de cero.***

#### Checklist

##### Confirma que tienes:

- El kubeconfig funcionando (`kubectl get nodes` responde)
- Backup de cualquier YAML importante (deployment, pvc, service)
- Confirmado que quieres borrar el namespace `namespace-atascado` completo

## PASO 1: Ver qué hay en el cluster

```bash
export KUBECONFIG=~/Escritorio/Proliant\ Cluster/kubeconfig

# Ver TODOS los namespaces
kubectl get namespaces

# Ver qué hay en namespace-atascado
kubectl get all,pvc,configmap,secret,serviceaccount -n namespace-atascado

# Ver TODOS los PVCs (importante: verificar que no haya nada crítico)
kubectl get pvc -A

# Ver TODOS los PVs
kubectl get pv
```

## PASO 2: Backup de seguridad (por si acaso)

```bash
# Crear directorio de backup
mkdir -p ~/Escritorio/Proliant\ Cluster/backup-purga-$(date +%Y%m%d)

# Backup del namespace completo
kubectl get all,pvc,configmap,secret,serviceaccount,ingress,networkpolicy -n namespace-atascado -o yaml > ~/Escritorio/Proliant\ Cluster/backup-purga-$(date +%Y%m%d)/namespace-atascado-backup.yaml

# Backup de los PVs (estos NO se borran con el namespace)
kubectl get pv -o yaml > ~/Escritorio/Proliant\ Cluster/backup-purga-$(date +%Y%m%d)/pv-backup.yaml

echo "Backup guardado en: ~/Escritorio/Proliant Cluster/backup-purga-$(date +%Y%m%d)/"
```

### PASO Importante: Desinstalar el Helm release (IMPORTANTE hacerlo primero)

```bash
# Ver si está instalado por Helm

helm list -n truemetal-storage

# Desinstalar (esto limpia el provisioner correctamente)

helm uninstall nfs-provisioner -n truemetal-storage 2>/dev/null || echo "No hay release de Helm, continuando..."
```
## PASO 3: Eliminación ordenada (respetando dependencias)

El orden importa porque Kubernetes valida dependencias. Vamos de arriba hacia abajo:

### 3.1 - Eliminar los deployments

```bash
# Eliminar deployment de ansible-runner
kubectl delete deployment ansible-runner -n namespace-atascado --ignore-not-found

# Eliminar deployment del provisioner
kubectl delete deployment nfs-provisioner-nfs-subdir-external-provisioner -n namespace-atascado --ignore-not-found
```

### 3.2 - Eliminar los services

```bash
kubectl delete service ansible-runner-ssh -n namespace-atascado --ignore-not-found
kubectl delete service --all -n namespace-atascado --ignore-not-found
```

### 3.3 - Eliminar los pods atascados (forzado)

```bash
# Eliminar TODOS los pods del namespace con force
kubectl delete pods --all -n namespace-atascado --force --grace-period=0 --ignore-not-found
```

### 3.4 - Eliminar ReplicaSets huérfanos

```bash
kubectl delete replicaset --all -n namespace-atascado --ignore-not-found
```

### 3.5 - Eliminar el PVC

```bash
kubectl delete pvc ansible-data -n namespace-atascado --ignore-not-found

# Verificar que no queden PVCs en ese namespace
kubectl get pvc -n namespace-atascado
```

### 3.6 - Eliminar el Namespace completo

Ahora que está casi vacío, eliminamos el namespace:

```bash
kubectl delete namespace namespace-atascado
```

**Esto puede tardar. Si se queda atascado, sigue al paso 4.**

## PASO 4: Si el namespace se queda en "Terminating"

Si después de 5 minutos sigue en `Terminating`, hay que forzar:

```bash
# Ver el estado
kubectl get namespace namespace-atascado

# Si está atascado, ver qué recursos quedan
kubectl api-resources --verbs=list --namespaced -o name | \
  xargs -n 1 kubectl get --show-kind --ignore-not-found -n namespace-atascado

# Forzar eliminación del namespace
kubectl get namespace namespace-atascado -o json | \
  jq '.spec.finalizers = []' | \
  kubectl replace --raw "/api/v1/namespaces/namespace-atascado/finalize" -f -
```

Si no tienes `jq` instalado:

```bash
sudo apt install jq -y
```

## PASO 5: Limpiar PVs huérfanos (los que quedaron del NFS)

Los PVs son recursos de cluster, no de namespace. Después de eliminar el namespace, pueden quedar PVs en estado `Released`:

```bash
# Ver PVs
kubectl get pv

# Si hay PVs en estado "Released" o "Failed" relacionados con ansible, elimínalos:
kubectl delete pv <nombre-del-pv> --ignore-not-found
```

## PASO 6: Verificación final

```bash
# 1. Ver namespaces restantes (solo deberían quedar los del sistema)
kubectl get namespaces

# 2. Verificar que no hay pods en namespace-atascado
kubectl get pods -n namespace-atascado 2>&1 | head -5

# 3. Ver PVs restantes
kubectl get pv

# 4. Ver PVCs en todo el cluster
kubectl get pvc -A

# 5. Estado de nodos
kubectl get nodes
```

## PASO 7: Script completo de purga (opcional)

Si prefieres ejecutar todo de una vez, guarda esto como `purga-total.sh`:

```bash
cat > ~/Escritorio/Proliant\ Cluster/purga-total.sh << 'EOF'
#!/bin/bash
export KUBECONFIG=~/Escritorio/Proliant\ Cluster/kubeconfig
NS="namespace-atascado"

echo "=== PURGA COMPLETA DE $NS ==="
read -p "¿Confirmas la eliminación total del namespace $NS? (si/no): " confirm
if [ "$confirm" != "si" ]; then
  echo "Cancelado"
  exit 0
fi

echo ""
echo "1. Backup..."
mkdir -p ~/Escritorio/Proliant\ Cluster/backup-purga-$(date +%Y%m%d)
kubectl get all,pvc,configmap,secret -n $NS -o yaml > ~/Escritorio/Proliant\ Cluster/backup-purga-$(date +%Y%m%d)/backup.yaml 2>/dev/null

echo "2. Eliminando deployments..."
kubectl delete deployment --all -n $NS --ignore-not-found

echo "3. Eliminando services..."
kubectl delete service --all -n $NS --ignore-not-found

echo "4. Eliminando pods (force)..."
kubectl delete pods --all -n $NS --force --grace-period=0 --ignore-not-found

echo "5. Eliminando replicasets..."
kubectl delete replicaset --all -n $NS --ignore-not-found

echo "6. Eliminando PVCs..."
kubectl delete pvc --all -n $NS --ignore-not-found

echo "7. Eliminando configmaps..."
kubectl delete configmap --all -n $NS --ignore-not-found

echo "8. Eliminando secrets..."
kubectl delete secret --all -n $NS --ignore-not-found

echo "9. Eliminando namespace..."
kubectl delete namespace $NS

echo ""
echo "=== Estado final ==="
kubectl get namespaces
kubectl get pv
kubectl get pvc -A
EOF

chmod +x ~/Escritorio/Proliant\ Cluster/purga-total.sh
```

## Después de la purga

Tu cluster quedará limpio con solo:

- Namespaces del sistema (`kube-system`, `kube-public`, `kube-node-lease`, `default`)
- Pods del sistema (coredns, kube-proxy, flannel, etc.)
- Sin rastro de `namespace-atascado`

## Advertencia importante

**NO ejecutes el Paso 5 (eliminar PVs) sin revisar primero.** Algunos PVs pueden ser compartidos. Solo elimina los que claramente son de del pod atascado o degradado:

```bash
# Ver PVs con detalle
kubectl get pv -o wide
```
---
## PASO 10: Verificación final

```bash
echo "=== NAMESPACES ==="
kubectl get namespaces

echo ""
echo "=== PVs ==="
kubectl get pv

echo ""
echo "=== PVCs ==="
kubectl get pvc -A

echo ""
echo "=== PODS en namespace-atascado ==="
kubectl get pods -n namespace-atascado 2>&1 | head -3

echo ""
echo "=== NODOS ==="
kubectl get nodes

# Verifiquemos qué StorageClasses quedan
echo ""
echo "=== STORAGECLASS ==="
kubectl get storageclass

```
### El orden importa -> Deployments -> Services -> Pods -> ReplicaSets -> PVC -> Namespace -> PV