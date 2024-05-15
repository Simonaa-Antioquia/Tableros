#Proyecto FAO
#Procesamiento datos SIPSA
################################################################################-
#Autores: Juliana Lalinde, Laura Quintero, Germán Angulo
#Fecha de creacion: 24/02/2024
#Fecha de ultima modificacion: 24/02/2024
################################################################################-
# Limpiar el entorno de trabajo
rm(list=ls())
# Paquetes 
################################################################################-
library(leaflet)
options(scipen = 999)
################################################################################-

## Cargamos la base de datos de origen destino 

abastecimiento_medellin <- readRDS("abastecimiento_rutas_cierre.rds")

ruta <- function(Año = NULL,Mes = NULL,Producto = NULL,Rutas = NULL) {
  df <- abastecimiento_medellin
  
  if (!is.null(Año)) {
    df <- df %>% dplyr::filter(anio == Año)
  }
  
  if (!is.null(Mes)) {
    df <- df %>% dplyr::filter(mes == Mes)
  }
  
  if (!is.null(Producto)) {
    df <- df %>% dplyr::filter(producto == Producto)
  }
  
  df <- df[!(duplicated(df[c("codigo_mpio_destino","codigo_mpio_origen")])),]

  ton_original <- sum(df$suma_kg)
  
  if (!is.null(Rutas)) {
    for(i in 1:length(Rutas)){
      df <-df[df$id_ruta_externa != Rutas[i],]
      #df <- df %>% dplyr::filter(!id_ruta_externa %in% Rutas)
    }
  }

  ton_sin_rutas <- sum(df$suma_kg)
  
  map <- leaflet() %>%
    addTiles()
  
  for(i in 1:nrow(df)) {
    dir <- matrix(unlist(df[i,18][[1]]), ncol = 2)
    map <- map %>% addPolylines(data = dir, color = df$color[i], stroke = 0.05, opacity = 0.8)
  }

  por_perdido = ((ton_original -  ton_sin_rutas)/ton_original)*100
  ton_perdido = ton_original -  ton_sin_rutas
  
  return(list(
    grafico=map,
    datos=df,
    por_perdido = por_perdido,
    ton_perdido = ton_perdido
  ))
}
