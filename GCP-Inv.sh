ORG_ID=$(gcloud organizations list --format="value(ID)") 
echo $ORG_ID
FILE="inventario-gcp-$(date +%Y-%m-%d).md"
{
  echo "# Inventario GCP - $(date +%Y-%m-%d)"
  echo ""
  echo "## Conteo por tipo de recurso"
  gcloud asset search-all-resources \
    --scope=organizations/$ORG_ID \
    --format="value(assetType)" | sort | uniq -c | sort -rn
  echo ""
  echo "## Detalle completo"
  gcloud asset search-all-resources \
    --scope=organizations/$ORG_ID \
    --format="table(assetType, name, project, location)"
} > $FILE
echo "✅ Guardado en $FILE"
