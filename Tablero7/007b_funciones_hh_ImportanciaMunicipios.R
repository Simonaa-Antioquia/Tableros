#Proyecto FAO
#INDICE DE IMPORTANCIA DE LOS MUNICIPIOS EN EL ABASTECIMIENTO DE ANTIOQUIA
#FUNCIONES
################################################################################
#Autores: Juan Carlos, Juliana Lalinde, Laura Quintero, Germán Angulo
#Fecha de creacion: 24/04/2024
#Fecha de ultima modificacion: 24/04/2024
################################################################################
# Paquetes 
library(readr);library(lubridate);library(dplyr);library(ggplot2);library(zoo);library(readxl)
library(glue);library(tidyverse);library(haven); library(DT);library(extrafont);
options(scipen = 999)
################################################################################
rm(list = ls())
#font_import(pattern = "Prompt.ttf")
#loadfonts(device = "win")
############
#source("007a_HHINDEX_participacion_municipios.R")
# Bases de datos 
IHH_anual_producto <- read.csv("base_IHH_anual_producto_importanciadelosmunicipios.csv", row.names = 1) %>%
  rename(year = anio)
IHH_anual_total <- read.csv("base_IHH_anual_total_importanciadelosmunicipios.csv", row.names = 1) %>%
  rename(year = anio)
IHH_mensual_producto <- read.csv("base_IHH_mensual_producto_importanciadelosmunicipios.csv", row.names = 1) %>%
  mutate(mes_y_ano = as.Date(mes_y_ano, format = "%Y-%m-%d")) 
IHH_mensual_total <- read.csv("base_IHH_mensual_total_importanciadelosmunicipios.csv", row.names = 1) %>%
  mutate(mes_y_ano = as.Date(mes_y_ano, format = "%Y-%m-%d"))


# FUNCIONES  
# Temporal (serie de tiempo)

col_palette <- c("#1A4922", "#2E7730", "#0D8D38", "#85A728", "#AEBF22", "#F2E203", "#F1B709", "#F39F06", "#BE7E11",
                 "#08384D", "#094B5C", "#00596C", "#006A75", "#007A71", "#00909C", "#0088BB", "#007CC3", "#456ABB")


grafica_indice_mun <- function(tipo, anio_seleccionado = "", productos_seleccionados = "") {
  if (tipo == 1 ) {
    df <- IHH_anual_total
    df <- df %>%
      select("year", "IHH")
  } else if (tipo == 2) {
    df <- IHH_anual_producto
    df <- df %>%
      select("year","producto", "IHH")
    if (length(productos_seleccionados) == 0){
      stop("Para esta opcion debe escoger los productos que quiere graficar")
    }
  } else if (tipo == 3) {
    df <- IHH_mensual_total
    df <- df %>%
      select("mes_y_ano","year","month","IHH")
    if (anio_seleccionado != ""){
      df <- df %>%
        filter(anio_seleccionado == year)
    }
  } else if (tipo == 4) {
    df <- IHH_mensual_producto
    df <- df %>%
      select("year","month","mes_y_ano","producto", "IHH")
    if (anio_seleccionado != ""){
      df <- df %>%
        filter(anio_seleccionado == year)
    }
  }
  if (tipo == 2) {
    df <- rename(df, fecha = year) 
  }else if (tipo == 4){
    df <- rename(df, fecha = mes_y_ano)
  }
  
  # Filtrar los productos seleccionados solo para las opciones 2 y 4
  if (tipo %in% c(2, 4)) {
    df <- df[df$producto %in% productos_seleccionados, ]
    p <- ggplot(df, aes(x = fecha, y = IHH, color = producto)) +
      geom_line() +
      labs(x = "Fecha", y = "Municipios en el abastecimiento") +
      theme_minimal() +
      scale_color_manual(values = col_palette) + 
      theme(text = element_text(family = "Prompt", size = 16)) 
  } else {
    if (tipo == 1) {
      df <- rename(df, fecha = year) 
    }else if (tipo == 3){
      df <- rename(df, fecha = mes_y_ano)
    }
    p<- ggplot(df, aes(x = fecha, y = IHH)) +
      geom_line() +
      labs(x = "Fecha", y = "Municipios en el abastecimiento") +
      theme_minimal()  +
      scale_color_manual(values = col_palette) +
      theme(text = element_text(family = "Prompt", size = 16)) 
  }
  
  # Calcular el valor máximo del índice de vulnerabilidad
  indice_max_ihh <- which.max(df$IHH)
  max_IHH <- round(df$IHH[indice_max_ihh], 3)
  fecha_max_vulnerabilidad <- df$fecha[indice_max_ihh]
  producto_max_vulnerabilidad <- ifelse("producto" %in% names(df), df$producto[indice_max_ihh], NA)
  
  # Devolver el gráfico, los datos y los valores máximos
  return(list(
    grafico = p,
    datos = df,
    max_vulnerabilidad = max_IHH,
    fecha_max_vulnerabilidad = fecha_max_vulnerabilidad,
    producto_max_vulnerabilidad = producto_max_vulnerabilidad
  ))
} 


# Ejemplos:
# Informacion anual 
#grafica_indice_mun(1)
#grafica_indice_mun(2,"",c("ARROZ","CARNE DE CERDO","FRÍJOL"))
#grafica_indice_mun(3)
#grafica_indice_mun(3,2023)
#grafica_indice_mun(4,"",c("ARROZ","CARNE DE CERDO","FRÍJOL"))
#grafica_indice_mun(4,2022,c("ARROZ","CARNE DE CERDO","FRÍJOL"))







