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
library(readr);library(lubridate);library(zoo);library(stringr);library(tidyr);library(ggrepel);library(stringr)
################################################################################-

#data <- readRDS("02_Indices/Output/base_precios_vs_medellin.rds")
# Cargamos bases de datos
data_comparacion_anual_mensual_producto <- readRDS("base_precios_data_comparacion_anual_mensual_producto.rds")
data_comparacion_anual_mensual <- readRDS("base_precios_data_comparacion_anual_mensual.rds")
data_comparacion_mensual_producto <- readRDS("base_precios_data_comparacion_mensual_producto.rds")
data_comparacion_mensual <- readRDS("base_precios_data_comparacion_mensual.rds")
data_comparacion_anual_producto <- readRDS("base_precios_data_comparacion_anual_producto.rds")
data_comparacion_anual <- readRDS("base_precios_data_comparacion_anual.rds")
data_comparacion_producto <- readRDS("base_precios_data_comparacion_producto.rds")
data_comparacion <- readRDS("base_precios_data_comparacion.rds")


col_palette <- c("#007CC3", "#456ABB","#1A4922", "#2E7730", "#0D8D38", "#85A728", "#AEBF22", "#F2E203", "#F1B709", "#F39F06", "#BE7E11",
                 "#08384D", "#094B5C", "#00596C", "#006A75", "#007A71", "#00909C", "#0088BB", "#007CC3", "#456ABB")

  #FUNCION
  #Opciones: 
  #  1 es tipo de funcion 
  #  2 es año
  #  3 es mes
  #  4 es producto 
  
  diferencias_precios <- function(opcion1, opcion2 = NULL, opcion3 = NULL,opcion4 = NULL) {
   
  # Cuando no se pone ninguna opcion se muestra el promedio general de datos  
     if (opcion1 == 1 & opcion2 == "" & opcion3 =="" & is.null(opcion4)) {
      df <- data_comparacion 
  # Se pone la opcion del año
    } else if (opcion1 == 1 & opcion2 != "" & opcion3 =="" & is.null(opcion4)) {
      df <- data_comparacion_anual %>% 
        filter(year == opcion2)
  # Se pone la opcion del mes     
    } else if (opcion1 == 1 & opcion2 == "" & opcion3 !="" & is.null(opcion4)) {
      df <- data_comparacion_mensual %>%
        filter(mes == opcion3)
  # Se pone la opcion del mes y del año    
    } else if (opcion1 == 1 & opcion2 != "" & opcion3 !="" & is.null(opcion4)) {
      df <- data_comparacion_anual_mensual %>%
        filter(mes == opcion3 & year == opcion2)
  # La opcion 1 cambia a 0. Todo es por producto
  # Informacion General de precios por producto    
    } else if (opcion1 == 0 & opcion2 == "" & opcion3 =="" & !is.null(opcion4)) {
      df <- data_comparacion_producto %>%
        filter(opcion4 == producto)
  # Informacion anual (promedio) por producto    
    } else if (opcion1 == 0 & opcion2 != "" & opcion3 =="" & !is.null(opcion4)) {
      df <- data_comparacion_anual_producto %>%
        filter(opcion4 == producto & opcion2 == year)
  # Informacion mensual (promedio) pro prodcuto  
      } else if (opcion1 == 0 & opcion2 == "" & opcion3 !="" & !is.null(opcion4)) {
      df <- data_comparacion_mensual_producto %>%
        filter(opcion4==producto & opcion3 == mes)
  # Infrmacion anual - mensual por producto    
      } else if (opcion1 == 0 & opcion2 != "" & opcion3 !="" & !is.null(opcion4)) {
        df_lista <- data_comparacion_anual_mensual_producto[[opcion4]]
        df_lista <- as.data.frame(df_lista)
        df <- filter(df_lista, year == opcion2 & mes == opcion3)
      }
    
    # Verificar si df está vacío
    if(nrow(df) == 0) {
      return("No hay datos disponibles para los criterios seleccionados.")
    }
    
  
  df <- df %>%
    dplyr::rename_with(~ ifelse(str_starts(.x, "sd_"), "dev", .x))
    
  df <- df %>%
    dplyr::rename_with(~ ifelse(str_starts(.x, "comparacion"), "comp", .x))  
  
    
  df <- df[!(duplicated(df[c("ciudad")])),]
  
    
    #Calcular indices de entrada al gráfico
    positives <- df[df$comp>0,c("comp","ciudad")]
    positives <- positives %>%
      arrange(comp) %>%
      mutate(indice = row_number())
    
    negatives <- df[df$comp<0,c("comp","ciudad")]
    negatives <- negatives%>%
      arrange(-comp) %>%
      mutate(indice = row_number())
    
    indices <- rbind(positives,negatives)
    
    df <- merge(df,indices,by=c("comp","ciudad"),all = T)
    df$indice[is.na(df$indice)] <- 0
    
    # Alternar ángulos
    angulos <- 90
    for(i in 2:nrow(df)){
      if(i%%2 == 0) {
        angulos <- c(angulos,90)
      } else {
        angulos <- c(angulos,-90)
      }
    }
    
    df_2<-df
    df$tooltip_text <- paste("Ciudad: ", df$ciudad, "<br>Diferencia de precio: ", round(df$comp, 0), "<br>Desviación Estándar:", round(df$dev, 0))
    
    map <- ggplot(df, aes(x=comp,y=1,color=ciudad)) +
      geom_point(aes(size = dev, text = tooltip_text), alpha = 0.8) +
      theme_bw() +
      theme(legend.position="none",axis.title.y=element_blank(),axis.text.y=element_blank(),axis.ticks.y=element_blank()) +
      #geom_text(aes(label=ciudad),size = 3.5, hjust=0.5, vjust=-2, angle = 90, colour = "#000000") +  
      geom_vline(xintercept = 0,linetype = "longdash",size=0.5,alpha = 0.2) +
      labs(title = ' ', x = ' ', y = '') +
      scale_size(range = c(5,15)) +
      scale_color_manual(values = col_palette)
    
    precio_max <- round(max(df$comp))
    precio_min <- round(min(df$comp)*-1)
    ciudad_max <- df$ciudad[which.max(df$comp)]
    ciudad_min <- df$ciudad[which.min(df$comp)]
    

    # Convertir a plotly y especificar que el texto del tooltip viene de la columna 'text'
    p <- plotly::ggplotly(map, tooltip = "text")
    

    for(i in 1:nrow(df)) {
      yshift_value <- ifelse(i %% 2 == 0, 80, -80)  # Alternar entre 70 y -70
      p <- p %>% plotly::add_annotations(
        x = df$comp[i], 
        y = 1, 
        text = df$ciudad[i], 
        showarrow = FALSE, 
        yshift = yshift_value,  
        textangle = -90,
        font = list(size = 10, family = 'Prompt', color = "#838B8B")
      )
    }

    map <- map + geom_text(aes(label=ciudad),size = 3.5, hjust=1.5, vjust=0, angle = angulos, colour = "#000000")
    precio_max <- round(max(df$comp))
    precio_min <- round(min(df$comp)*-1)
    ciudad_max <- df$ciudad[which.max(df$comp)]
    ciudad_min <- df$ciudad[which.min(df$comp)]
    
    return(list(
      grafico = p,
      grafico2 = map,
      datos = df_2,
      precio_max=precio_max,
      precio_min=precio_min,
      ciudad_max=ciudad_max,
      ciudad_min=ciudad_min
    ))
  }
  
  #diferencias_precios(opcion1 = 0, opcion2 = 2014, opcion3 = "",opcion4="Aguacate")$grafico2
