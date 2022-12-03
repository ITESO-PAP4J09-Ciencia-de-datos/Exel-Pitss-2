library(tidyverse)
library(purrr)
library(fpp3)
library(GGally)

options(digits = 3)


#Base de datos--------------
servicios <- read_csv("servicios.csv") %>%
  select("fechaRecepcion", "tecnicoEjecutor", "NumVisitas", "horas", "tiemporespuesta", "TiempoefectivoenSitio",
         "ServiceRouteName", "SOCNAME", "productModel", "TiempoRespuestaSO") %>%
  separate(fechaRecepcion, c("Fecha", "Hora"), sep = " ") %>%
  separate(horas, c("HorasTST", "MinutosTST"), sep = ":",) %>%
  separate(tiemporespuesta, c("HorasTSP", "MinutosTSP"), sep = ":")%>%
  separate(TiempoRespuestaSO, c("HorasRespuesta", "MinutosRespuesta", "SegundosRespuesta"), sep = ":") %>%
  mutate(TiempoefectivoenSitio = as.numeric(TiempoefectivoenSitio)/3600,
         TST = as.numeric(HorasTST) + as.numeric(MinutosTST)/60,
         TSP = as.numeric(HorasTSP) + as.numeric(MinutosTSP)/60,
         RespuestaTecnico = as.numeric(HorasRespuesta) + as.numeric(MinutosRespuesta)/60)%>%
  mutate_if(is.numeric, ~replace(., is.na(.), 0)) %>%
  filter(SOCNAME %in% c("CORRECTIVO", "MANTENIMIENTO PREVENTIVO", "SERVICIO A TERCEROS"))

servicios <- servicios[, -5:-8]
servicios <- servicios[, -9:-11]

colnames(servicios) <- c("Fecha", "Hora", "Tecnico", "Visitas", "TiempoenSitio", "Estado", 
                         "Servicio", "Modelo", "TST", "TSP", "RespuestaTecnico")


# CLUSTERS TECNICOS------------------------------------------

#Creando estadisticos por tecnico
tecnicos_estadisticos <- servicios %>%
  group_by(Tecnico) %>%
  summarize(MediaVisitas = median(Visitas),
            MediaSitio = median(TiempoenSitio),
            MediaSolucionTotal = median(TST),
            MediaSolucionPits = median(TSP),
            MediaRespuesta = median(RespuestaTecnico))

summary(tecnicos_estadisticos)

#estandarizando
mean_sd_standard <- function (x) {
  (x- mean(x)) / sd(x)
}

tecnicos_st <- tecnicos_estadisticos %>%
  mutate_if(is.numeric, mean_sd_standard)

summary(tecnicos_st)            

# Determinando numero de clusters (k)
tot_withinss <- map_dbl(1:10, function(k){
  model <- kmeans(x = tecnicos_st[,-1], centers = k)
  model$tot.withinss
})

elbow_df <- data.frame(
  k= 1:10,
  tot_withinss = tot_withinss
)

ggplot(elbow_df, aes(k, tot_withinss)) +
  geom_line()+
  scale_x_continuous(breaks = 1:10)

#OTRA FORMA ELBOW PLOT
#wss <- 0
#for (i in 1:10) {
#  km.out <- kmeans(servicios_st[,-1], centers = i, nstart=20)

  # Save total within sum of squares to wss variable
#  wss[i] <- km.out$tot.withinss
#}

# Plot total within sum of squares vs. number of clusters
#plot(1:10, wss, type = "b", 
#     xlab = "Number of Clusters", 
#     ylab = "Within groups sum of squares")


# Cluster
set.seed(1)

kmeans_tecnicos <-kmeans(tecnicos_st[,-1], centers = 3)

summary(kmeans_tecnicos)
kmeans_tecnicos

#Distribucion de cluster 
table(kmeans_tecnicos$cluster)


#Asignando cluster a tabla original
cluster_tecnicos <- kmeans_tecnicos$cluster
tecnicos_estadisticos <- mutate(tecnicos_estadisticos, cluster = cluster_tecnicos)

# Promedios para cada cluster
k_tecnicos_avg <- tecnicos_estadisticos[-1] %>%
  group_by(cluster) %>%
  summarize_all(list(mean))

k_tecnicos_avg

k_tecnicos_med <- tecnicos_estadisticos[-1] %>%
  group_by(cluster) %>%
  summarize_all(list(median)) %>%
  mutate(cluster = as.character(cluster))

k_tecnicos_med

