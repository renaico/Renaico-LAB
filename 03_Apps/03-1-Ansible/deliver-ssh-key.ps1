##Este Script esta pensado para deplegar la clave ssh creada en el nodo de control de Ansible 

# 1. Definir la clave pública de Ansible
$sshKey = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAQCuwlukLBrDPt2GseZlcnWOMuvxy05hgv9d14lGZPBKil3vtLrXlSR5T/ObdMrP1b7SUMVq/OkFM2Q2Jah0WGCHiLDt4XIRBucyAbootp4rxsUxVRtlc2C50Oe1O5Rd8VM7Eu5qJYbO95M7TZqTi3DjwfokaU/DdK3sjyBZoX3KwFCP2G4HUIKl8kUW5YppcPWARNF9B4kkc8vJ8i4vZpUfeSHm0THWTiAT5iYnSOg58fvS7Wx8+sHbiDu+4SXKhJmyLx8iU5XVqMPCpfk0DXknPahiVX7DowoBuuCv7QFOFnLqaT9IR/6oyptzM5ZhoBvIOEfsGYqAA72yvE3h6p+My7pnUqu4sp27ewvPSYaPUByOBQB/2/fWEmMLn5VLAN2AMXH8ltO3dsTdrt2/i/Mc+Bn9p0ydcv5mDLpU4gVAuIdXJvu5EjPU3AdSqulv3CXAzJ9N6h5h0AZTI6b61pu3marKROfh1Pen3j1GdOjNvs98XSkqqorI6aOQmfjsHB81XuHWhB6mwX36t9CHWl/OfMoGC00FuBJJu2N1DzTaHxvtypda9W5JOOahGXtUYWGP6MnicequckfA89oMJSYLMEl9w7ZPmevG5Zu0Q/gg5VCrA6KjJPAK4QVczFX/NTdKTaj9e4vhBmbJgUT3X6nNmgl6/bOymYKzi1XUdEMz8w== root@ansible-runner-c464bd8-4s8q7"

# 2. Asegurar la instalación y arranque del servicio OpenSSH Server
if (-not (Get-Service sshd -ErrorAction SilentlyContinue)) {
    Add-WindowsCapability -Online -Name OpenSSH.Server~~~~0.0.1.0
}
Set-Service -Name sshd -StartupType Automatic
Start-Service sshd

# 3. Configurar la clave pública global para Administradores
$sshDir = "C:\ProgramData\ssh"
if (!(Test-Path $sshDir)) { New-Item -ItemType Directory -Path $sshDir -Force }

$adminFile = "$sshDir\administrators_authorized_keys"
Set-Content -Path $adminFile -Value $sshKey -Encoding UTF8

# 4. Aplicar Permisos (ACLs) estrictos requeridos por OpenSSH
icacls $adminFile /inheritance:r
icacls $adminFile /grant "NT AUTHORITY\SYSTEM:(F)"
icacls $adminFile /grant "BUILTIN\Administrators:(F)"

# 5. Regla de Firewall para SSH (en el puerto 22 o el que definas)
if (-not (Get-NetFirewallRule -Name "OpenSSH-Server-In-TCP" -ErrorAction SilentlyContinue)) {
    New-NetFirewallRule -Name 'OpenSSH-Server-In-TCP' -DisplayName 'OpenSSH Server (sshd)' -Enabled True -Direction Inbound -Protocol TCP -Action Allow -LocalPort 22
}

# 6. Reiniciar el servicio SSH para aplicar los cambios
Restart-Service sshd