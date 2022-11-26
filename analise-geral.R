pacotes <- c("plotly", 
             "tidyverse",
             "ggrepel", 
             "digest",
             "foreach",
             "ggplot2")

if(sum(as.numeric(!pacotes %in% installed.packages())) != 0){
  instalador <- pacotes[!pacotes %in% installed.packages()]
  for(i in 1:length(instalador)) {
    install.packages(instalador, dependencies = T)
    break()}
  sapply(pacotes, require, character = T) 
} else {
  sapply(pacotes, require, character = T) 
}

datasets_logs <- c(
  "logd-00407-0001.dat",
  "logd-00407-0002.dat",
  "logd-00407-0003.dat",
  "logd-00407-0004.dat", 
  "logd-00407-0005.dat",
  "logd-00407-0006.dat",
  "logd-00407-0007.dat",
  "logd-00407-0008.dat",
  "logd-00407-0009.dat",
  "logd-00407-0010.dat",
  "logd-00407-0011.dat",
  "logd-00407-0012.dat",
  "logd-00407-0013.dat",
  "logd-00407-0014.dat",
  "logd-00407-0015.dat",
  "logd-00407-0028.dat",
  "logd-00407-0075.dat",
  "logd-00407-0122.dat",
  "logd-00407-0147.dat",
  "logd-00407-0253.dat"
)

## Abrindo o arquivo inicial para efetuar análise 
logs <- read.table(datasets_logs[1], 
                   header=FALSE, 
                   skip=0, 
                   sep="\t", 
                   nrows = 100,
                   fileEncoding="iso-8859-1"
)

View(logs)

initial_table <- table(logs$v3)
initial_table


# Criando um Dummy Dataframe para iniciar o merge dos datasets
logs <- read.table(datasets_logs[1], 
                   header=FALSE, 
                   skip=0, 
                   sep="\t", 
                   nrows = 1,
                   fileEncoding="iso-8859-1"
)


logs$modelo_urna <- ""
logs$municipio <- ""
logs$zona_eleitoral <- ""
logs$local_votacao <- ""
logs$secao_eleitoral <- ""

names(logs) <- c("datetime", "log_level", "id_urna", "cod", "log", "log_id", "modelo_urna", "municipio", "zona_eleitoral", "local_votacao", "secao_eleitoral")

logs <- logs[0,]
logs


## Fazendo o merge de todos os datasets
for (d in datasets_logs) {
  tmp <- read.table(d, 
                    header=FALSE, 
                    skip=0, 
                    sep="\t", 
                    fileEncoding="iso-8859-1"
  )
  names(tmp) <- c("datetime", "log_level", "id_urna", "cod", "log", "log_id")
  
  ## Enriquecimento inicial - Numero do modelo da urna
  str_find_pattern <- "Identificação do Modelo de Urna: "
  tmp$modelo_urna <- str_remove(grep(str_find_pattern, tmp$log,  value = TRUE)[1],str_find_pattern)
  
  ## Enriquecimento inicial - Municipio
  str_find_pattern <- "Município: "
  tmp$municipio <- str_remove(grep(str_find_pattern, tmp$log,  value = TRUE)[1],str_find_pattern)
  
  ## Enriquecimento inicial - Zona Eleitoral
  str_find_pattern <- "Zona Eleitoral: "
  tmp$zona_eleitoral <- str_remove(grep(str_find_pattern, tmp$log,  value = TRUE)[1],str_find_pattern)
  
  ## Enriquecimento inicial - Local de Votação
  str_find_pattern <- "Local de Votação: "
  tmp$local_votacao <- str_remove(grep(str_find_pattern, tmp$log,  value = TRUE)[1],str_find_pattern)
  
  ## Enriquecimento inicial - Sessão Eleitoral
  str_find_pattern <- "Seção Eleitoral:"
  tmp$secao_eleitoral <- str_trim(
    str_remove(grep(str_find_pattern, tmp$log,  value = TRUE)[1],str_find_pattern), 
    side = c("both", "left", "right")
  )
  
  logs <- rbind(logs, tmp)
  
}

View(logs)

# Tabela de Frequencias Inicial
table(logs$modelo_urna)
table(logs$zona_eleitoral)
table(logs$secao_eleitoral)
table(logs$municipio)
table(logs$local_votacao)
table(logs$id_urna)



# Análise Visual Logs da Seção Eleitoral