k_tecnicos_med_promedio <- k_tecnicos_med %>%
  mutate(Promedio = rowMeans(k_tecnicos_med[,3:6]))

k_tecnicos_med_promedio


#PARALLEL COORDINATE PLOT
min_max_standard <- function(x) {
  (x - min(x))/(max(x)- min(x))
}

tecnicos_minmax <- k_tecnicos_med %>%
  mutate_if(is.numeric, min_max_standard)

ggparcoord(tecnicos_minmax, columns = 2:ncol(tecnicos_minmax),
           groupColumn = "cluster", scale = "globalminmax", order = "skewness")


#EDA tecnicos --------------

tecnicos_estadisticos_promedios <- tecnicos_estadisticos %>%
  mutate(promedio = rowMeans(tecnicos_estadisticos[,c(3:6)])) %>%
  arrange(cluster)

top_tecnicos <- tecnicos_estadisticos_promedios %>%
  group_by(cluster) %>%
  select("Tecnico", "promedio") %>%
  slice_min(order_by = promedio, n = 10)


#histograma de cada cluster
ggplot(tecnicos_estadisticos, aes(MediaSitio))+
  geom_histogram()+
  facet_wrap(~cluster)

ggplot(servicios_tecnicos, aes(1, PromedioSitio))+
  geom_boxplot()+
  facet_wrap(~cluster)

#Desnity plots sobre puestos
ggplot(tecnicos_estadisticos, aes(PromedioSitio, fill = cluster)) +
  geom_density(alpha=0.3)

servicios_tecnicos %>%
  filter(cluster == 1) %>%
  ggplot()


#CLUSTER ESTADOS -------------------------------------------
#Creando estadisticos por tecnico
estados_estadisticos <- servicios %>%
  group_by(Estado) %>%
  summarize(MedianaVisitas = median(Visitas),
            MedianaSitio = median(TiempoenSitio),
            MedianaSolucionnTotal = median(TST),
            MedianaSolucionPits = median(TSP),
            MedianaRespuesta = median(RespuestaTecnico))

summary(estados_estadisticos)

#estandarizando
mean_sd_standard <- function (x) {
  (x- mean(x)) / sd(x)
}

estados_st <- estados_estadisticos %>%
  mutate_if(is.numeric, mean_sd_standard)

summary(estados_st)            

# Determinando numero de clusters (k)
tot_withinss <- map_dbl(1:10, function(k){
  model <- kmeans(x = estados_st[,-1], centers = k)
  model$tot.withinss
})

elbow_df <- data.frame(
  k= 1:10,
  tot_withinss = tot_withinss
)

ggplot(elbow_df, aes(k, tot_withinss)) +
  geom_line()+
  scale_x_continuous(breaks = 1:10)

#OTRA FORMA ELBOW PLOT
#wss <- 0
#for (i in 1:10) {
#  km.out <- kmeans(servicios_st[,-1], centers = i, nstart=20)

# Save total within sum of squares to wss variable
#  wss[i] <- km.out$tot.withinss
#}

# Plot total within sum of squares vs. number of clusters
#plot(1:10, wss, type = "b", 
#     xlab = "Number of Clusters", 
#     ylab = "Within groups sum of squares")


# Cluster
set.seed(2)

kmeans_estados <-kmeans(estados_st[,-1], centers = 3)

summary(kmeans_estados)
kmeans_estados


#Distribucion de cluster 
table(kmeans_estados$cluster)


#Asignando cluster a tabla original
cluster_estados <- kmeans_estados$cluster
estados_estadisticos <- mutate(estados_estadisticos, cluster = cluster_estados)

# Promedios para cada cluster
k_estados_avg <- estados_estadisticos[-1] %>%
  group_by(cluster) %>%
  summarize_all(list(mean))

k_estados_avg

k_estados_med <- estados_estadisticos[-1] %>%
  group_by(cluster) %>%
  summarize_all(list(median)) %>%
  mutate(cluster = as.character(cluster))

k_estados_med

k_estados_med_promedio <- k_estados_med %>%
  mutate(Promedio = rowMeans(k_estados_med[,3:6]))

k_estados_med_promedio


#PARALLEL COORDINATE PLOT
min_max_standard <- function(x) {
  (x - min(x))/(max(x)- min(x))
}

estados_minmax <- k_estados_med %>%
  mutate_if(is.numeric, min_max_standard)

ggparcoord(estados_minmax, columns = 2:ncol(estados_minmax),
           groupColumn = "cluster", scale = "globalminmax", order = "skewness")

#EDA estados ----------

