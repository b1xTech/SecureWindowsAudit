# Ruta del reporte
$ReportePath = "$PSScriptRoot\ReporteSeguridad.html"

# Función para agregar filas al reporte
function Add-Reporte {
    param(
        [string]$Titulo,
        [string]$Estado,
        [string]$Recomendacion
    )

    "<tr><td>$Titulo</td><td>$Estado</td><td>$Recomendacion</td></tr>" | Out-File -Append $ReportePath -Encoding utf8
}

# Crear HTML inicial
@"
<html>
<head>
    <title>Reporte de Seguridad Local</title>
    <style>
        body { font-family: Arial; background-color:#f9f9f9; }
        h2 { color:#333; }
        table { border-collapse: collapse; width: 100%; margin-top: 20px; }
        th, td { border: 1px solid #ccc; padding: 10px; text-align: left; }
        th { background-color: #4CAF50; color: white; }
    </style>
</head>
<body>
<h2>Reporte de Seguridad Local - $(Get-Date)</h2>
<table>
<tr><th>Configuración</th><th>Estado</th><th>Recomendación</th></tr>
"@ | Out-File $ReportePath -Encoding utf8

# ------------------------
# 1. Firewall
# ------------------------
$firewallProfiles = Get-NetFirewallProfile
foreach ($profile in $firewallProfiles) {
    $estado = if ($profile.Enabled) { "OK" } else { "CRÍTICO" }
    $recomendacion = if ($profile.Enabled) { "No se requiere acción" } else { "Habilitar firewall" }
    Add-Reporte "$($profile.Name) Firewall" $estado $recomendacion
}

# ------------------------
# 2. UAC
# ------------------------
$uacKey = "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System"
try {
    $uacLevel = Get-ItemProperty -Path $uacKey -Name "ConsentPromptBehaviorAdmin"
    $estado = switch ($uacLevel.ConsentPromptBehaviorAdmin) {
        0 { "CRÍTICO" }
        2 { "OK" }
        default { "ADVERTENCIA" }
    }
    $recomendacion = if ($uacLevel.ConsentPromptBehaviorAdmin -eq 0) { "Activar UAC" } else { "No se requiere acción" }
}
catch {
    $estado = "ADVERTENCIA"
    $recomendacion = "Revisar UAC manualmente"
}
Add-Reporte "UAC" $estado $recomendacion

# ------------------------
# 3. Antivirus / Defender
# ------------------------
try {
    $avStatus = Get-CimInstance -Namespace root/SecurityCenter2 -ClassName AntivirusProduct -ErrorAction SilentlyContinue
    if ($avStatus) {
        $estado = "OK"
        $recomendacion = "No se requiere acción"
    } else {
        $estado = "CRÍTICO"
        $recomendacion = "Instalar o activar un antivirus"
    }
}
catch {
    $estado = "ADVERTENCIA"
    $recomendacion = "Revisar antivirus manualmente"
}
Add-Reporte "Antivirus / Defender" $estado $recomendacion

# ------------------------
# 4. Cuentas administrativas locales
# ------------------------
try {
    $admins = Get-LocalGroupMember -Group "Administrators" | ForEach-Object { $_.Name }
    if ($admins.Count -eq 0) {
        $estado = "ADVERTENCIA"
        $recomendacion = "No se detectaron cuentas admin, revisar sistema"
    } else {
        $estado = "OK"
        $recomendacion = "Cuentas admin: " + ($admins -join ", ")
    }
}
catch {
    $estado = "ADVERTENCIA"
    $recomendacion = "Error al listar cuentas admin"
}
Add-Reporte "Cuentas Administrativas" $estado $recomendacion

# ------------------------
# 5. Windows Update
# ------------------------
try {
    $wuSettings = Get-ItemProperty "HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\WindowsUpdate\Auto Update"
    $estado = if ($wuSettings.AUOptions -ge 3) { "OK" } else { "ADVERTENCIA" }
    $recomendacion = if ($wuSettings.AUOptions -ge 3) { "No se requiere acción" } else { "Habilitar actualizaciones automáticas" }
}
catch {
    $estado = "ADVERTENCIA"
    $recomendacion = "Revisar Windows Update manualmente"
}
Add-Reporte "Windows Update" $estado $recomendacion

# ------------------------
# Cerrar HTML
# ------------------------
@"
</table>
</body>
</html>
"@ | Out-File -Append $ReportePath -Encoding utf8

Write-Host "✅ Reporte generado en: $ReportePath"
