#Proyecto FAO
#Procesamiento datos SIPSA
################################################################################-
#Autores: Juliana Lalinde, Laura Quintero, Germán Angulo
#Fecha de creacion: 16/04/2024
#Fecha de ultima modificacion: 16/04/2024
################################################################################-
# Limpiar el entorno de trabajo
rm(list=ls())
# Paquetes 
################################################################################-
library(readr);library(lubridate);library(dplyr);library(ggplot2);library(zoo);library(readxl)
library(glue);library(tidyverse);library(gridExtra);library(corrplot);library(plotly)
options(scipen = 999)
################################################################################-

data<-readRDS("base_precios_cambio.rds")%>%
  filter(ciudad == "Medellín")
complet<-readRDS("base_precios_cantidades_distancias.rds")

##Funcion para ver el promedio por mes de los precios y cantidades en todos los años

# Usa la función para graficar la cantidad y el precio mensual de un producto específico
# (reemplaza 'nombre_del_producto' con el nombre del producto que quieres graficar)
#graficar_producto_y_precio(complet, 'total')

#Gráficas precios----
# Define la función

#Sys.setlocale("LC_TIME", "Spanish")

graficar_variable <- function(df, variable, alimento = NULL, fecha = NULL) {
  # Si no se proporciona alimento, calcula el promedio
  if (!is.null(alimento)) {
    producto_vol<-"Solo se tiene un producto"
    df <- df %>%
      filter(producto == alimento)
    
    # Prepara los datos
    df_graf <- df %>%
      arrange( producto, mes_y_ano)%>%
      mutate(precio_prom=round(precio_prom)) %>%
      mutate(cambio_pct = round((precio_prom / lag(precio_prom) - 1) * 100))  %>%
      mutate(mes_y_ano = floor_date(as.Date(as.yearmon(mes_y_ano, "%Y-%m"), frac = 1), "month")) %>%
      drop_na(mes_y_ano) %>%
      complete( mes_y_ano = seq.Date(min(mes_y_ano, na.rm = TRUE), max(mes_y_ano, na.rm = TRUE), by = "month")) %>%
      mutate(cambio_pct_anual = round((precio_prom / lag(precio_prom, 12) - 1) * 100,1))
  } else {
    
    if(is.null(fecha)){
      df_volatilidad <- df %>%
      #filter(ciudad == "Medellín")%>%
      group_by(producto) %>%
      summarise(volatilidad = sd(precio_prom, na.rm = TRUE), .groups = "drop")%>%
      ungroup()
    }else{
        df_volatilidad <- df %>%
          #filter(ciudad == "Medellín")%>%
          filter(anio == fecha)%>%
          group_by(producto) %>%
          summarise(volatilidad = sd(precio_prom, na.rm = TRUE), .groups = "drop")%>%
          ungroup()
      }
    
    producto_vol<-paste0("El precio de ",df_volatilidad$producto[which.max(df_volatilidad$volatilidad)]," experimenta cambios significativos con frecuencia, lo que lo hace más volátil que otros productos.")
    
    df <- df %>%
      group_by( mes_y_ano, anio) %>%
      summarise(precio_prom = round(mean(precio_prom, na.rm = TRUE)), .groups = "drop")
    
    #df <- df# %>%
     # filter(ciudad == "Medellín")
    
    df_graf <- df %>%
      arrange( mes_y_ano) %>%
      mutate(precio_prom=round(precio_prom))%>%
      mutate(cambio_pct = round((precio_prom / lag(precio_prom) - 1) * 100)) %>%
      mutate(mes_y_ano = floor_date(as.Date(as.yearmon(mes_y_ano, "%Y-%m"), frac = 1), "month")) %>%
      drop_na(mes_y_ano) %>%
      complete(mes_y_ano = seq.Date(min(mes_y_ano, na.rm = TRUE), max(mes_y_ano, na.rm = TRUE), by = "month")) %>%
      mutate(cambio_pct_anual = round((precio_prom / lag(precio_prom, 12) - 1) * 100,1)) 
  }
  
  # Si se proporciona un valor para fecha, filtra por año
  if (!is.null(fecha)) {
    df_graf <- df_graf %>%
      filter(anio == fecha)
  }
  vaiable2<-ifelse(variable=="precio_prom", "Precio promedio",
                   ifelse(variable=="cambio_pct", "Cambio porcentual","Cambio porcentual año anterior"))
  titulo<-paste("Tendencia de", tolower(vaiable2),ifelse(is.null(alimento),"",paste("para", alimento) ))
  # Crea la gráfica
  
  df_graf$tooltip_text <- paste("Fecha: ", format(as.Date(df_graf$mes_y_ano), "%B-%Y"), 
                                case_when(
                                  variable == "precio_prom" ~ paste("<br>Precio promedio: ", formatC(df_graf$precio_prom, format = "f", big.mark = ".", decimal.mark = ",", digits = 0)),
                                  variable == "cambio_pct" ~ paste("<br>Cambio porcentual: ", df_graf$cambio_pct),
                                  variable == "cambio_pct_anual" ~ paste("<br>Cambio porcentual año anterior: ", df_graf$cambio_pct_anual)
                                ),
                                case_when(
                                  variable == "precio_prom" ~ "",
                                  variable == "cambio_pct" ~ "%",
                                  variable == "cambio_pct_anual" ~ "%"
                                ))
  
  if(is.null(fecha)){
  p<-ggplot(df_graf, aes(x = mes_y_ano, y = !!sym(variable), group = 1)) +
    geom_line(aes(text = tooltip_text),color = "#0D8D38") +
    scale_x_date(date_labels = "%Y-%m", date_breaks = "12 month") +
    xlab("Fecha")+
    labs( y = "", 
         title = "") +
    theme_minimal()
  }else{
    
    mes_en_espanol <- function(x) {
      meses <- c("ene", "feb", "mar", "abr", "may", "jun", "jul", "ago", "sep", "oct", "nov", "dic")
      meses[month(x)]
    }
    
    # Convertir la columna de fecha a un formato de fecha y extraer el mes en español
    df_graf$mes_y_ano <- as.Date(df_graf$mes_y_ano)
    df_graf$mes <- factor(mes_en_espanol(df_graf$mes_y_ano), levels = c("ene", "feb", "mar", "abr", "may", "jun", "jul", "ago", "sep", "oct", "nov", "dic"))
    
    p <- ggplot(df_graf, aes(x = mes, y = !!sym(variable), group = 1)) +
      geom_line(aes(text = tooltip_text),color = "#0D8D38") +
      scale_x_discrete() +
      xlab("Fecha") +
      labs(y = "", title = "") +
      theme_minimal()
  }
  
  map<-plotly::ggplotly(p, tooltip = "text")
  datos<-df_graf
  convertir_mes <- function(fecha) {
    meses_ingles <- c("January", "February", "March", "April", "May", "June", 
                      "July", "August", "September", "October", "November", "December")
    meses_espanol <- c("Enero", "Febrero", "Marzo", "Abril", "Mayo", "Junio", 
                       "Julio", "Agosto", "Septiembre", "Octubre", "Noviembre", "Diciembre")
    fecha_formato <- format(fecha, "%B-%Y")
    for (i in 1:12) {
      fecha_formato <- gsub(meses_ingles[i], meses_espanol[i], fecha_formato)
    }
    return(fecha_formato)
  }
  promedio <- round(mean(datos$precio_prom, na.rm = TRUE))
  fecha_max <- as.Date(datos$mes_y_ano[which.max(datos$precio_prom)])
  fecha_max <- convertir_mes(fecha_max)
  fecha_min <- as.Date(datos$mes_y_ano[which.min(datos$precio_prom)])
  fecha_min <- convertir_mes(fecha_min)
  precio_max <- formatC(max(datos$precio_prom, format = "f", big.mark = ".", decimal.mark = ",", digits = 0))
  precio_min <- formatC(min(datos$precio_prom, format = "f", big.mark = ".", decimal.mark = ",", digits = 0))
  producto_vol<-producto_vol
  promedio_camb<-paste0("En promedio, los precios de los productos variaron un ",round(mean(datos$cambio_pct, na.rm = TRUE)), "%")
  
  fecha_max2 <- as.Date(datos$mes_y_ano[which.max(datos$cambio_pct_anual)])
  cambio_max <- max(datos$cambio_pct_anual, na.rm = TRUE)
  
  mes <- format(fecha_max2, "%B")
  ano <- format(fecha_max2, "%Y")
  ano_anterior <- as.integer(ano) - 1
  
  promedio_camb_an <- ifelse(is.null(fecha),
                             paste0("En ", mes, " de ", ano, ", los precios subieron un ", cambio_max, "% comparado con ", mes, " del año anterior."),
                             ifelse(fecha != 2013,
                                    paste0("En ", mes, " de ", ano, ", los precios subieron un ", cambio_max, "% comparado con ", mes, " del año anterior."),
                                    "2013 es el primer año con datos por lo que no se puede mostrar la variación intranual"))
  return(
    list(
      grafico=map,
      grafico2=p,
      datos=datos,
      promedio=promedio,
      fecha_max=fecha_max,
      fecha_min=fecha_min,
      precio_max=precio_max,
      precio_min=precio_min,
      producto_vol=producto_vol,
      promedio_camb=promedio_camb,
      promedio_camb_an=promedio_camb_an
    )
  )
}