estados_estadisticos_promedios <- estados_estadisticos %>%
  mutate(promedio = rowMeans(estados_estadisticos[,c(3:6)])) %>%
  arrange(cluster)

top_estados <- estados_estadisticos_promedios %>%
  group_by(cluster) %>%
  select("Estado", "promedio") %>%
  slice_min(order_by = promedio, n = 10)

top_estados

# CLUSTER TIPO SERVICIO-----------------------------

#Creando estadisticos por tecnico
servicios_estadisticos <- servicios %>%
  group_by(Servicio) %>%
  summarize(MedianaVisitas = median(Visitas),
            MedianaSitio = median(TiempoenSitio),
            MedianaSolucionnTotal = median(TST),
            MedianaSolucionPits = median(TSP),
            MedianaRespuesta = median(RespuestaTecnico))

summary(tecnicos_estadisticos)

servicios_estadisticos_promedios <- servicios_estadisticos %>%
  mutate(promedio = rowMeans(servicios_estadisticos[,c(3:6)]))

servicios_estadisticos_promedios
#EDA servicio------------------

# CLUSTER MODELO-----------------------------

#Creando estadisticos por tecnico
modelo_estadisticos <- servicios %>%
  group_by(Modelo) %>%
  summarize(MedianaVisitas = median(Visitas),
            MedianaSitio = median(TiempoenSitio),
            MedianaSolucionnTotal = median(TST),
            MedianaSolucionPits = median(TSP),
            MedianaRespuesta = median(RespuestaTecnico))

summary(tecnicos_estadisticos)

#estandarizando
mean_sd_standard <- function (x) {
  (x- mean(x)) / sd(x)
}

modelo_st <- modelo_estadisticos %>%
  mutate_if(is.numeric, mean_sd_standard)

summary(modelo_st)            

# Determinando numero de clusters (k)
tot_withinss <- map_dbl(1:10, function(k){
  model <- kmeans(x = modelo_st[,-1], centers = k)
  model$tot.withinss
})

elbow_df <- data.frame(
  k= 1:10,
  tot_withinss = tot_withinss
)

ggplot(elbow_df, aes(k, tot_withinss)) +
  geom_line()+
  scale_x_continuous(breaks = 1:10)

#OTRA FORMA ELBOW PLOT
#wss <- 0
#for (i in 1:10) {
#  km.out <- kmeans(servicios_st[,-1], centers = i, nstart=20)

# Save total within sum of squares to wss variable
#  wss[i] <- km.out$tot.withinss
#}

# Plot total within sum of squares vs. number of clusters
#plot(1:10, wss, type = "b", 
#     xlab = "Number of Clusters", 
#     ylab = "Within groups sum of squares")


# Cluster
set.seed(3)

kmeans_modelo <-kmeans(modelo_st[,-1], centers = 3)

summary(kmeans_modelo)
kmeans_modelo

#Distribucion de cluster 
table(kmeans_modelo$cluster)


#Asignando cluster a tabla original
cluster_modelo <- kmeans_modelo$cluster
modelo_estadisticos <- mutate(modelo_estadisticos, cluster = cluster_modelo)

# Promedios para cada cluster
k_modelo_avg <- modelo_estadisticos[-1] %>%
  group_by(cluster) %>%
  summarize_all(list(mean))

k_modelo_avg

k_modelo_med <- modelo_estadisticos[-1] %>%
  group_by(cluster) %>%
  summarize_all(list(median)) %>%
  mutate(cluster = as.character(cluster))

k_modelo_med

k_modelo_med_promedio <- k_modelo_med %>%
  mutate(Promedio = rowMeans(k_modelo_med[,3:6]))

k_modelo_med_promedio



#PARALLEL COORDINATE PLOT
min_max_standard <- function(x) {
  (x - min(x))/(max(x)- min(x))
}

modelo_minmax <- k_modelo_med %>%
  mutate_if(is.numeric, min_max_standard)

ggparcoord(modelo_minmax, columns = 2:ncol(modelo_minmax),
           groupColumn = "cluster", scale = "globalminmax", order = "skewness")


#EDA modelo ------------

modelo_estadisticos_promedios <- modelo_estadisticos %>%
  mutate(promedio = rowMeans(modelo_estadisticos[,c(3:6)])) %>%
  arrange(cluster)

top_modelo <- modelo_estadisticos_promedios %>%
  group_by(cluster) %>%
  select("Modelo", "promedio") %>%
  slice_min(order_by = promedio, n = 10)

top_modelo

#EDA GENERAL -------------------------
