# SecureWindowsAudit
Script PowerShell para analizar configuraciones críticas de seguridad en Windows y generar un informe profesional


Auditoría de configuraciones de seguridad de Windows mediante PowerShell, que analiza firewall, UAC, antivirus, PowerShell remoto, cuentas administrativas y más, generando un reporte detallado con recomendaciones.

## Capturas


## Funcionalidades

- Verifica estado del firewall en todos los perfiles.
- Comprueba el nivel de UAC.
- Detecta si el antivirus o Windows Defender está activo.
- Revisa si PowerShell remoto está habilitado.
- Lista usuarios locales con privilegios administrativos.
- Comprueba actualizaciones automáticas de Windows.
- Genera reporte en HTML con estado y recomendaciones.

## Requisitos

- Windows 10 / 11
- PowerShell 5.1 o superior
- Permisos de ejecución de scripts habilitados (`Set-ExecutionPolicy`)

## Uso

1. Descargar el script `AuditorSeguridad.ps1`.
2. Abrir PowerShell como administrador.
3. Navegar a la carpeta donde está el script.
4. Ejecutar:

   powershell
.\AuditorSeguridad.ps1