# n<-graficar_variable(data, "precio_prom")$grafico2
#graficar_variable(data, "precio_prom", alimento = "Aguacate", fecha="2020")
# Usa la función para graficar la variable "precio" para la ciudad "Bogota" y el producto "Arroz"

# Define la función
graficar_variables <- function(df, producto=NULL, fecha = NULL) {
  # Crea las tres gráficas
  grafica1 <- graficar_variable(df, "precio_prom", producto,  fecha)
  grafica2 <- graficar_variable(df,"cambio_pct",  producto,  fecha)
  grafica3 <- graficar_variable(df, "cambio_pct_anual", producto, fecha)
  
  convertir_mes <- function(fecha) {
    meses_ingles <- c("January", "February", "March", "April", "May", "June", 
                      "July", "August", "September", "October", "November", "December")
    meses_espanol <- c("Enero", "Febrero", "Marzo", "Abril", "Mayo", "Junio", 
                       "Julio", "Agosto", "Septiembre", "Octubre", "Noviembre", "Diciembre")
    fecha_formato <- format(fecha, "%B-%Y")
    for (i in 1:12) {
      fecha_formato <- gsub(meses_ingles[i], meses_espanol[i], fecha_formato)
    }
    return(fecha_formato)
  }
  
  # Muestra las tres gráficas juntas
  p<-plotly::subplot(grafica1$grafico, grafica2$grafico, grafica3$grafico, nrows = 3)
  datos<-unique(rbind(grafica1$datos,grafica2$datos,grafica3$datos))
  promedio <- round(mean(datos$precio_prom, na.rm = TRUE))
  fecha_max <- as.Date(datos$mes_y_ano[which.max(datos$precio_prom)])
  fecha_max <- convertir_mes(fecha_max)
  fecha_min <- as.Date(datos$mes_y_ano[which.min(datos$precio_prom)])
  fecha_min <- convertir_mes(fecha_min)
  precio_max <- formatC(max(datos$precio_prom, format = "f", big.mark = ".", decimal.mark = ",", digits = 0))
  precio_min <- formatC(min(datos$precio_prom, format = "f", big.mark = ".", decimal.mark = ",", digits = 0))
  producto_vol<-grafica1$producto_vol
  promedio_camb<-round(mean(datos$cambio_pct, na.rm = TRUE))
  promedio_camb_an<-round(mean(datos$cambio_pct_anual, na.rm = TRUE))
  return(
    list(
      grafico=p,
      datos=datos,
      promedio=promedio,
      fecha_max=fecha_max,
      fecha_min=fecha_min,
      precio_max=precio_max,
      precio_min=precio_min,
      producto_vol=producto_vol,
      promedio_camb=promedio_camb,
      promedio_camb_an=promedio_camb_an
    )
  )
}

# Usa la función para graficar las variables "precio_prom", "cambio_pct" y "cambio_pct_anual" para la ciudad "Medellín" y el producto "Papa negra"
#graficar_variables(data, producto = "Papa criolla")


#graficar_variables(data, fecha = "2020")


# Ejemplo 1: Graficar el precio promedio para todas las ciudades y alimentos
#graficar_variable(df, "precio_prom")

# Ejemplo 2: Graficar el cambio porcentual para la ciudad "Medellin" y todos los alimentos
#graficar_variable(data, "cambio_pct")

# Ejemplo 3: Graficar el cambio porcentual anual para el alimento "arroz" en todas las ciudades
#graficar_variable(data, "cambio_pct_anual", alimento = "cebolla cabezona blanca")

# Ejemplo 4: Graficar el precio promedio para la ciudad "Medellin" y el alimento "arroz"
#graficar_variable(data, "precio_prom",  alimento = "papa negra")

# Ejemplo 5: Graficar el cambio porcentual para la ciudad "Medellin" y el alimento "arroz" en el año 2020
#graficar_variable(df, alimento = "papa criolla", fecha = 2020)















