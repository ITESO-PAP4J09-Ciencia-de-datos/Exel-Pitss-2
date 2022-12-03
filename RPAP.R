library(tidyverse)

servicios_rpap <- read_csv("servicios.csv")

glimpse(servicios_rpap)


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

glimpse(servicios)

#EDA-----------------------------------

# vector de conteo

v_tecnicos_rpap <- servicios %>%
  count(Tecnico) %>%
  pull(n)


v_estados_rpap <- servicios %>%
  count(Estado) %>%
  pull(n)

v_servicio_rpap <- servicios %>%
  count(Servicio) %>%
  pull(n)

v_modelo_rpap <- servicios %>%
  count(Modelo) %>%
  pull(n)


fecha <- servicios %>%
  count(Fecha) 

#Estadisticos

Medianas_rpap <- servicios %>%
  summarize(MedianaVisitas = median(Visitas),
            MedianaSitio = median(TiempoenSitio),
            MedianaSolucionTotal = median (TST),
            MedianaSolucionPits = median (TSP),
            MedianaRespuesta = median(RespuestaTecnico))



tecnicos_rpap <- servicios %>%
  group_by(Tecnico) %>%
  summarize(MedianaVisitas = median(Visitas),
            MedianaSitio = median(TiempoenSitio),
            MedianaSolucionTotal = median (TST),
            MedianaSolucionPits = median (TSP),
            MedianaRespuesta = median(RespuestaTecnico))
tecnicos_rpap <- tecnicos_rpap %>%
  mutate(Conteo = v_tecnicos_rpap) %>%
  arrange(desc(Conteo))


estados_rpap <- servicios %>%
  group_by(Estado) %>%
  summarize(MedianaVisitas = median(Visitas),
            MedianaSitio = median(TiempoenSitio),
            MedianaSolucionTotal = median (TST),
            MedianaSolucionPits = median (TSP),
            MedianaRespuesta = median(RespuestaTecnico))
estados_rpap <- estados_rpap %>%
  mutate(Conteo = v_estados_rpap) %>%
  arrange(desc(Conteo))

servicio_rpap <- servicios %>%
  group_by(Servicio) %>%
  summarize(MedianaVisitas = median(Visitas),
            MedianaSitio = median(TiempoenSitio),
            MedianaSolucionTotal = median (TST),
            MedianaSolucionPits = median (TSP),
            MedianaRespuesta = median(RespuestaTecnico))
servicio_rpap <- servicio_rpap %>%
  mutate(Conteo = v_servicio_rpap) %>%
  arrange(desc(Conteo))

modelo_rpap <- servicios %>%
  group_by(Modelo) %>%
  summarize(MedianaVisitas = median(Visitas),
            MedianaSitio = median(TiempoenSitio),
            MedianaSolucionTotal = median (TST),
            MedianaSolucionPits = median (TSP),
            MedianaRespuesta = median(RespuestaTecnico))
modelo_rpap <- modelo_rpap %>%
  mutate(Conteo = v_modelo_rpap) %>%
  arrange(desc(Conteo))


#VARIABLES CATEGORICAS (TECNICOS, ESTADO, SERVICIO, MODELO)

#Grafica de barras de conteo  (cambiar aes())
servicios %>%
  ggplot(aes(Estado)) +
  geom_bar() +
  coord_flip()+
  arrange()

#Grafica de barras dividido en tipo de servicio (cambiar aes())
servicios %>%
  ggplot(aes(Modelo)) +
  geom_bar() +
  coord_flip() +
  facet_wrap(~Servicio)

#VARIABLES NUMERICAS (VISITAS, TIEMPO EN SITIO, TST, TSP, TIEMPO DE RESPUESTA)

#Estadisticos SPREAD
spread_rpap <- servicios %>%
  summarize(sdVisitas = sd(Visitas),
            sdSitio = sd(TiempoenSitio),
            sdSolucionTotal = sd(TST),
            sdSolucionPits = sd(TSP),
            sdRespuesta = sd(RespuestaTecnico))

servicios %>%
  ggplot(aes(RespuestaTecnico)) +
  geom_histogram(binwidth = 5)

servicios %>%
  ggplot(aes(RespuestaTecnico)) +
  geom_histogram() +
  facet_wrap(~ Servicio)


#Tecnicos-------------

#Fill Servicio

servicios_tec %>%
  ggplot(aes(Tecnico)) +
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

servicios_k %>%
  ggplot(aes(Servicio)) +
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
  ggplot(aes(Servicio, fill = Modelo)) +
  geom_bar() +
  coord_flip() +
  facet_wrap(~ cluster, scales = "free") +
  theme(legend.position = "top")

#Estados --------------

#Fill top 5 Tecnicos
servicios_est %>%
  ggplot(aes(Estado)) +
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
  ggplot(aes(Modelo)) +
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


