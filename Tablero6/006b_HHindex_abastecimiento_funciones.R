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
library(glue);library(tidyverse);library(extrafont);
options(scipen = 999)
################################################################################
rm(list = ls())
#font_import(pattern = "Prompt.ttf", prompt = FALSE)
#loadfonts(device = "win")
################################################################################

IHH_anual<-read.csv("IHH_anual_abastecimiento.csv")
IHH_total<-read.csv("IHH_total_abastecimiento.csv")
IHH_mensual<-read.csv("IHH_mensual_abastecimiento.csv")%>%
  mutate(mes_y_ano = floor_date(as.Date(as.yearmon(mes_y_ano, "%Y-%m"), frac = 1), "month"))


# Función para producir un gráfico de tiempo
plot_data <- function(tipo, anio = NULL) {
  # Elegir el data frame correcto y el título
  if (tipo == 1) {
    data <- IHH_anual
    data <- rename(data, date_col = year)
    data$year <- data$date_col
  } else {
    data <- IHH_mensual
    data <- rename(data, date_col = mes_y_ano)
    # Si se especificó un año, filtrar los datos para ese año
    if (!is.null(anio)) {
      data <- data %>% filter(year == anio)
    }
  }
  
  # Crear un gráfico de tiempo
  p <- ggplot(data, aes_string(x = "date_col", y = "IHH")) +
    geom_line(color = "#2E7730") +
    labs(x = "Año - Mes", y = "Concentracion de Productos") +
    theme_minimal() +  # Usar un tema minimalista
    scale_color_manual(values = "#2E7730") +  # Establecer el color de la línea
    theme(text = element_text(family = "Prompt", size = 16)) # Establecer la fuente y el tamaño del texto
  
  
  # Calcular el valor máximo del índice de vulnerabilidad
  max_IHH <- which.max(data$IHH)
  max_IHH_value <- round(data$IHH[max_IHH], 3)
  mes_max_IHH <- data$month[max_IHH]
  anio_max_IHH <- data$year[max_IHH]
  
  return(list("plot" = p, "data" = data, "max_IHH" = max_IHH_value, "mes_max_IHH" = mes_max_IHH,"anio_max_IHH" = anio_max_IHH))
}



# Uso de la función
# Informacion Anual
#plot_data(1)
# Informmacion mensual - total
#plot_data(0)
# Informacion mensual - por año
#plot_data(0,2013)

