### **Explicación del Archivo de Configuración (ansible.cfg)**

```ini
[defaults]
inventory = ./hosts.ini
host_key_checking = False
stdout_callback = yaml
deprecation_warnings = False
```

**1.- *inventory* = ./hosts.ini: Define la ruta por defecto del archivo de inventario dentro del directorio actual del proyecto. Evita tener que especificar el parámetro -i hosts.ini en cada comando ansible o ansible-playbook.**

**2.- *host_key_checking* = False: Deshabilita la verificación interactiva de la clave SSH del host (known_hosts). Esto permite que Ansible se conecte automáticamente a máquinas nuevas o reinstaladas por primera vez sin detener la ejecución pidiendo confirmación manual.**

**3.- *stdout_callback* = yaml: Formatea la salida de la consola en formato YAML estructurado en lugar del texto continuo predeterminado. Facilita enormemente la lectura de los resultados de los comandos y playbooks.**

**4.- *deprecation_warnings* = False: Oculta los mensajes de advertencia sobre características u opciones que quedarán obsoletas en futuras versiones de Ansible, manteniendo limpia la consola durante la ejecución.**

## Explicación de la Configuración del Inventario (hosts.ini)

``` Ini
[windows_vms]
172.16.99.241
172.16.99.242
172.16.99.243
172.16.100.111

[windows_vms:vars]
ansible_user=Administrador
ansible_connection=ssh
ansible_shell_type=powershell
ansible_shell_executable=powershell.exe
ansible_ssh_private_key_file=/home/ansible/.ssh/id_rsa
```

**1. Sección del Grupo [windows_vms]**
    **[windows_vms]: Agrupa las 4 direcciones IP bajo un identificador común. Permite lanzar comandos o playbooks a todo el grupo a la vez en lugar de especificar las IPs individualmente.**


**2. Sección de Variables del Grupo [windows_vms:vars]**
    **Esta sección define las variables de conexión que aplicarán a todas las máquinas pertenecientes al grupo windows_vms:**

***ansible_user*=Administrador: Especifica el usuario del sistema operativo Windows con el que Ansible iniciará sesión.**

***ansible_connection*=ssh: Le indica a Ansible que utilice el protocolo SSH como canal de transporte hacia Windows en lugar de WinRM.**

***ansible_shell_type*=powershell: Variable crítica para Windows sobre SSH. Informa a Ansible que el shell remoto responderá como PowerShell. Sin esto, Ansible intentaría enviar comandos formateados para Bash/Linux, provocando errores de sintaxis.**

***ansible_shell_executable*=powershell.exe: Especifica explícitamente el ejecutable de la consola a utilizar en el host remoto.**

***ansible_ssh_private_key_file*=/home/ansible/.ssh/id_rsa: Indica la ruta exacta de la clave privada SSH en el Pod que se usará para la autenticación sin contraseña mediante par de llaves criptográficas.**
