pacotes <- c("plotly", 
             "tidyverse",
             "ggrepel", 
             "digest",
             "foreach")

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
logs$sessao_eleitoral <- ""

names(logs) <- c("datetime", "log_level", "id_urna", "cod", "log", "log_id", "modelo_urna", "municipio", "zona_eleitoral", "local_votacao", "sessao_eleitoral")

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
  tmp$sessao_eleitoral <- str_trim(
    str_remove(grep(str_find_pattern, tmp$log,  value = TRUE)[1],str_find_pattern), 
    side = c("both", "left", "right")
  )
  
  logs <- rbind(logs, tmp)
  
}

View(logs)

# Tabela de Frequencias Inicial
table(logs$modelo_urna)
table(logs$zona_eleitoral)
table(logs$sessao_eleitoral)
table(logs$local_votacao)

## Gerando uma seed para vincular ao Boletim das Urnas 
## Gerado com as informações que tem lá para cruzamento dos dados

logs$boletim_seed <- paste(
  logs$municipio,
  logs$zona_eleitoral,
  logs$local_votacao,
  logs$sessao_eleitoral,
  sep = "-")

table(logs$id_urna)
table(logs$boletim_seed)

## Gerando um hash de identificação
logs$hash_identificacao_boletim <- sapply(logs$boletim_seed, digest, algo="md5")

table(logs$hash_identificacao_boletim)

## Gerando uma seed para vincular a auditoria das urnas
logs$urna_seed <- paste(
  logs$municipio,
  logs$zona_eleitoral,
  logs$local_votacao,
  logs$sessao_eleitoral,
  logs$modelo_urna,
  logs$id_urna, 
  sep = "-")

logs$hash_identificao_urna <- sapply(logs$urna_seed, digest, algo="md5")

logs$urna_seed
logs$hash_identificacao_boletim

## Tabela de frequencias
table(logs$urna_seed)
table(logs$hash_identificao_urna)

## Prova real dos hashes de identificao vs id da urna repetido nos modelos > 2020

### Codigo das urnas apontado como erro
codigo_urna_analise <- 67305985
urnas_analise <- subset(logs, id_urna == codigo_urna_analise)

View(urnas_analise)

### Tabela de frequencias id_urna
table(urnas_analise$id_urna)
summary(urnas_analise$id_urna)

### Tabela de frequencia dos hashes
table(urnas_analise$hash_identificao_urna)

### Conseguimos ter uma identificação de cada urna :)


###### Vinculo com o boletim

boletim <- read.csv("bweb_2t_SP_311020221535/bweb_2t_SP_311020221535.csv", 
                    sep = ";", 
                    dec = ".", 
                    fileEncoding="iso-8859-1"
)

boletim
View(boletim)

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

## Verificando a sessão 0004 de Salto

logs_sessao_004 <- subset(logs, sessao_eleitoral == "0004")
View(subset(boletim_salto_sp, HASH_IDENTIFICACAO == logs_sessao_004$hash_identificacao_boletim[1]))

## Verificando a sessão 0001 de Salto
logs_sessao_001 <- subset(logs, sessao_eleitoral == "0001")
View(subset(boletim_salto_sp, HASH_IDENTIFICACAO == logs_sessao_001$hash_identificacao_boletim[1]))

## Verificando a sessão 0001 de Salto
logs_sessao_028 <- subset(logs, sessao_eleitoral == "0028")
View(subset(boletim_salto_sp, HASH_IDENTIFICACAO == logs_sessao_028$hash_identificacao_boletim[1]))

for (row in 1:nrow(boletim_salto_sp)) {
  print(boletim_salto_sp[b, "HASH_IDENTIFICACAO"])
}