ini_secao_eleitoral_freq <- as.data.frame(table(logs$secao_eleitoral))

ggplot(ini_secao_eleitoral_freq, aes(x=Var1, y=Freq)) + 
  geom_bar(stat='identity', aes(fill=Var1)) +
  ggtitle("Quantidade de Logs por Seção Eleitoral - Zona 0221 Municipio 70050") +
  labs(x = "Seção Eleitoral", y = "Logs", fill = "Seção") +
  geom_text(aes(label=Freq)) +
  scale_color_discrete("Seção:")  


# Análise Visual Logs dos Modelo de Urna

ini_modelo_freq <- as.data.frame(table(logs$modelo_urna))

ggplot(ini_modelo_freq, aes(x=Var1, y=Freq)) + 
  geom_bar(stat='identity', aes(fill=Var1)) +
  ggtitle("Quantidade de Logs por Modelo de Urna - Zona 0221 Municipio 70050") +
  labs(x = "Modelo", y = "Logs", fill = "Modelo") +
  geom_text(aes(label=Freq)) +
  scale_color_discrete("Modelos:")  

# Análise Visual - Quantidade de Urnas de Diferentes Modelos da Amostra

unique_modelos <- logs %>% distinct(secao_eleitoral, zona_eleitoral, modelo_urna)
unique_modelos <- as.data.frame(unique_modelos)
unique_modelos

unique_modelos_freq <- table(unique_modelos$modelo_urna)
unique_modelos_freq <- as.data.frame(unique_modelos_freq)
unique_modelos_freq

ggplot(unique_modelos_freq, aes(x=Var1, y=Freq)) + 
  geom_bar(stat='identity', aes(fill=Var1)) +
  ggtitle("Quantidade de Modelos de Urna da Amostra - Municipio 70050") +
  labs(x = "Modelo", y = "Logs", fill = "Modelo") +
  geom_text(aes(label=Freq)) +
  scale_color_discrete("Modelos:") 

unique_modelos_freq$percent = round(
  100 * unique_modelos_freq$Freq / sum(unique_modelos_freq$Freq),
  digits = 0
)

ggplot(unique_modelos_freq, aes(x="", y=Freq, fill=Var1)) + 
  geom_bar(stat="identity", width=1) +
  coord_polar("y", start=0) +
  geom_text(aes(label = Freq), position = position_stack(vjust = 0.5)) +
  labs(x = NULL, y = NULL, fill = NULL, title = "Quantidade de Modelos de Urna da Amostra - Municipio 70050") + 
  theme_classic() + theme(axis.line = element_blank(),
                          axis.text = element_blank(),
                          axis.ticks = element_blank(),
                          plot.title = element_text(hjust = 0.5, color = "#666666"))

# Análise Visual da tabela de frequencia dos id_urna 

freq_table_id_urna <- table(logs$id_urna)
freq_table_id_urna <- as.data.frame(freq_table_id_urna)
names(freq_table_id_urna) <- c("id_urna", "frequencia")
freq_table_id_urna

ggplot(freq_table_id_urna, aes(x=id_urna, y=frequencia)) + 
  geom_bar(stat='identity', aes(fill=id_urna)) +
  ggtitle("Quantidade de Logs por Urna Eletrônica") +
  labs(x = "Identificador Urna", y = "Logs", fill = "ID's de Urna:") +
  geom_text(aes(label=frequencia)) +
  scale_color_discrete("ID's:")  


freq_table_modelo <- table(logs$modelo_urna)
freq_table_modelo <- as.data.frame(freq_table_modelo)
names(freq_table_modelo) <- c("modelo_urna", "frequencia")
freq_table_modelo

ggplot(freq_table_modelo, aes(x=modelo_urna, y=frequencia)) + 
  geom_bar(stat='identity', aes(fill=modelo_urna)) +
  ggtitle("Quantidade de Logs por Urna Eletrônica") +
  labs(x = "Modelo Urna", y = "Logs", fill = "Modelos de Urna:") +
  geom_text(aes(label=frequencia)) +
  scale_color_discrete("Modelos:")  

## Gerando uma seed para vincular a auditoria das urnas
logs$urna_seed <- paste(
  logs$municipio,
  logs$zona_eleitoral,
  logs$local_votacao,
  logs$secao_eleitoral,
  logs$modelo_urna,
  logs$id_urna, 
  sep = "-")

logs$hash_urna <- sapply(logs$urna_seed, digest, algo="md5")

