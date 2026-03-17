INDEX=$(aws resource-explorer-2 get-index --output text 2>/dev/null) 
ARN=$(echo "$INDEX" | awk '{print $1}') 
TYPE=$(echo "$INDEX" | awk '{print $5}') 
if [ "$TYPE" = "AGGREGATOR" ]; then 
	echo "✅ El índice AGGREGATOR ya existe." 
elif [ "$TYPE" = "LOCAL" ]; then 
	echo "🔄 Existe un índice LOCAL, actualizando a AGGREGATOR..." 
	aws resource-explorer-2 update-index-type --arn $ARN --type AGGREGATOR 
else echo "🔧 No existe índice, creando AGGREGATOR..." 
	aws resource-explorer-2 create-index --index-type AGGREGATOR 
fi

aws resource-explorer-2 search --query-string "*" --output table > inventario-aws-$(date +%Y-%m-%d).md
aws resource-explorer-2 search --query-string "*" --query "Resources[*].ResourceType" --output text | tr '\t' '\n' | sort | uniq -c | sort -rn >> inventario-aws-$(date +%Y-%m-%d).md
