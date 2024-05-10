#Proyecto FAO
#INDICE DE VULNERABILIDAD 
#Funciones
################################################################################
#Autores: Juan Carlos, Juliana Lalinde, Laura Quintero, Germán Angulo
#Fecha de creacion: 17/04/2024
#Fecha de ultima modificacion: 17/04/2024
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
#source("009a_Indice:Vulnerabilidad.R")
# Bases de datos 
indice_v_anual <- read.csv("base_indice_anual_todos.csv")
indice_v_anual$anio <-  as.numeric(indice_v_anual$anio)
indice_v_anual$indice_vulnerabilidad <- as.numeric(indice_v_anual$indice_vulnerabilidad)
indice_v_anual_producto <- read.csv("base_indice_anual_productos.csv")
indice_v_general <- read.csv("base_indice.csv")
indice_v_general_producto <- read.csv("base_indice_productos.csv")
indice_v_mensual <- read.csv("base_indice_mensual.csv")
indice_v_mensual$mes_y_ano <- as.Date(indice_v_mensual$mes_y_ano)
indice_v_mensual_producto <- read.csv("base_indice_mensual_productos.csv")
indice_v_mensual_producto$mes_y_ano <- as.Date(indice_v_mensual_producto$mes_y_ano)


# LINEA DE TIEMPO 

col_palette <- c("#1A4922", "#2E7730", "#0D8D38", "#85A728", "#AEBF22", "#F2E203", "#F1B709", "#F39F06", "#BE7E11",
                 "#08384D", "#094B5C", "#00596C", "#006A75", "#007A71", "#00909C", "#0088BB", "#007CC3", "#456ABB")


grafica_indice <- function(tipo, anio_seleccionado = "", productos_seleccionados = "") {
  if (tipo == 1 ) {
    df <- indice_v_anual
    df$indice_vulnerabilidad <- df$indice_vulnerabilidad * 100
    df <- df %>%
      select("anio", "indice_vulnerabilidad")
  } else if (tipo == 2) {
    df <- indice_v_anual_producto
    df$indice_vulnerabilidad <- df$indice_vulnerabilidad *100
    df <- df %>%
      select("anio","producto", "indice_vulnerabilidad")
    if (length(productos_seleccionados) == 0){
      stop("Para esta opcion debe escoger los productos que quiere graficar")
    }
    if (anio_seleccionado != ""){
      stop("Para esta opcion debe escoger los productos que quiere graficar")
    }
    
  } else if (tipo == 3) {
    df <- indice_v_mensual
    df$indice_vulnerabilidad <- df$indice_vulnerabilidad *100
    df <- df %>%
      select("mes_y_ano","anio","mes","indice_vulnerabilidad")
    if (anio_seleccionado != ""){
      df <- df %>%
        filter(anio_seleccionado == anio)
    }
  } else if (tipo == 4) {
    df <- indice_v_mensual_producto 
    df$indice_vulnerabilidad <- df$indice_vulnerabilidad *100
    df <- df %>%
      select("anio","mes","mes_y_ano","producto", "indice_vulnerabilidad")
    if (anio_seleccionado != ""){
      df <- df %>%
        filter(anio_seleccionado == anio)}
  }
  if (tipo == 2) {
    df <- rename(df, fecha = anio) 
    df <- df[df$producto %in% productos_seleccionados, ]
    df$tooltip_text <- paste("Año: ", df$fecha , "<br> Producto:",df$producto, "<br> I.Vulnerabilidad:" , round(df$indice_vulnerabilidad,3))
    p <- ggplot(df, aes(x = fecha, y = indice_vulnerabilidad, color = producto)) +
      geom_line() +
      geom_point(aes(text = tooltip_text), size = 1e-8) +
      labs(x = "Año", y = "Indice de Vulnerabilidad") +
      theme_minimal() +
      scale_color_manual(values = col_palette) + 
      theme(text = element_text(family = "Prompt", size = 16))+
      scale_x_continuous(breaks = unique(df$fecha))

  }else if (tipo == 4){
    df <- rename(df, fecha = mes_y_ano)
    df <- df[df$producto %in% productos_seleccionados, ]
    df$tooltip_text <- paste("Año: ", df$anio , "<br> Mes:",df$mes, "<br> Producto:",df$producto, "<br> I.Vulnerabilidad:" , round(df$indice_vulnerabilidad,3))
    p <- ggplot(df, aes(x = fecha, y = indice_vulnerabilidad, color = producto)) +
      geom_line() +
      geom_point(aes(text = tooltip_text), size = 1e-8) +
      labs(x = "Año", y = "Indice de Vulnerabilidad") +
      theme_minimal() +
      scale_color_manual(values = col_palette) + 
      theme(text = element_text(family = "Prompt", size = 16)) 
  } else if (tipo == 1) {
      df <- rename(df, fecha = anio) 
      df$tooltip_text <- paste("Año: ", df$fecha ,  "<br> I.Vulnerabilidad:" , round(df$indice_vulnerabilidad,3))
      p<- ggplot(df, aes(x = fecha, y = indice_vulnerabilidad)) +
        geom_line() +
        geom_point(aes(text = tooltip_text), size = 1e-8) +
        labs(x = "Año", y = "Indice de Vulnerabilidad") +
        theme_minimal()  +
        scale_color_manual(values = col_palette) +
        theme(text = element_text(family = "Prompt", size = 16))+
        scale_x_continuous(breaks = unique(df$fecha))
      
    }else if (tipo == 3){
      df <- rename(df, fecha = mes_y_ano)
      df$tooltip_text <- paste("Año: ", df$anio , "<br> Mes:",df$mes, "<br> I.Vulnerabilidad:" , round(df$indice_vulnerabilidad,3))
      p<- ggplot(df, aes(x = fecha, y = indice_vulnerabilidad)) +
        geom_line() +
        geom_point(aes(text = tooltip_text), size = 1e-8) +
        labs(x = "Año", y = "Indice de Vulnerabilidad") +
        theme_minimal()  +
        scale_color_manual(values = col_palette) 
        
      }
  # Calcular el valor máximo del índice de vulnerabilidad
  indice_max_vulnerabilidad <- which.max(df$indice_vulnerabilidad)
  max_vulnerabilidad <- round(df$indice_vulnerabilidad[indice_max_vulnerabilidad], 3)
  fecha_max_vulnerabilidad <- df$fecha[indice_max_vulnerabilidad]
  producto_max_vulnerabilidad <- ifelse("producto" %in% names(df), df$producto[indice_max_vulnerabilidad], NA)
  
  p <- plotly::ggplotly(p, tooltip = "text")
  
  # Devolver el gráfico, los datos y los valores máximos
  return(list(
    grafico = p,
    datos = df,
    max_vulnerabilidad = max_vulnerabilidad,
    fecha_max_vulnerabilidad = fecha_max_vulnerabilidad,
    producto_max_vulnerabilidad = producto_max_vulnerabilidad
  ))
}

#grafica_indice(1)
#grafica_indice(2,"",c("CEBOLLA JUNCA","ARROZ"))
#grafica_indice(3)
#grafica_indice(3,2015)
#grafica_indice(4, , c("CEBOLLA JUNCA" , "ARROZ", "TOMATE CHONTO"))
#grafica_indice(4,2015, c("CEBOLLA JUNCA" , "ARROZ"))

