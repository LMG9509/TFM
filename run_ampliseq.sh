#!/bin/bash
#Submuestreo de los reads a partir de un script de R, con tres proporciones (0.25,0.5,0.75)
# Rutas de los directorios base
INPUT_DIRECTORY="/home/lorena/TFM/muestras/100Percent"
OUTPUT_DIRECTORY="/home/lorena/TFM/muestras"

# Se llama al script de R, pasando las rutas de los directorios
Rscript /home/lorena/TFM/submuestreo_reads.R $INPUT_DIRECTORY $OUTPUT_DIRECTORY

# Nf-core/ampliseq
# Se definen  los directorios base que va a coger nf-core/ampliseq
BASE_INPUT_DIR="/home/lorena/TFM/muestras"
BASE_OUTPUT_DIR="/home/lorena/TFM/resultados"

# Se definen los parámetros para los comandos  para nf-core/ampliseq 
FW_PRIMER="TCCTACGGGAGGCAGCAGT"
RV_PRIMER="GGACTACCAGGGTATCTAATCCTGTT"
PROFILE="docker"

# Bucle para que se ejecute nf-core/ampliseq sobre cada directorio de las distintas proporciones
for PROP_DIR in "$BASE_INPUT_DIR"/*Percent; do
  if [ -d "$PROP_DIR" ]; then
    # se extrae la propoción del nombre base
    PROP_PERCENT=$(basename "$PROP_DIR")
    
    # Se define el directorio de salida para la proporción Define the output directory for this proportion
    OUTDIR="$BASE_OUTPUT_DIR/$PROP_PERCENT"
    
    # Nos aseguramos de que existe el directorio de salida
    mkdir -p "$OUTDIR"
    
    # Se corre nf-core/ampliseq
    nextflow run nf-core/ampliseq \
        -r 2.7.1 \
        -profile "$PROFILE" \
        --input_folder "$PROP_DIR" \
        --FW_primer "$FW_PRIMER" \
        --RV_primer "$RV_PRIMER" \
        --outdir "$OUTDIR"  \
        --max_memory '8.GB'

  fi
done
