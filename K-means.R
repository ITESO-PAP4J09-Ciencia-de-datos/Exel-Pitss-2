library(tidyverse)
library(fpp3)
library(GGally)

options(digits = 3)



 
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




#Seleccion de variables numericas
servicios_pits <- servicios %>%
  select("Visitas", "TiempoenSitio", "TST", "TSP", "RespuestaTecnico")

summary(servicios_pits)

#Estandarizando
servicios_st <- scale(servicios_pits)

summary(servicios_st)

# Determinando numero de clusters (k)
tot_withinss <- map_dbl(1:10, function(k){
  model <- kmeans(x = servicios_st, centers = k)
  model$tot.withinss
})

elbow_df <- data.frame(
  k= 1:10,
  tot_withinss = tot_withinss
)

ggplot(elbow_df, aes(k, tot_withinss)) +
  geom_line()+
  scale_x_continuous(breaks = 1:10)

#Cluster k = x
set.seed(10)

kmeans_pits <- kmeans(servicios_st, centers = 4) 
summary(kmeans_pits)
kmeans_pits

#Distribucion de clusters
table(kmeans_pits$cluster)

#Asignando cluster a tabla original
cluster_pits <- kmeans_pits$cluster
servicios_pits <- mutate(servicios_pits, cluster = cluster_pits)

# Promedios para cada cluster
servicios_pits_avg <- servicios_pits %>%
  group_by(cluster) %>%
  summarize_all(list(mean))

servicios_pits_avg

servicios_pits_med <- servicios_pits %>%
  group_by(cluster) %>%
  summarize_all(list(median)) %>%
  mutate(cluster = as.character(cluster))

servicios_pits_med

#Graficas
ggplot(servicios_pits, aes(TST, TSP, color = factor(cluster)))+
  geom_point()

#PARALLEL COORDINATE PLOT
min_max_standard <- function(x) {
  (x - min(x))/(max(x)- min(x))
}

servicios_st_minmax <- servicios_pits_med %>%
  mutate_if(is.numeric, min_max_standard)

ggparcoord(servicios_st_minmax, columns = 2:ncol(servicios_st_minmax),
           groupColumn = "cluster", scale = "globalminmax", order = "skewness")

#ASIGNANDO CLUSTERS A TABLA ORIGINAL SERVICIOS

servicios_k <- servicios %>%
  mutate(servicios, cluster = cluster_pits)



#EDA ----------------------

servicios_group <- servicios_k %>%
  group_by(cluster)

#BASE DE DATOS -------------

#Top 5 tecnicos----------

tecnicos <- servicios_group %>%
  count(Tecnico)

tec <-  tecnicos %>%
  slice_max(order_by = n, n = 5) %>%
  mutate(id = paste(cluster, Tecnico, sep = "-")) %>%
  pull(id) 

servicios_tec <- servicios_group %>%
  mutate(id = paste(cluster, Tecnico, sep = "-")) %>%
  filter(id %in% tec)

#Top 5 modelos ----------

modelos <- servicios_group %>%
  count(Modelo)

mod <-  modelos %>%
  slice_max(order_by = n, n = 5) %>%
  mutate(id = paste(cluster, Modelo, sep = "-")) %>%
  pull(id)

servicios_mod <- servicios_group %>%
  mutate(id = paste(cluster, Modelo, sep = "-")) %>%
  filter(id %in% mod)

#Top 5 Estados -----------

estados <- servicios_group %>%
  count(Estado)

est <-  estados %>%
  slice_max(order_by = n, n = 5) %>%
  mutate(id = paste(cluster, Estado, sep = "-")) %>%
  pull(id)

servicios_est <- servicios_group %>%
  mutate(id = paste(cluster, Estado, sep = "-")) %>%
  filter(id %in% est)

#GRAFICAS ------------------------

#Vector top 5 modelos
v_modelos <- modelos %>%
  slice_max(order_by = n, n = 5) %>%
  pull(Modelo)

#Vector top 5 tecnicos 
v_tecnicos <- tecnicos %>%
  slice_max(order_by = n, n = 5) %>%
  pull(Tecnico)


#Tecnicos-------------

#Fill Servicio

servicios_tec %>%
  ggplot(aes(Tecnico, fill = Servicio)) +
  geom_bar() +
  coord_flip() +
  facet_wrap(~ cluster, scales = "free") +
  theme(legend.position = "top")

#Fill Estado
servicios_tec %>%
  ggplot(aes(Tecnico, fill = Estado)) +
  geom_bar() +
  coord_flip() +
  facet_wrap(~ cluster, scales = "free") +
  theme(legend.position = "top")

#Fill top 5 modelos
servicios_tec %>%
  filter(Modelo %in% v_modelos) %>%
  ggplot(aes(Tecnico, fill = Modelo)) +
  geom_bar() +
  coord_flip() +
  facet_wrap(~ cluster, scales = "free") +
  theme(legend.position = "top")

#Servicios ----------------

#Fill top 5 Tecnicos

