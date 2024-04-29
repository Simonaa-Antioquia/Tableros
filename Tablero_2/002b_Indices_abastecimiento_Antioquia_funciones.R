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
library(readr);library(lubridate);library(dplyr);library(ggplot2);library(zoo);library(readxl)
library(glue);library(tidyverse);library(gridExtra);library(corrplot);library(tools)
options(scipen = 999)
################################################################################-

abastecimiento_medellin<-read.csv("base_indices_abastecimiento.csv")%>%
  mutate(mes_y_ano = floor_date(as.Date(as.yearmon(mes_y_ano, "%Y-%m"), frac = 1), "month"))


tiempo <- function(opcion1, opcion2 = NULL, opcion3 = NULL, opcion4 = NULL) {
  df <- abastecimiento_medellin
  
  # Si opcion4 no es NULL, filtrar por año
  if (!is.null(opcion4)) {
    df <- df %>% filter(anio == opcion4)
  }
  
  if (opcion1 == "total") {
    df <- df %>%
      distinct(anio, mes, .keep_all = TRUE) %>%
      select(anio, mes, mes_y_ano, total_kilogramos_mes)
    
    ggplot(df, aes(x = mes_y_ano, y = total_kilogramos_mes)) +
      geom_line() +
      labs(title = "Total de toneladas que ingresan a Medellín por mes") +
      ylab("Total de toneladas que ingresan a Medellín por mes") +
      xlab("Información por meses") +
      theme_minimal() +
      theme(panel.grid.major = element_blank(), panel.grid.minor = element_blank())  
    
  } else if (opcion1 == "mpio_origen") {
    if (is.null(opcion2)) {
      stop("Debe proporcionar un municipio cuando opcion1 es 'mpio_origen'")
    }
    
    df <- df %>%
      distinct(anio, mes, mpio_origen, .keep_all = TRUE) %>%
      select(anio, mes, mes_y_ano, total_kilogramos_año_mes_municipio, mpio_origen) %>%
      filter(mpio_origen == opcion2)
    
    ggplot(df, aes(x = mes_y_ano, y = total_kilogramos_año_mes_municipio)) +
      geom_line() +
      labs(title = "Total de toneladas por municipio por mes") +
      ylab("Total de toneladas que ingresan a Medellín por mes") +
      xlab("Información por meses") +
      theme_minimal() +
      theme(panel.grid.major = element_blank(), panel.grid.minor = element_blank())
    
  } else if (opcion1 == "producto") {
    df <- df %>%
      distinct(anio, mes, producto, .keep_all = TRUE) %>%
      select(anio, mes, mes_y_ano, total_kilogramos_mes_producto, producto)
    
    if (!is.null(opcion3)) {
      df <- df %>%
        filter(producto == opcion3)
    }
    
    ggplot(df, aes(x = mes_y_ano, y = total_kilogramos_mes_producto, color = producto)) +
      geom_line() +
      labs(title = paste("Total de toneladas de", opcion3, "por mes")) +
      ylab("Total de toneladas") +
      xlab("Información Mensual") +
      theme_minimal() +
      theme(panel.grid.major = element_blank(), panel.grid.minor = element_blank())  # Elimina la cuadrícula
    
  } else if (opcion1 == "mpio_origen_producto") {
    if (is.null(opcion2) || is.null(opcion3)) {
      stop("Debe proporcionar un municipio y un producto cuando opcion1 es 'mpio_origen_producto'")
    }
    
    df <- df %>%
      distinct(anio, mes, mpio_origen, producto, mes_y_ano, .keep_all = TRUE) %>%
      select(anio, mes, mes_y_ano, total_kilogramos_año_mes_municipio_producto, mpio_origen, producto) %>%
      filter(mpio_origen == opcion2, producto == opcion3)
    
    ggplot(df, aes(x = mes_y_ano, y = total_kilogramos_año_mes_municipio_producto, color = producto)) +
      geom_line() +
      labs(title = paste("Total de toneladas de" , opcion3 , "que provienen del municipio de ", opcion2)) +
      ylab("Total toneladas") +
      xlab("Información Mensual") +
      theme_classic()  
  }
}

# Para obtener el total de toneladas que ingresan a Medellín por mes
#tiempo("total")
# Para obtener el total de toneladas que ingresan a Medellín por mes de un municipio específico
#tiempo("mpio_origen", "MEDELLÍN")
# Para obtener el total de toneladas de un producto específico que ingresan a Medellín por mes
#tiempo("producto", "", "arroz")
# Para obtener el total de toneladas de un producto específico que ingresan a Medellín por mes de un municipio específico
#tiempo("mpio_origen_producto", "MEDELLÍN", "arroz")
# Para obtener el total de toneladas que ingresan a Medellín por mes en un año específico
#tiempo("total", "" , "", 2021)
# Para obtener el total de toneladas que ingresan a Medellín por mes de un municipio específico en un año específico
#tiempo("mpio_origen", "MEDELLÍN", "", 2021)
# Para obtener el total de toneladas de un producto específico que ingresan a Medellín por mes en un año específico
#tiempo("producto", "", "arroz", 2018)
# Para obtener el total de toneladas de un producto específico que ingresan a Medellín por mes de un municipio específico en un año específico
#tiempo("mpio_origen_producto", "MEDELLÍN", "arroz", 2021)



# Funcion Numero 2