sort(table(logs$urna_seed))
sort(table(logs$hash_urna))


## Tabela de frequencias id_urna
freq_table_id <- sort(table(logs$id_urna))
freq_table_id <- as.data.frame(freq_table_id)
names(freq_table_id) <- c("id_urna", "frequencia")
freq_table_id

ggplot(freq_table_id, aes(y=id_urna, x=frequencia)) + 
  geom_bar(stat='identity', aes(fill=id_urna)) +
  ggtitle("Quantidade de Logs por Urna Eletrônica") +
  labs(x = "Quantidade de Logs", y = "Identificador id_urna", fill = "ID de Urna:") +
  geom_text(aes(label=frequencia)) +
  scale_color_discrete("Modelos:")  


## Tabela de frequencias hash_urna
freq_table_hash <- sort(table(logs$hash_urna))
freq_table_hash <- as.data.frame(freq_table_hash)
names(freq_table_hash) <- c("identificado_urna", "frequencia")
freq_table_hash

ggplot(freq_table_hash, aes(y=identificado_urna, x=frequencia)) + 
  geom_bar(stat='identity', aes(fill=identificado_urna)) +
  ggtitle("Quantidade de Logs por Urna Eletrônica") +
  labs(x = "Quantidade de Logs", y = "Identificador Hash Urna", fill = "Hash-id de Urna:") +
  geom_text(aes(label=frequencia)) +
  scale_color_discrete("Modelos:")  

sum(freq_table_hash$frequencia)

## "Me diga qual urna estava na seção X do local Y da zona Z"

urna_x <- subset(logs, secao_eleitoral == "0001" | local_votacao == "1015" | zona_eleitoral == "0221")
urna_x_view <- urna_x %>% select(hash_urna,datetime, modelo_urna, municipio, zona_eleitoral, secao_eleitoral)

View(head(urna_x_view, 1))

## "Me dê somente os logs da urna hash_id:1a2097e964d5e77e355e30744484aa2c"

urna_x <- subset(logs, hash_urna == "1a2097e964d5e77e355e30744484aa2c")
urna_x_view <- urna_x %>% select(hash_urna,datetime, modelo_urna, municipio, zona_eleitoral, secao_eleitoral,  log)

View(urna_x_view)

## Prova real dos hashes de identificao vs id da urna repetido nos modelos > 2020

### Codigo das urnas apontado como erro
codigo_urna_analise <- 67305985
urnas_analise <- subset(logs, id_urna == codigo_urna_analise)

### Tabela de frequencias id_urna
table(urnas_analise$id_urna)
summary(urnas_analise$id_urna)

### Tabela de frequencia do id_urna dos modelos antigos
freq_table_urnas_analise <- table(urnas_analise$id_urna)
freq_table_urnas_analise <- as.data.frame(freq_table_urnas_analise)
names(freq_table_urnas_analise) <- c("id_urna", "frequencia")
freq_table_urnas_analise

ggplot(freq_table_urnas_analise, aes(y=id_urna, x=frequencia)) + 
  geom_bar(stat='identity', aes(fill=id_urna)) +
  ggtitle("Quantidade de Logs por ID Urna - 67305985") +
  labs(x = "Quantidade de Logs", y = "ID Urna", fill = "ID Urna:") +
  geom_text(aes(label=frequencia)) +
  scale_color_discrete("ID:")  


### Tabela de frequencia do hash_urna dos modelos antigos
freq_table_urnas_analise <- table(urnas_analise$hash_urna)
freq_table_urnas_analise <- as.data.frame(freq_table_urnas_analise)
names(freq_table_urnas_analise) <- c("hash_urna", "frequencia")
freq_table_urnas_analise

ggplot(freq_table_urnas_analise, aes(y=hash_urna, x=frequencia)) + 
  geom_bar(stat='identity', aes(fill=hash_urna)) +
  ggtitle("Quantidade de Logs por Hash da Urna - 67305985") +
  labs(x = "Quantidade de Logs", y = "Hash Urna", fill = "Hash Urna:") +
  geom_text(aes(label=frequencia)) +
  scale_color_discrete("Hash:")  

### Conseguimos ter uma identificação de cada urna :)


###### Vinculo com o boletim

boletim <- read.csv("bweb_2t_SP_311020221535/bweb_2t_SP_311020221535.csv", 
                    sep = ";", 
                    dec = ".", 
                    fileEncoding="iso-8859-1"
)

