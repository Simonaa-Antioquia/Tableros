#Proyecto FAO
#INDICE Herfindahl–Hirschman - Abastecimiento tablero 1 
################################################################################
#Autores: Juan Carlos, Juliana Lalinde, Laura Quintero, Germán Angulo
#Fecha de creacion: 14/03/2024
#Fecha de ultima modificacion: 21/02/2024
################################################################################
# Paquetes 
################################################################################
library(readr);library(lubridate);library(dplyr);library(ggplot2);library(zoo);library(readxl)
library(glue);library(tidyverse);library(extrafont);library(plotly);
options(scipen = 999)
################################################################################
rm(list = ls())
#font_import(pattern = "Prompt.ttf", prompt = FALSE)
#loadfonts(device = "win")
################################################################################

IHH_anual<-readRDS("IHH_anual_abastecimiento.rds")
IHH_total<-readRDS("IHH_total_abastecimiento.rds")
IHH_mensual<-readRDS("IHH_mensual_abastecimiento.rds")%>%
  mutate(mes_y_ano = floor_date(as.Date(as.yearmon(mes_y_ano, "%Y-%m"), frac = 1), "month"))


# Función para producir un gráfico de tiempo
plot_data <- function(tipo, anio = NULL) {
  # Elegir el data frame correcto y el título
  if (tipo == 1) {
    data <- IHH_anual
    data <- rename(data, date_col = year)
    data$year <- data$date_col
    data$IHH <- data$IHH * 100 
    
    # Crear un gráfico de tiempo
    data$tooltip_text <- paste("Año: ", data$year , "<br> IHH:" , round(data$IHH,3))
    p <- ggplot(data, aes_string(x = "date_col", y = "IHH")) +
      geom_line(color = "#2E7730") +
      geom_point(aes(text = tooltip_text),size = 1e-8) +
      labs(x = "Año - Mes", y = "Variedad en la oferta %") +
      theme_minimal() +  # Usar un tema minimalista
      scale_color_manual(values = "#2E7730") +  # Establecer el color de la línea
      theme(text = element_text(family = "Prompt", size = 16)) + # Establecer la fuente y el tamaño del texto
      scale_x_continuous(breaks = seq(min(data$date_col), max(data$date_col), by = 1))  # Establecer las marcas del eje x
    
  } else {
    data <- IHH_mensual
    data <- rename(data, date_col = mes_y_ano)
    data$IHH <- data$IHH *100
    data$tooltip_text <- paste("Año: ", data$year , "<br> IHH:" , round(data$IHH,3))
    
    # Si se especificó un año, filtrar los datos para ese año
    if (!is.null(anio)) {
    data$tooltip_text <- paste("Año: ", data$year , "<br> Mes:" , data$month,  "<br> IHH:" , round(data$IHH,3))
      data <- data %>% filter(year == anio)
    }
    # Crear un gráfico de tiempo
    p <- ggplot(data, aes_string(x = "date_col", y = "IHH")) +
      geom_line(color = "#2E7730") +
      geom_point(aes(text = tooltip_text),size = 1e-8) +
      labs(x = "Año - Mes", y = "Variedad en la oferta %") +
      theme_minimal() +  # Usar un tema minimalista
      scale_color_manual(values = "#2E7730") +  # Establecer el color de la línea
      theme(text = element_text(family = "Prompt", size = 16)) # Establecer la fuente y el tamaño del texto
  }
  

  data<-data%>%select(-tooltip_text)
  # Calcular el valor máximo del índice de vulnerabilidad
  max_IHH <- which.max(data$IHH)
  max_IHH_value <- round(data$IHH[max_IHH], 3)
  mes_max_IHH <- data$month[max_IHH]
  anio_max_IHH <- data$year[max_IHH]
  
  p <- plotly::ggplotly(p, tooltip = "text")
  
  return(list("plot" = p, "data" = data, "max_IHH" = max_IHH_value, "mes_max_IHH" = mes_max_IHH,"anio_max_IHH" = anio_max_IHH))
}



# Uso de la función
# Informacion Anual
#plot_data(1)
# Informmacion mensual - total
#plot_data(0)
# Informacion mensual - por año
#plot_data(0,2013)