importancia <- function(Año = NULL, Mes = NULL, municipios = 10, Producto = NULL) {
  df <- abastecimiento_medellin
  
  # Año seleccionado
  if (!is.null(Año)) {
    df <- df %>% dplyr::filter(anio == Año)
  }
  
  # Mes seleccionado, si se proporciona
  if (!is.null(Mes)) {
    df <- df %>% dplyr::filter(mes == Mes)
  }
  
  # Si se especifica un producto
  if (!is.null(Producto)) {
    df <- df %>% dplyr::filter(producto == Producto)
  }
  
  # Determinar la columna de porcentaje
  if (!is.null(Año) && !is.null(Mes) && !is.null(Producto)) {
    
    df<- df  %>%
      distinct(anio, mpio_origen,producto,mes, .keep_all = TRUE) %>%
      select(anio, mpio_origen, mes, producto, mes_municipio_producto_porcentaje)  
    df <- df %>% rename( columna_porcentaje = mes_municipio_producto_porcentaje)
    
  } else if (!is.null(Año) && !is.null(Mes)) {
    
    df<- df  %>%
      distinct(anio, mpio_origen,mes, .keep_all = TRUE) %>%
      select(anio, mpio_origen, mes, mes_municipio_porcentaje)  
    columna_porcentaje <- "mes_municipio_porcentaje"
    df <- df %>% rename( columna_porcentaje = mes_municipio_porcentaje)
    
    
  } else if (!is.null(Año) && !is.null(Producto)) {
    
    df<- df  %>%
      distinct(anio, mpio_origen,producto, .keep_all = TRUE) %>%
      select(anio, mpio_origen, producto, año_municipio_producto_porcentaje)  
    columna_porcentaje <- "año_municipio_producto_porcentaje"
    df <- df %>% rename( columna_porcentaje =año_municipio_producto_porcentaje)
    
  } else if (!is.null(Año)){
    # No se tienen ni mes ni producto
    
    df<- df  %>%
      distinct(anio, mpio_origen, .keep_all = TRUE) %>%
      select(anio, mpio_origen, año_municipio_porcentaje)  
    df <- df %>% rename( columna_porcentaje = año_municipio_porcentaje)
    
  }else if (!is.null(Producto)){
    # No se tienen ni mes ni producto
    
    df<- df  %>%
      distinct( mpio_origen,producto, .keep_all = TRUE) %>%
      select( mpio_origen,producto, municipio_producto_porcentaje)  
    df <- df %>% rename( columna_porcentaje = municipio_producto_porcentaje)
    
  } else {
    
    df<- df  %>%
      distinct( mpio_origen, .keep_all = TRUE) %>%
      select( mpio_origen, municipio_porcentaje)  
    df <- df %>% rename( columna_porcentaje = municipio_porcentaje)
    
  }
  
  df <- df  %>% 
    arrange(desc(all_of(columna_porcentaje))) %>% 
    mutate( mpio_origen = factor( mpio_origen, levels =  mpio_origen)) %>% 
    head(municipios)
  
  # Grafica  
  # Crear un título dinámico
  titulo <- paste("Importancia de los", length(unique(df$ mpio_origen)), "municipios principales", ifelse(is.null(Año), "", paste("en el año", Año)), 
                  ifelse(is.null(Mes), "", paste("en el mes de", Mes)), 
                  ifelse(is.null(Producto), "", paste("-", Producto)))
  
  # Definir los colores de inicio y fin
  #start_color <- "#6B0077"
  #end_color <- "#ACE1C2"
  
  # Crear una función de interpolación de colores
  #color_func <- colorRampPalette(c(start_color, end_color))
  
  # Generar una paleta de N colores
  #N <- municipios
  #col_palette <- color_func(N)
  col_palette <- c("#1A4922", "#2E7730", "#0D8D38", "#85A728", "#AEBF22", "#F2E203", "#F1B709", "#F39F06", "#BE7E11",
                   "#08384D", "#094B5C", "#00596C", "#006A75", "#007A71", "#00909C", "#0088BB", "#007CC3", "#456ABB")
  
  # Ahora puedes usar col_palette en tu gráfico
  p<-ggplot(df, aes(x =  mpio_origen, y = as.numeric(all_of(columna_porcentaje)), fill =  mpio_origen)) +
    geom_bar(stat = "identity") +
    geom_text(aes(label = scales::percent(as.numeric(all_of(columna_porcentaje)), accuracy = 0.01)), hjust = -0.1) +
    coord_flip() +
    labs(x = "Municipio", y = "Porcentaje", title = titulo) +
    scale_fill_manual(values = col_palette) +  # Agregar la paleta de colores
    theme_minimal() +
    theme(panel.grid.major = element_blank(), panel.grid.minor = element_blank(), legend.position = "none")
  
  porcentaje_max<-round(max(df$columna_porcentaje)*100,1)
  lugar_max<-df$mpio_origen[which.max(df$columna_porcentaje)]
  
  return(
    list(
      grafico = p,
      datos = df,
      porcentaje_max=porcentaje_max,
      lugar_max=lugar_max
    )
  )
}


#importancia(2023)
#importancia(2023,1)
#importancia(2023,1,15,"lechuga batavia")
#importancia(Año = 2023, Producto = "lechuga batavia")
#importancia(municipios = 8,Producto = "carne de cerdo")
#importancia()