colnames(boletim)

# Normalizando o NR_ZONA com padding de 4 zeros
boletim$NR_ZONA_NORM <- sprintf("%04d",boletim$NR_ZONA)

# Normalizando o NR_SECAO com padding de 4 zeros
boletim$NR_SECAO_NORM <- sprintf("%04d",boletim$NR_SECAO)

colnames(boletim)


# O Boletim sai por estado. Fizemos a análise somente com Salto, 
# Vamos criar um dataframe somente com o código municipio da cidade 

boletim_salto_sp <- subset(boletim, CD_MUNICIPIO == 70050)
boletim_salto_sp

## Gerando uma seed para vincular ao Boletim das Urnas 
## Gerado com as informações que tem lá para cruzamento dos dados

logs$boletim_seed <- paste(
  logs$municipio,
  logs$zona_eleitoral,
  logs$local_votacao,
  logs$secao_eleitoral,
  sep = "-")


## Gerando um hash de identificação do Boletim
logs$hash_identificacao_boletim <- sapply(logs$boletim_seed, digest, algo="md5")

table(logs$id_urna)
sort(table(logs$boletim_seed))
sort(table(logs$hash_identificacao_boletim))

table(logs$hash_identificacao_boletim)

## Gerando a seed de identificação com as mesmas informações que temos no log
## das urnas para fazer o merge

boletim_salto_sp$SEED_IDENTIFICACAO <- paste(
  boletim_salto_sp$CD_MUNICIPIO,
  boletim_salto_sp$NR_ZONA_NORM,
  boletim_salto_sp$NR_LOCAL_VOTACAO,
  boletim_salto_sp$NR_SECAO_NORM,
  sep = "-"
)

## Gerando a hash de identificação da urna no boletim
boletim_salto_sp$HASH_IDENTIFICACAO <- sapply(boletim_salto_sp$SEED_IDENTIFICACAO, digest, algo="md5")
boletim_salto_sp

View(boletim_salto_sp)

## Verificando a sessão 0004 de Salto

logs_secao_004 <- subset(logs, secao_eleitoral == "0004")
View(subset(boletim_salto_sp, HASH_IDENTIFICACAO == logs_secao_004$hash_identificacao_boletim[1]))

## Verificando a sessão 0001 de Salto
logs_secao_001 <- subset(logs, secao_eleitoral == "0001")
View(subset(boletim_salto_sp, HASH_IDENTIFICACAO == logs_secao_001$hash_identificacao_boletim[1]))

## Verificando a sessão 0001 de Salto
logs_secao_028 <- subset(logs, secao_eleitoral == "0028")
View(subset(boletim_salto_sp, HASH_IDENTIFICACAO == logs_secao_028$hash_identificacao_boletim[1]))

# Separando os hashes unicos pra melhorar a performance do update do dataset
unique_hashes <- logs %>% distinct(hash_identificacao_boletim, hash_urna, hash_urna, modelo_urna)
unique_hashes <- as.data.frame(unique_hashes)
unique_hashes

# Adicionando as informações da urna no boletim com base no HASH_IDENTIFICAO

# Adiciona o HASH_URNA e MODELO URNA
for (i in 1:nrow(unique_hashes)) {
  h <- unique_hashes[i, "hash_identificacao_boletim"]
  boletim_salto_sp$HASH_URNA[boletim_salto_sp$HASH_IDENTIFICACAO == h] <- unique_hashes[i, "hash_urna"]
  boletim_salto_sp$MODELO_URNA[boletim_salto_sp$HASH_IDENTIFICACAO == h] <- unique_hashes[i, "modelo_urna"] 
}


# Removendo as urnas que não foram incluídas na análise
boletim_salto_sp_amostra <- as.data.frame(boletim_salto_sp[rowSums(is.na(boletim_salto_sp)) == 0,])
table(boletim_salto_sp_amostra$HASH_IDENTIFICACAO)

# Conferindo Numero de Votos entre o Boletim vs Logs 

colnames(boletim_salto_sp_amostra)

boletim_salto_sp_amostra_resumido <- boletim_salto_sp_amostra %>% 
  select(HASH_URNA, MODELO_URNA, DS_ELEICAO, DS_CARGO_PERGUNTA, DS_TIPO_VOTAVEL, NM_VOTAVEL, QT_VOTOS)

View(boletim_salto_sp_amostra_resumido)

## Boletim
View(boletim_salto_sp_amostra)


