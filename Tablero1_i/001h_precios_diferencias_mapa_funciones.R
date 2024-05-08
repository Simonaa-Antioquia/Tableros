#Proyecto FAO
#Procesamiento datos SIPSA
################################################################################-
#Autores: Juliana Lalinde, Laura Quintero, Germán Angulo
#Fecha de creacion: 21/02/2024
#Fecha de ultima modificacion: 25/02/2024
################################################################################-
# Limpiar el entorno de trabajo
rm(list=ls())
# Paquetes 
################################################################################-
library(readxl);library(reshape2);library(ggplot2);library(gganimate);library(dplyr);
library(readr);library(lubridate);library(zoo);library(stringr);library(tidyr);library(ggrepel);library(plotly)
################################################################################-

data <- readRDS("base_precios_vs_medellin.rds")%>%
  mutate(cod_depto=as.numeric(cod_depto))

data$departamento[data$departamento=="Bogotá, D.C."]<-"Bogotá"

shapefile <- st_read("MGN_DPTO_POLITICO.shp")%>%
  janitor::clean_names()%>%filter(dpto_ccdgo!=88)%>%mutate(dpto_ccdgo=as.numeric(dpto_ccdgo))

Anio=2014
Mes=11
Producto= "Aguacate papelillo"

mapa_dif <- function(Anio = NULL, Mes = NULL, Producto = NULL) {
  df <- data
  
  # Determina qué columnas y condiciones de filtrado usar
  cols <- c("cod_depto", "departamento")
  cond <- list()
  comp_col <- "comparacion"
  if (!is.null(Anio)) {
    cond$year <- Anio
    comp_col <- "comparacion_anual"
  }
  if (!is.null(Mes)) {
    cond$mes <- Mes
    comp_col <- "comparacion_mensual"
  }
  if (!is.null(Producto)) {
    cond$producto <- Producto
    comp_col <- "comparacion_producto"
  }
  
  # Realiza la operación de filtrado y selección una sola vez
  df <- df %>%
    filter(!!!cond) %>%
    rename(comp = all_of(comp_col)) %>%
    select(cod_depto, departamento, comp) %>%
    unique()
  
  
  mapa<-shapefile%>%left_join(df, by = c("dpto_ccdgo"="cod_depto"))
  
  titulo <- paste("Precio con respecto a Medellín", ifelse(is.null(Anio), "", paste("en el año", Anio)),
                  ifelse(is.null(Mes), "", paste("para el mes", Mes)), 
                  ifelse(is.null(Producto), "", paste("-", Producto)))
  
  mapa$tooltip_text<-ifelse(is.na(mapa$departamento),"",paste("Departamento: ",mapa$departamento,
                              "<br>Diferencia de precio: $", round(mapa$comp)))
  
  if (nrow(df) == 0) {
    print("No hay datos disponibles")
  } else {
    p <- ggplot() +
    geom_sf(data = mapa, aes(fill = comp, text = tooltip_text)) +
    scale_fill_gradient2(low = "#1A4922", mid = "white", high = "#F39F06", midpoint = 0, na.value = "#D5D5D5", name = "Diferencia\ndel precio") +
    labs(title = "") +
    theme_minimal() +
    theme(
      plot.background = element_blank(),  # Hace que el fondo sea transparente
      panel.background = element_blank(),  # Hace que el fondo del panel sea transparente
      panel.grid = element_blank(),  # Elimina las líneas de la cuadrícula
      axis.line = element_blank(),
      axis.text = element_blank(),
      axis.ticks = element_blank(),
      axis.title = element_blank()
    )
    map<-plotly::ggplotly(p, tooltip = "text")
  }
  
  
  precio_max <- ifelse(nrow(df) == 0,"",round(max(df$comp)))
  precio_min <- ifelse(nrow(df) == 0,"",round(min(df$comp)*-1))
  ciudad_max <- df$departamento[which.max(df$comp)]
  ciudad_min <- df$departamento[which.min(df$comp)]
  return(list(
    grafico=map,
    datos=df,
    precio_max=precio_max,
    precio_min=precio_min,
    ciudad_max=ciudad_max,
    ciudad_min=ciudad_min
  ))
  
}

#mapa_dif()
#mapa_dif(Anio=2023)
#mapa_dif(Anio=2023, Mes=1)
#mapa_dif(Anio=2023, Mes=1, Producto = "Aguacate")
#mapa_dif(Mes=1, Producto = "Aguacate")
#mapa_dif(Mes=1)
#mapa_dif(Anio=2023, Producto = "Aguacate")
#mapa_dif(Producto = "Aguacate")





