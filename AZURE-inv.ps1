# inventario-azure.ps1

# Conectar a Azure
Connect-AzAccount

# Obtener Tenant ID (equivalente a ORG_ID en GCP)
$TENANT_ID = (Get-AzContext).Tenant.Id
Write-Host "Tenant ID: $TENANT_ID"

# Nombre del fichero con fecha
$FECHA = Get-Date -Format "yyyy-MM-dd"
$FILE = "inventario-azure-$FECHA.md"

# ── CONTEO POR TIPO DE RECURSO ────────────────────────────────
$queryResumen = @"
Resources
| summarize Cantidad = count() by type
| order by Cantidad desc
"@

$resumen = Search-AzGraph -Query $queryResumen -UseTenantScope

# ── DETALLE COMPLETO ──────────────────────────────────────────
$queryDetalle = @"
Resources
| project subscriptionId, resourceGroup, name, type, location
| order by type asc, name asc
"@

$detalle = Search-AzGraph -Query $queryDetalle -UseTenantScope -First 5000

# ── GENERAR MARKDOWN ──────────────────────────────────────────
$contenido = @"

# Inventario Azure - $FECHA

**Tenant ID:** $TENANT_ID
---

## Conteo por tipo de recurso

| Tipo de Recurso | Cantidad |
|---|---|
$(($resumen | ForEach-Object { "| $($_.type) | $($_.Cantidad) |" }) -join "`n")

---

## Detalle completo

| Suscripción | Resource Group | Nombre | Tipo | Ubicación |
|---|---|---|---|---|
$(($detalle | ForEach-Object { "| $($_.subscriptionId) | $($_.resourceGroup) | $($_.name) | $($_.type) | $($_.location) |" }) -join "`n")
"@

# ── GUARDAR FICHERO ───────────────────────────────────────────
$contenido | Out-File -FilePath $FILE -Encoding UTF8
Write-Host "✅ Guardado en $FILE"


