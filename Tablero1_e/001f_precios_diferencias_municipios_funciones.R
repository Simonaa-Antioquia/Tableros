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
library(readr);library(lubridate);library(zoo);library(stringr);library(tidyr);library(ggrepel)
################################################################################-

data <- readRDS("base_precios_vs_medellin.rds")

diferencias_precios <- function(opcion1,opcion2 = NULL, opcion3 = NULL,opcion4 = NULL) {
  df <- data
  
  if (opcion2 != "" & opcion3 != "") {
    df <- df %>% filter(year == opcion2 & mes == opcion3)
    
    if(!is.null(opcion4)) {
      var <- 29
      std <- 0
    } else {
      var <- 30
      std <- 9
    }
  } else if (opcion2 != "") {
    df <- df %>% filter(year == opcion2)
    
    if(!is.null(opcion4)) {
      var <- 33
      std <- 15
    } else {
      var <- 34
      std <- 17
    }
  } else if (opcion3 != "") {
    df <- df %>% filter(mes == opcion3)
    
    if(!is.null(opcion4)) {
      var <- 31
      std <- 11
    } else {
      var <- 32
      std <- 13
    }
  } else {
    if(!is.null(opcion4)) {
      var <- 36
      std <- 21
    } else {
      var <- 35
      std <- 19
    }
  }
  
  if (!is.null(opcion4)) {
    df <- df %>%
      filter(producto == opcion4)
  }
  
  if(std != 0){
    df <- df[,c(var,6,37,std)]
    colnames(df)[4] <- "dev"
    
    if(sum(is.na(df$dev)) > 0){
      df$dev[is.na(df$dev)] <- 1
    }
    
  } else {
    df <- df[,c(var,6,37)]
  }
  
  df <- df[!(duplicated(df[c("ciudad")])),]
  
  colnames(df)[1] <- "comp"
  
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
  
  #Alternar ángulos
  angulos <- 90
  for(i in 2:nrow(df)){
    if(i%%2 == 0) {
      angulos <- c(angulos,90)
    } else {
      angulos <- c(angulos,-90)
    }
    
  }
  
  #Mapa
  if(std != 0){
    map <- ggplot(df, aes(x=comp,y=axis,color=ciudad)) +
      geom_point(aes(size = dev), alpha = 0.6) +
      theme_bw() +
      theme(legend.position="none",axis.title.y=element_blank(),axis.text.y=element_blank(),axis.ticks.y=element_blank()) +
      geom_text(aes(label=ciudad),size = 4.5,hjust=2, vjust=0, angle = angulos) +
      #geom_text_repel(aes(label=ciudad),size = 4.5,segment.color = 'transparent',hjust=2,vjust=0,angle = 90) +
      geom_vline(xintercept = 0,linetype = "longdash",size=0.5,alpha = 0.2) +
      # gganimate specific bits:
      labs(title = 'Precio promedio mensual en relación a Medellín', x = 'Diferencia de precio', y = '') +
      transition_reveal(indice) +
      view_follow() +
      ease_aes('linear')+
      scale_size(range = c(5,25))
  } else {
    map <- ggplot(df, aes(x=comp,y=axis,color=ciudad)) +
      geom_point(size=10) +
      theme_bw() +
      theme(legend.position="none",axis.title.y=element_blank(),axis.text.y=element_blank(),axis.ticks.y=element_blank()) +
      geom_text(aes(label=ciudad),size = 4.5,hjust=2, vjust=0, angle = 90) +
      geom_vline(xintercept = 0,linetype = "longdash",size=0.5,alpha = 0.2) +
      # gganimate specific bits:
      labs(title = 'Precio promedio mensual en relación a Medellín', x = 'Diferencia de precio', y = '') +
      transition_reveal(indice) +
      view_follow() +
      ease_aes('linear')
  }
  
  p<-anim_save("outfile.gif",animate(map))
  precio_max <- round(max(df$comp))
  precio_min <- round(min(df$comp)*-1)
  ciudad_max <- df$ciudad[which.max(df$comp)]
  ciudad_min <- df$ciudad[which.min(df$comp)]
  
  return(list(
    grafico = p,
    datos = df,
    precio_max=precio_max,
    precio_min=precio_min,
    ciudad_max=ciudad_max,
    ciudad_min=ciudad_min
  ))
}

#diferencias_precios(opcion1 = "General", opcion2 = 2013, opcion3 = "")
