args <- commandArgs(trailingOnly = TRUE)
input_directory <- args[1]
output_directory <- args[2]
proportion_to_subsample <- as.numeric(args[3])

library(ShortRead)

# Función para submuestrear reads de un archivo FASTQ
subsample_reads <- function(fastq_path, proportion) {
  # Se cargan los reads del archivo FASTQ
  fastq_reads <- readFastq(fastq_path)
  
  # Se determina el número de reads que se van seleccionar
  total_reads <- length(fastq_reads)
  num_reads_to_select <- round(total_reads * proportion)
  
  # Se selecciona un subconjunto aleatorio de reads
  set.seed(123)
  selected_indices <- sample(total_reads, num_reads_to_select)
  subsampled_reads <- fastq_reads[selected_indices]
  
  # Reads submuestreados
  return(subsampled_reads)
}

# Directorios donde se encuentran tus archivos FASTQ y el directorio de salida
input_directory <- "/home/lorena/TFM/muestras/100Percent"
output_directory <- "/home/lorena/TFM/muestras"
proportion_to_subsample <- c(0.25,0.5,0.75) # 25%,50% y 75% de los reads


# Se listan todos los archivos FASTQ en el directorio
fastq_files <- list.files(input_directory, pattern = "\\.fastq\\.gz$", full.names = TRUE)

# Se submuestrea cada archivo FASTQ
for (fastq_file in fastq_files) {
  # Se procesa cada proporción
  for (prop in proportion_to_subsample) {
    # Se crea un nombre de archivo para los reads submuestreados
    file_base_name <- gsub(pattern = "\\.fastq\\.gz$", replacement = "", basename(fastq_file))
    prop_output_directory <- file.path(output_directory, paste0(prop*100, "Percent"))
    output_path <- file.path(prop_output_directory, paste0( file_base_name,".fastq.gz"))
    
    if (!dir.exists(prop_output_directory)) {
      dir.create(prop_output_directory, recursive = TRUE)
    }
    # Se submuestrean los reads
    subsampled_reads <- subsample_reads(fastq_file, prop)
    
    # Se guardan los submuestreados en un nuevo archivo FASTQ en el directorio de salida
    writeFastq(subsampled_reads, output_path)
  }
}
