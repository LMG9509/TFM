args <- commandArgs(trailingOnly = TRUE)

fastq_dir <- args[1]
output_base_dir <- args[2]

#Librerías empleadas
library(ShortRead)
library(MASS)

#Se establece una semilla para la reproducibilidad
set.seed(123)

# Función para calcular "size" para la distribución binomial negativa

calcular_tamaño<- function(mu, prob) {
  tamaño <- mu * (1 - prob) / prob
  return(tamaño)
}

# Función  para submuestrear los archivos fastq (haciendo que el resultado sea pareado)

submuestrear_fastq <- function(ruta_forward, ruta_reverse, tamaño, prob, forward_output, reverse_output) {
  fq_forward <- readFastq(ruta_forward)
  fq_reverse <- readFastq(ruta_reverse)
  
  if(length(sread(fq_forward)) != length(sread(fq_reverse))) {
    stop("No coinciden el número de lecturas (forward y reverse")
  }
  
  subsample_size <- rnbinom(n = 1, size = tamaño, prob = prob)
  indices <- sample(1:length(sread(fq_forward)), size = subsample_size, replace = FALSE)
  
  fq_forward_submuestreado<- fq_forward[indices]
  fq_reverse_submuestreado <- fq_reverse[indices]
  
  writeFastq(fq_forward_submuestreado, forward_output)
  writeFastq(fq_reverse_submuestreado, reverse_output)
}

# Directorios

fastq_dir <- "/home/lorena/TFM/100Percent"
output_base_dir <- "/home/lorena/TFM/muestras"

#Asignación de probabilidades

escenarios <- list(high_reads = 0.1, balanced_reads = 0.5, low_reads = 0.7, unequal_reads = runif(1, min = 0.2, max = 0.7))

#Directorios de salida

dir.create(output_base_dir, showWarnings = FALSE, recursive = TRUE)

for (scenario in names(scenarios)) {
  scenario_dir <- file.path(output_base_dir, scenario)
  dir.create(scenario_dir, showWarnings = FALSE)
}

#Se emplean "_L001_R1_001" y R2, como formato de nombres de archivos
file_paths <- list.files(fastq_dir, pattern = "_L001_R1_001\\.fastq.gz$", full.names = TRUE)

for (file_path in file_paths) {
  ruta_reverse <- sub("_L001_R1_001\\.fastq.gz$", "_L001_R2_001.fastq.gz", file_path)
  
  if(!file.exists(ruta_reverse)) {
    next  # Saltar si no hay un archivo pareado
  }
  
  #Asignación de factor por escenario, probabilidad al mismo y calculo de mu
  for (escenario in names(escenarios)) {
    prob <- escenarios[[escenario]]
    mu <- mean(width(sread(readFastq(file_path))))
    if (escenario == "high_reads"){
      factor <- 2
    } else if (escenario == "low_reads") {
      factor <- 0.9
    } else if (escenario == "balanced_reads") {
      factor <- 1
    } else if (escenario == "unequal") {
      factor <- runif(1, min = 0.5, max = 2)
    } else {
      factor <- 1  # Valor por defecto
    }
    #Se calcula el tamaño
    tamaño <- calcular_tamaño(mu*factor, prob)
    #Generación del output mediante la función de submuestreo
    
    forward_output <- file.path(output_base_dir, escenario, basename(file_path))
    reverse_output <- file.path(output_base_dir, escenario, basename(ruta_reverse))
    
    submuestrear_fastq(file_path, ruta_reverse, tamaño, prob, forward_output, reverse_output)
  }
}

