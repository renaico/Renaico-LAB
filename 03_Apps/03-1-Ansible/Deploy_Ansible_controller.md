# Despliegue de un POD Ansible, Nodo de control.

---

### Paso 1: Crear namespace

```bash
kubectl create namespace ansible
```

### Paso 2: Crear PVC

```Bash
nano ansible-pvc-truenas-nfs.yaml
```

```yaml
apiVersion: v1
kind: PersistentVolumeClaim
metadata:
  name: ansible-data
  namespace: ansible
spec:
  accessModes:
    - ReadWriteMany
  resources:
    requests:
      storage: 20Gi
  storageClassName: truenas-nfs
```

### Paso 3: Crear deployment de ansible runner
```yaml
apiVersion: apps/v1
kind: Deployment
metadata:
  name: ansible-runner
  namespace: ansible
  labels:
    app: ansible-runner
spec:
  replicas: 1
  selector:
    matchLabels:
      app: ansible-runner
  template:
    metadata:
      labels:
        app: ansible-runner
    spec:
      # fsGroup asigna el grupo 1000 (ansible) a todos los volúmenes montados automáticamente
      securityContext:
        fsGroup: 1000
      containers:
      - name: ansible
        image: ubuntu:22.04
        env:
        - name: DEBIAN_FRONTEND
          value: noninteractive
        - name: LANG
          value: en_US.UTF-8
        - name: LC_ALL
          value: en_US.UTF-8
        command: ["/bin/bash", "-c"]
        args:
        - |
          set -e
          echo "=== Actualizando repositorios e instalando paquetes básicos ==="
          apt-get update
          apt-get install -y --no-install-recommends \
            openssh-server \
            sudo \
            python3 \
            python3-pip \
            python3-argcomplete \
            curl \
            wget \
            git \
            vim \
            iputils-ping \
            net-tools \
            rsync \
            locales \
            ca-certificates

          echo "=== Configurando Locales ==="
          sed -i 's/# en_US.UTF-8 UTF-8/en_US.UTF-8 UTF-8/' /etc/locale.gen
          locale-gen
          echo "LANG=en_US.UTF-8" > /etc/default/locale

          echo "=== Instalando Ansible y dependencias para Windows (WinRM) ==="
          pip3 install --upgrade pip
          pip3 install ansible pywinrm requests-ntlm

          echo "=== Configurando Servidor SSH ==="
          mkdir -p /var/run/sshd
          ssh-keygen -A

          sed -i 's/#PermitRootLogin prohibit-password/PermitRootLogin yes/' /etc/ssh/sshd_config
          sed -i 's/#PasswordAuthentication yes/PasswordAuthentication yes/' /etc/ssh/sshd_config
          sed -i 's/#PubkeyAuthentication yes/PubkeyAuthentication yes/' /etc/ssh/sshd_config

          echo "=== Creando usuario ansible ==="
          if ! id ansible >/dev/null 2>&1; then
            useradd -u 1000 -m -d /home/ansible -s /bin/bash ansible
            echo "ansible:ansible123" | chpasswd
            echo "ansible ALL=(ALL) NOPASSWD:ALL" > /etc/sudoers.d/ansible
            chmod 0440 /etc/sudoers.d/ansible
          fi

          echo "=== Configurando claves SSH ==="
          mkdir -p /home/ansible/.ssh
          
          cat > /home/ansible/.ssh/authorized_keys << 'KEY'
          ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAQDTxty2xndH7/w62LuLfoeJ4UKx+nHZWvAzCWjeU8+ZCfRHZf+1ncWKwfwiG/su2O2sVn1LYv7NX2NI5RGEADorWIT36MB1sTo8w3twIA9VENWYBQirk9rsMTwhD4ANsVFdRjEuRxS2RvPT5ZJ/CqkdSOAZ0nFyAF6fpwWa80wKaoBXVC3tgtUZWMkBsYW4jgQvfFT4cRiMEfgrpEUxfkFQbACvRUNuOQ3H30/XUK7hWaRTp8LkC05Z4ljw75VTWP9pVeurLxnmJXEHxlJmenWZ6kj1gz6LPkECwR7v/25PRf2//ec5wVqOLeBKcxM296aLAkl4b9inlhGq+q2j0VogHgcd15ToHnX+2q8IljSwSxtQR0bgTOQLTEYUE5Qf67hpLvDA0FZ0cC28q3B18dxu4lGCXgX0amMZDPRMk5YFTWjvvYYkLU1OERSwQ+pm9NF0nSA8oOiMIutkuLSyjb4h66Yoy2baL+F7nfFvlH6d0OQ7n+9z0GObi1DT+JnDFGsMFtozI3LAzKsD4wymOhVhYRDXYS/9a3m3U4aKxPiORHt9TAtzXlfCDqIVEQeWdNvL8GvOkpCTO1HvrVlOLdemdcQgUN0tyvNmuID4lIxt2KQnIleD+8XdewYBPu/c0Tq5CeySN976OsUXpujBuMxeMEMt4/QXy7OXAdm+2ERDkQ== renaico@INFRMBM1
          KEY

          chown -R 1000:1000 /home/ansible
          chmod 700 /home/ansible/.ssh
          chmod 600 /home/ansible/.ssh/authorized_keys

          echo "=== Creando directorio en el PVC ==="
          mkdir -p /ansible-data/projects
          chmod -R 777 /ansible-data || true

          echo "=== Iniciando Servicio SSH ==="
          exec /usr/sbin/sshd -D -e
        workingDir: /ansible-data
        ports:
        - containerPort: 22
          name: ssh
        volumeMounts:
        - mountPath: /ansible-data
          name: ansible-storage
        resources:
          requests:
            cpu: "500m"
            memory: "1Gi"
          limits:
            cpu: "1000m"
            memory: "2Gi"
        livenessProbe:
          tcpSocket:
            port: 22
          initialDelaySeconds: 40
          periodSeconds: 20
        startupProbe:
          tcpSocket:
            port: 22
          initialDelaySeconds: 15
          periodSeconds: 10
          failureThreshold: 30 
        readinessProbe:
          tcpSocket:
            port: 22
          initialDelaySeconds: 20
          periodSeconds: 10
      volumes:
      - name: ansible-storage
        persistentVolumeClaim:
          claimName: ansible-data
```

