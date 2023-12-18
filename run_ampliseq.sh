#!/bin/bash
#Submuestreo de los reads a partir de submuestreo.R, genera cuatro escenarios de profundidad de secuenciación (alto número de lecturas, bajo número de lecturas, balanceado y desigual.
# Rutas de los directorios base
INPUT_DIRECTORIO="/home/lorena/TFM/100Percent"
OUTPUT_DIRECTORIO="/home/lorena/TFM/muestras"

# Se llama al script de R, pasando las rutas de los directorios
Rscript /home/lorena/TFM/submuestreo.R $INPUT_DIRECTORIO $OUTPUT_DIRECTORIO

# Nf-core/ampliseq
# Se definen  los directorios base que va a coger nf-core/ampliseq
BASE_INPUT_DIR="/home/lorena/TFM/muestras"
BASE_OUTPUT_DIR="/home/lorena/TFM/resultados"

# Se definen los parámetros para los comandos  para nf-core/ampliseq 
FW_PRIMER="TCCTACGGGAGGCAGCAGT"
RV_PRIMER="GGACTACCAGGGTATCTAATCCTGTT"
PROFILE="docker"
#Crear el directorio de resultados de Nextflow si no existe, crearlo

mkdir -p "$BASE_OUTPUT_DIR"

for ESCENARIO_DIR in "$BASE_INPUT_DIR"/*_reads; do
  if [ -d "$ESCENARIO_DIR" ]; then
    # Extraer el nombre del escenario
    ESCENARIO_NAME=$(basename "$ESCENARIO_DIR")

    # Definir el directorio de salida para este escenario en Nextflow
    NF_ES_OUTDIR="$BASE_OUTPUT_DIR/$SCENARIO_NAME"

    # Se corre nf-core/ampliseq
    nextflow run nf-core/ampliseq \
        -r 2.7.1 \
        -profile "$PROFILE" \
        --input_folder "$ESCENARIO_DIR" \
        --FW_primer "$FW_PRIMER" \
        --RV_primer "$RV_PRIMER" \
        --outdir "$NF_ES_OUTDIR"  \
        --max_memory '8.GB'  \
        --max_time "1.h" \
       


        
  fi
done

