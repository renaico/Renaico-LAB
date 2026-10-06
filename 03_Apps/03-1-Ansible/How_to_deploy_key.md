
## Como crear y deplegar la clave ssh desde el pod ansible (nodo de control) a las nodos gestioandos o clientes 

#### 1.- Generar el par de claves en el Pod e importar la nueva pública en Windows (Más rápida)

 ***Como no tenemos el archivo `id_rsa` en el Pod, generamos un par de llaves nuevo en un segundo:***

1. **Genera la llave dentro del Pod:**
   
```bash
ssh-keygen -t rsa -b 4096 -N "" -f ~/.ssh/id_rsa
```

2. **Visualiza tu nueva clave pública:**
  
```bash

ansible@ansible-runner-7b9d5588fb-2n8cv:~$ cat ~/.ssh/id_rsa.pub

ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAQDdWaOUzF0RqCNEo5fjPvj+QLaDEus29twzUWVjTSFS7Ija67vMh1C4rq3c6xLfi8miWeUZ4+92F6ffWsbTc2uAiCHuIlYp+VGTYoDLbKP3VHeFPhcemKsQYq8tFSxbhhsygRzWFDMmx0xQ5A9zN6dERxX/AATboaBOmAeVjO41tCw4WNVLt+SBTG6gBhWw/4itIylmXc9ZNA/d9+9Vkq60NFqe3JOAF0k55LgLEldGFDjKuRj8td4vgityAjKPyMWUqR2Els3KHpzZsPzi8Dj5NDlGeL2CUmxAADdTlDebMVVUGf2nOH+M9rQI8y14uW9Gto8h9K/nhHBK7343FS9AZMfsj2SuNmpfLmpTIY3TWeRt/G4S83KwKwU/es7UK/RSO3N/GfvbWBaUnH1+ANELc771OFoysnZeIz9t9C85GuxiBlZr3O5H4QH7o18jR8aKww04eoHpHnUULYTj/Kb2ZMj8DgGPul66fky/3o3WYDcGW7BGaIKxDU0kncznYpwUmvuAvmp4RVE6VWCGQ8xxQZxdVS+cnAGsZZpsNS4vSwLlLG9+dAKB4z1lb9gUXCGfWZ+hKkFPhYAtvELjJtz9rqIJ4ygzhK2DRxCUZVqeWv1SLIh0swjSzXXBXOpn1ipb9hhe2cNaMcWsa0gLzwerSmuFux6TEoJn8gLY62NbAQ== ansible@ansible-runner-7b9d5588fb-2n8cv

ansible@ansible-runner-7b9d5588fb-2n8cv:~$ 

```

3. **Copia el texto devuelto** y reemplaza la variable `$sshKey` en tu script de Windows con esta nueva llave pública^^. Luego, ejecutas el script en Windows nuevamente^^.


#### 2.- Edicion del Script Powershell, agregamos la clave recien generada. 

```powershell
##Este Script esta pensado para deplegar la clave ssh creada en el nodo de control de Ansible 

# 1. Definir la clave pública exacta de tu Pod de Ansible
$sshKey = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAQDdWaOUzF0RqCNEo5fjPvj+QLaDEus29twzUWVjTSFS7Ija67vMh1C4rq3c6xLfi8miWeUZ4+92F6ffWsbTc2uAiCHuIlYp+VGTYoDLbKP3VHeFPhcemKsQYq8tFSxbhhsygRzWFDMmx0xQ5A9zN6dERxX/AATboaBOmAeVjO41tCw4WNVLt+SBTG6gBhWw/4itIylmXc9ZNA/d9+9Vkq60NFqe3JOAF0k55LgLEldGFDjKuRj8td4vgityAjKPyMWUqR2Els3KHpzZsPzi8Dj5NDlGeL2CUmxAADdTlDebMVVUGf2nOH+M9rQI8y14uW9Gto8h9K/nhHBK7343FS9AZMfsj2SuNmpfLmpTIY3TWeRt/G4S83KwKwU/es7UK/RSO3N/GfvbWBaUnH1+ANELc771OFoysnZeIz9t9C85GuxiBlZr3O5H4QH7o18jR8aKww04eoHpHnUULYTj/Kb2ZMj8DgGPul66fky/3o3WYDcGW7BGaIKxDU0kncznYpwUmvuAvmp4RVE6VWCGQ8xxQZxdVS+cnAGsZZpsNS4vSwLlLG9+dAKB4z1lb9gUXCGfWZ+hKkFPhYAtvELjJtz9rqIJ4ygzhK2DRxCUZVqeWv1SLIh0swjSzXXBXOpn1ipb9hhe2cNaMcWsa0gLzwerSmuFux6TEoJn8gLY62NbAQ== ansible@ansible-runner-7b9d5588fb-2n8cv"

# 2. Habilitar la cuenta Administrador y asignar la contraseña por defecto
Get-LocalUser -Name "Administrador" | Enable-LocalUser
Set-LocalUser -Name "Administrador" -Password (ConvertTo-SecureString "ADMINPASSWORD" -AsPlainText -Force)

# 3. Asegurar la instalación y arranque del servicio OpenSSH Server
if (-not (Get-Service sshd -ErrorAction SilentlyContinue)) {
    Add-WindowsCapability -Online -Name OpenSSH.Server~~~~0.0.1.0
}
Set-Service -Name sshd -StartupType Automatic
Start-Service sshd

# 4. Configurar el archivo autorizado global para la cuenta Administrador
$sshDir = "C:\ProgramData\ssh"
if (!(Test-Path $sshDir)) { New-Item -ItemType Directory -Path $sshDir -Force }

$adminFile = "$sshDir\administrators_authorized_keys"
Set-Content -Path $adminFile -Value $sshKey -Encoding UTF8

# 5. Aplicar Permisos (ACLs) requeridos por OpenSSH en Windows
icacls $adminFile /inheritance:r
icacls $adminFile /grant "NT AUTHORITY\SYSTEM:(F)"
icacls $adminFile /grant "BUILTIN\Administradores:(F)"

# 6. Habilitar la regla del Firewall de Windows para el puerto SSH (22)
if (-not (Get-NetFirewallRule -Name "OpenSSH-Server-In-TCP" -ErrorAction SilentlyContinue)) {
    New-NetFirewallRule -Name 'OpenSSH-Server-In-TCP' -DisplayName 'OpenSSH Server (sshd)' -Enabled True -Direction Inbound -Protocol TCP -Action Allow -LocalPort 22
}

# 7. stablecer la Shell por defecto de OpenSSH a PowerShell para que Ansible pueda ejecutar los playbooks correctamente. 
New-ItemProperty -Path 'HKLM:\SOFTWARE\OpenSSH' -Name DefaultShell -Value "C:\Windows\System32\WindowsPowerShell\v1.0\powershell.exe" -PropertyType String -Force

# 8. Reiniciar el servicio sshd para aplicar los cambios
Restart-Service sshd

```
