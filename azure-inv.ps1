# Instalar módulo si no lo tienes
Install-Module -Name Az.ResourceGraph -Force

Connect-AzAccount -TenantId "<TENANT_ID>"

# ── TABLA DETALLADA ──────────────────────────────────────────
$query = @"
Resources
| project subscriptionId, resourceGroup, name, type, location
| order by type asc, name asc
"@

$recursos = Search-AzGraph -Query $query -UseTenantScope -First 5000
$recursos | Export-Csv "inventario_azure.csv" -NoTypeInformation -Encoding UTF8
$recursos | Format-Table -AutoSize

# ── TABLA RESUMEN ────────────────────────────────────────────
$queryResumen = @"
Resources
| summarize Cantidad = count() by type
| order by Cantidad desc
"@

$resumen = Search-AzGraph -Query $queryResumen -UseTenantScope
$resumen | Format-Table -AutoSize
