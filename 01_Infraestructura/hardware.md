# Este Archivo define la compocision del laboratorio, cantidad y tipo de maquinas

## Detalles de la Infraestructura Fisica.

Este experimento basa su contruccion en maquinas recogidas de los desechos operativos de proyectos pasados, los limitados recursos que poseen fueron transformados en el valiso motor y soporte de este proyecto.
A continuacion se establece una tabla con cada detalle y recurso Disponible.

| Direccion IP | Hostname | Sistema Operativo              | Product              | cpu_model                                       | cpu_cores | mem_gib | disks_summary                       |
| ------------ | -------- | ------------------------------ | -------------------- | ----------------------------------------------- | --------- | ------- | ----------------------------------- |
| 172.16.99.11 | host01   | Debian GNU/Linux 12 (bookworm) | ProLiant ML310e Gen8 | Intel(R) Xeon(R) CPU E3-1220 V2 @ 3.10GHz       | 4         | 27,0,36 | sda(465,8G);sdb(465,8G);sdc(465,8G) |
| 172.16.99.12 | host02   | Debian GNU/Linux 11 (bullseye) | ProLiant ML350 G6    | Intel(R) Xeon(R) CPU           E5530  @ 2.40GHz | 16        | 27,0,44 | sda(558,7G);sdb(931,5G)             |
| 172.16.99.13 | host03   | Debian GNU/Linux 11 (bullseye) | ProLiant ML350 G6    | Intel(R) Xeon(R) CPU           E5645  @ 2.40GHz | 12        | 23,0,46 | sda(465,8G);sdb(465,8G)             |
| 172.16.99.14 | host04   | Debian GNU/Linux 13 (trixie)   |                      | Intel(R) Core(TM) i7-2600 CPU @ 3.40GHz         | 8         | 7,0,66  | sda(3,6T);sdb(931,5G)               |
| 172.16.99.15 | host05   | Debian GNU/Linux 13 (trixie)   |                      | Intel(R) Core(TM) i3-3220 CPU @ 3.30GHz         | 4         | 7,0,73  | sda(931,5G)                         |
| 172.16.99.16 | host06   | Debian GNU/Linux 13 (trixie)   |                      | Intel(R) Core(TM) i3-3240 CPU @ 3.40GHz         | 4         | 7,0,73  | sda(465,8G);sr0(1024M)              |
| 172.16.99.17 | host07   | Debian GNU/Linux 13 (trixie)   |                      | Intel(R) Core(TM) i3-3240 CPU @ 3.40GHz         | 4         | 7,0,60  | sda(931,5G)                         |
| 172.16.99.18 | host08   | Debian GNU/Linux 13 (trixie)   |                      | Intel(R) Core(TM) i3-2100 CPU @ 3.10GHz         | 4         | 7,0,67  | sda(465,8G)                         |

## Infraestructura Virtual

<figure>
  <img src="/Renaico_LAB/02_imagenes/Screenshot_20260514_142631.png" width="500" height="700" alt="Maquinas Virtuales del Cluster">
  <figcaption>Máquinas Virtuales componentes del cluster</figcaption>
</figure>

## Detalles de las maquinas 


| VM Name | HOST DE VIRTUALIZACION | ID | UUID                                 | Estado     | CPU(s) | CPU_Time_s | Memoria_Max_MiB | Memoria_Used_MiB | Persistente | Autoinicio |
| ------- | ---------------------- | -- | ------------------------------------ | ---------- | ------ | ---------- | --------------- | ---------------- | ----------- | ---------- |
| TALOS01 | HOST01                 | 10 | 3c3eb3b8-1c2a-4812-9928-2cf83973705d | ejecutando | 2      | 66851,1    | 16500           | 16500            | si          | activar    |
| TALOS02 | HOST02                 | 1  | b9db62ee-cef5-4a84-95b6-fc6884683eeb | ejecutando | 8      | 53428,3    | 16000           | 16000            | si          | desactivar |
| TALOS03 | HOST03                 | 1  | e03f83cd-ad92-4bc7-be08-234a3ee7d9ee | ejecutando | 8      | 54710,2    | 16000           | 16000            | si          | desactivar |
| TALOS04 | HOST04                 | 11 | 52fb2045-086f-46df-b260-94adf40cbb27 | ejecutando | 4      | 41482,7    | 5500            | 5500             | si          | activar    |
| Truenas | HOST04                 | 13 | a8ddaeed-8078-4051-b7ed-469af7792c84 | ejecutando | 2      | 14433,4    | 2048            | 2048             | si          | desactivar |
| TALOS05 | HOST05                 | 1  | 6a2ae31b-4858-41db-89fb-53a20eefa092 | ejecutando | 4      | 43791,2    | 7500            | 7500             | si          | activar    |
| TALOS06 | HOST06                 | 2  | dd30decf-0e73-45fc-bf1a-eef4c331d5d9 | ejecutando | 4      | 43363,2    | 7500            | 7500             | si          | activar    |
| TALOS07 | HOST07                 | 2  | d90c35f6-3be5-4f72-89da-b3a6c0d9bbe8 | ejecutando | 4      | 43553,9    | 7500            | 7500             | si          | activar    |
| TALOS08 | HOST08                 | 2  | ae3f5cbd-3e7c-485b-98a8-23dc406e94a9 | ejecutando | 4      | 44459,9    | 7500            | 7500             | si          | activar    |


### Preparacion del ambiente

#### Ejecutar como root, configuracion de usuario

```bash
#### instalar sudo
apt-get -y install sudo
```

```bash
#### Incluir al usuario en el grupo sudo
usermod -aG sudo renaico
```

#### cerrar todas las sesiones para que se apliquen los grupos

#### Configuracion de red

```bash
#### copia de seguridad del archivo de configuracion /etc/network/interfaces

cp  /etc/network/interfaces /etc/network/interfaces.bak
```

#### Configuracion de ip estatica, 

#### editar: /etc/network/interfaces

agregar:  

```config

# Configuración de IP estática para eno1
auto eno1
iface eno1 inet static
    address 172.16.99.11
    netmask 255.255.255.0
    gateway 172.16.99.1
    dns-nameservers 208.67.220.220

```
#### Ejecutar como usuario "sudo" 

```bash
#### Instalacion de binarios de kvm/libvirt
sudo apt update
sudo apt install qemu-kvm libvirt-daemon-system libvirt-clients bridge-utils virtinst virt-manager
```

```bash
#### agregar al usuario a los grupos kvm y libvirt 
sudo adduser $(whoami) libvirt
sudo adduser $(whoami) kvm 
```
### Desde la maquina local eviar la clave de ssh, administrar desde virt manager

