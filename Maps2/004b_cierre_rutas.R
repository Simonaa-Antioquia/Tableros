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

  df <- df %>% group_by(id_ruta_externa) %>% mutate(ton_ruta = sum(suma_kg))

  ruta_imp <- df$nombre[which.max(df$ton_ruta)]
  max_ton_ruta <- max(df$ton_ruta)

  aux_rutas <- df[!(duplicated(df[c("id_ruta_externa","nombre")])),c("id_ruta_externa","nombre","ton_ruta")]
  aux_rutas <- aux_rutas[order(aux_rutas$ton_ruta, decreasing = TRUE), ]

  for(i in 1:nrow(aux_rutas)) {
    if(i == 1){
      rutas_ordenadas <- aux_rutas$nombre[i]
    } else {
      rutas_ordenadas <- paste0(rutas_ordenadas,", ",aux_rutas$nombre[i])
    }
  }

  por_ruta = round(((ton_original - max_ton_ruta)/ton_original)*100, digits = 2)
  
  if (!is.null(Rutas)) {
    for(i in 1:length(Rutas)){
      df <-df[df$id_ruta_externa != Rutas[i],]
      #df <- df %>% dplyr::filter(!id_ruta_externa %in% Rutas)
    }
  }

  ton_sin_rutas <- sum(df$suma_kg)
  
  if(nrow(df)==0){
    map <-  validate("No hay datos disponibles")
  } else {
    
    map <- leaflet() %>%
      addTiles()
    
    for(i in 1:nrow(df)) {
      dir <- matrix(unlist(df[i,18][[1]]), ncol = 2)
      map <- map %>% addPolylines(data = dir,
                                  color = df$color[i],
                                  stroke = 0.05,
                                  opacity = 0.8,
                                  label = paste0("Ruta: ",df$nombre[i]," "," "," - "," "," Municipio de origen: ",df$mpio_origen[i]),
                                  labelOptions = labelOptions(noHide = F, direction = "top"))
    }
  }

  por_perdido = round(((ton_original -  ton_sin_rutas)/ton_original)*100, digits = 2)
  ton_perdido = ton_original -  ton_sin_rutas
  
  return(list(
    grafico=map,
    datos=df,
    por_perdido = por_perdido,
    ton_perdido = ton_perdido,
    ruta_imp = ruta_imp,
    por_ruta = por_ruta,
    rutas_ordenadas = rutas_ordenadas
  ))
}
