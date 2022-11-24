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

## Criando um Dummy Dataset vazio
logs <- datasets_logs[1]
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
table(logs$local_votacao)
table(logs$id_urna)

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


## Gerando uma seed para vincular ao Boletim das Urnas 
## Gerado com as informações que tem lá para cruzamento dos dados

logs$boletim_seed <- paste(
  logs$municipio,
  logs$zona_eleitoral,
  logs$local_votacao,
  logs$secao_eleitoral,
  sep = "-")


## Gerando um hash de identificação
logs$hash_identificacao_boletim <- sapply(logs$boletim_seed, digest, algo="md5")

table(logs$id_urna)
sort(table(logs$boletim_seed))
sort(table(logs$hash_identificacao_boletim))

table(logs$hash_identificacao_boletim)

View(logs)

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

logs$urna_seed
logs$hash_identificacao_boletim

View(logs)

## Tabela de frequencias
sort(table(logs$urna_seed))

freq_table_hash <- table(logs$hash_urna)
freq_table_hash <- as.data.frame(freq_table_hash)
names(freq_table_hash) <- c("identificado_urna", "frequencia")
freq_table_hash

ggplot(freq_table_hash, aes(y=identificado_urna, x=frequencia)) + 
  geom_bar(stat='identity', aes(fill=identificado_urna)) +
  ggtitle("Quantidade de Logs por Urna Eletrônica") +
  labs(x = "Quantidade de Logs", y = "Identificador Hash Urna", fill = "Hash de Urna:") +
  geom_text(aes(label=frequencia)) +
  scale_color_discrete("Modelos:")  

## Prova real dos hashes de identificao vs id da urna repetido nos modelos > 2020

### Codigo das urnas apontado como erro
codigo_urna_analise <- 67305985
urnas_analise <- subset(logs, id_urna == codigo_urna_analise)

View(urnas_analise)

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

# Adiciona o HASH_URNA
for (i in 1:nrow(unique_hashes)) {
  h <- unique_hashes[i, "hash_identificacao_boletim"]
  boletim_salto_sp$HASH_URNA[boletim_salto_sp$HASH_IDENTIFICACAO == h] <- unique_hashes[i, "hash_urna"]
}

# Adiciona o Modelo da Urna no Boletim
for (i in 1:nrow(unique_hashes)) {
  h <- unique_hashes[i, "hash_identificacao_boletim"]
  boletim_salto_sp$MODELO_URNA[boletim_salto_sp$HASH_IDENTIFICACAO == h] <- unique_hashes[i, "modelo_urna"]   
}

View(boletim_salto_sp$MODELO_URNA)