servicios %>%
  filter(Tecnico %in% v_tecnicos) %>%
  ggplot(aes(Servicio, fill = Tecnico)) +
  geom_bar() +
  coord_flip() +
  facet_wrap(~ cluster, scales = "free") +
  theme(legend.position = "top")

#Fill Estados

servicios %>%
  ggplot(aes(Servicio, fill = Estado)) +
  geom_bar() +
  coord_flip() +
  facet_wrap(~ cluster, scales = "free") +
  theme(legend.position = "top")

#Fill top 5 modelos
servicios %>%
  filter(Modelo %in% v_modelos) %>%
  ggplot(aes(Servicio, fill = Modelo)) +
  geom_bar() +
  coord_flip() +
  facet_wrap(~ cluster, scales = "free") +
  theme(legend.position = "top")

#Estados --------------

#Fill top 5 Tecnicos
servicios_est %>%
  filter(Tecnico %in% v_tecnicos) %>%
  ggplot(aes(Estado, fill = Tecnico)) +
  geom_bar() +
  coord_flip() +
  facet_wrap(~ cluster, scales = "free") +
  theme(legend.position = "top")

#Fill Servicio
servicios_est %>%
  ggplot(aes(Estado, fill = Servicio)) +
  geom_bar() +
  coord_flip() +
  facet_wrap(~ cluster, scales = "free") +
  theme(legend.position = "top")

#Fill top 5 modelos
servicios_est %>%
  filter(Modelo %in% v_modelos) %>%
  ggplot(aes(Estado, fill = Modelo)) +
  geom_bar() +
  coord_flip() +
  facet_wrap(~ cluster, scales = "free") +
  theme(legend.position = "top")


#Modelos---------------

#Fill top 5 Tecnicos
servicios_mod %>%
  filter(Tecnico %in% v_tecnicos) %>%
  ggplot(aes(Modelo, fill = Tecnico)) +
  geom_bar() +
  coord_flip() +
  facet_wrap(~ cluster, scales = "free") +
  theme(legend.position = "top")

#Fill Servicios
servicios_mod %>%
  ggplot(aes(Modelo, fill = Servicio)) +
  geom_bar() +
  coord_flip() +
  facet_wrap(~ cluster, scales = "free") +
  theme(legend.position = "top")

#Fill Estados
servicios_mod %>%
  ggplot(aes(Modelo, fill = Estado)) +
  geom_bar() +
  coord_flip() +
  facet_wrap(~ cluster, scales = "free") +
  theme(legend.position = "top")
  

#Cluster 1 --------------
#66448
#                 promedios       mediana
#Visitas          --- 1     --- 1  
#TiempoenSitio    --- 1.02  --- 0.833
#TST              --- 11.6  --- 3.27
#TSP              --- 2.43  --- 2.02
#RespuestaTecnico --- 1.47  --- 0.833

#Tiene el mayor numero de servicios de mantenimiento preventivo (Hector Marin) seguido por mantenimientos correctivos. 
#Todos los tecnicos operan en Jalisco. 
# Modelos principales X464, XM3150 (Hector Marin B405_DN)

#Cluster 2 --------------
#23939
#                 promedios       mediana
#Visitas          --- 2.14  --- 2
#TiempoenSitio    --- 2.61  --- 2.150
#TST              --- 51.1  --- 29.83
#TSP              --- 11.08 --- 6.97
#RespuestaTecnico --- 2.00  --- 1.5

#Mayormente servicios correctivos. Servicio Red externa pits es Tecnico con mayor servicios. 
#La mayoria de los tecnicos operan en Jalisco, excepto Jose Luis Mejia opera en Queretaro. (Servicio Red Externa pits parece operar en toda la republica).
#Servicio Red Externa Pits trabaja con la mayoria de modelos (principal B405_DN)
#Modelos principales D95_CP, C70, X464, XM3150

#Cluster 3 --------------
#2383
#                 promedios       mediana
#Visitas          --- 3.34  --- 3
#TiempoenSitio    --- 6.84  --- 5.2
#TST              --- 277.7 --- 186.97
#TSP              --- 59.91 --- 41.93
#RespuestaTecnico --- 2.63  --- 1.867


#Mayormente servicios correctivos. Servicio Red externa pits es Tecnico con mayor servicios. 
#La mayoria de los tecnicos operan en Jalisco, excepto Jesus Palacios opera en Ciudad/Estado Mexico.. (Servicio Red Externa pits parece operar en toda la republica).
#Servicio Red Externa Pits trabaja con la mayoria de modelos (principal XM3150)
#Modelos Principales x464, XM3150


#Cluster 4 --------------
#853
#                 promedios       mediana
#Visitas          --- 1.26  --- 1
#TiempoenSitio    --- 1.61  --- 1.083
#TST              --- 63.4  --- 29.85
#TSP              --- 32.84  --- 25.90
#RespuestaTecnico --- 27.04  --- 22.317

#Cluster con mayor servicios de tipo servicio a terceros. 
#Es el cluster con mayor numero de estados (principalmente Jalisco, Nuevo Leon, Ciudad de Mexico, Queretaro)
#Modelo principal 432FDN. 
