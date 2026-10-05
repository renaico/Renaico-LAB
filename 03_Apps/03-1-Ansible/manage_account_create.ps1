# Habilitar cuenta Administrador y establecer contraseña
Get-LocalUser -Name "Administrador" | Enable-LocalUser
Set-LocalUser -Name "Administrador" -Password (ConvertTo-SecureString "pa.le69," -AsPlainText -Force)