### Paso 4: Service

```yaml
apiVersion: v1
kind: Service
metadata:
  name: ansible-runner-ssh
  namespace: truemetal-storage
spec:
  type: NodePort
  selector:
    app: ansible-runner
  ports:
  - port: 22
    targetPort: 22
    nodePort: 31022  # Puerto fijo para acceso externo (30000-32767)
    protocol: TCP
  externalTrafficPolicy: Cluster
```

## Flujo final

```bash
# 1. Crear namespace
kubectl create namespace ansible

# 2. Aplicar PVC
kubectl apply -f ansible-pvc-truenas-nfs.yaml
kubectl get pvc -n ansible -w   # Esperar a "Bound"

# 3. Aplicar Deployment
kubectl apply -f ansible-ubuntu-nfs.yaml
kubectl get pods -n ansible -w

# 4. Aplicar Service
kubectl apply -f ansible-service-nfs.yaml
kubectl get svc -n ansible

# 5. Ver logs (verificar que SSH arrancó)
kubectl logs -n ansible -f deployment/ansible-runner

# 6. Probar conexión SSH
ssh -p 31022 ansible@172.16.99.101
# Password: ansible123
``` 
---

#### Ajustes Clave Realizados:

**fsGroup: 1000 en spec.template.spec.securityContext: Kubernetes asigna los permisos necesarios al montaje de /ansible-data a nivel de pod sin requerir comandos intrusivos del SO dentro del contenedor.**

**Reemplazo del chown por chmod 777 con tolerancia a errores (|| true): Evita romper el Script de Inicio en caso de que el proveedor de almacenamiento de tu cluster restrinja la modificación directa de permisos POSIX sobre el montaje /ansible-data.**

**Uso de exec /usr/sbin/sshd -D -e: exec reemplaza el proceso principal de bash por sshd, asegurando que SSH reciba las señales del sistema correctamente (evitando cuelgues del Pod).**