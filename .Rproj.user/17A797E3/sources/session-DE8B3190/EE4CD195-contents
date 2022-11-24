pacotes <- c("plotly", 
             "tidyverse",
             "ggrepel", 
             "digest")

if(sum(as.numeric(!pacotes %in% installed.packages())) != 0){
  instalador <- pacotes[!pacotes %in% installed.packages()]
  for(i in 1:length(instalador)) {
    install.packages(instalador, dependencies = T)
    break()}
  sapply(pacotes, require, character = T) 
} else {
  sapply(pacotes, require, character = T) 
}

## Verificando o encoding do arquivo .dat
## file -I logd.dat
## logd.dat: text/plain; charset=iso-8859-1

## Modelo de importação do arquivo
logs_amostra <- read.table("logd-00407-0008.dat", 
                   header=FALSE, 
                   skip=0, 
                   sep="\t", 
                   fileEncoding="iso-8859-1"
)

## Prova de conceito da geração de Hash de identificação
logs_amostra$V5

view(logs_amostra)

codigo_urna <- logs_amostra$V3[1]
codigo_urna

## Recupernado o pattern de Modelo da Urna
modelo_urna <- grep("Identificação do Modelo de Urna: ",logs_amostra$V5,  value = TRUE)[1]
modelo_urna
modelo_urna <- str_remove(modelo_urna, "Identificação do Modelo de Urna: ")
modelo_urna

## Recupernado o pattern de Local de Sessão de Votação
sessao_eleitoral <- grep("Seção Eleitoral: ",logs_amostra$V5,  value = TRUE)[1]
sessao_eleitoral
sessao_eleitoral <- str_remove(sessao_eleitoral, "Seção Eleitoral: ")
sessao_eleitoral 

## Recupernado o pattern de Municipio
municipio <- grep("Município: ",logs_amostra$V5,  value = TRUE)[1]
municipio
municipio <- str_remove(municipio, "Município: ")
municipio

## Recupernado o pattern de Zona Eleitoral
zona_eleitoral <- grep("Zona Eleitoral: ",logs_amostra$V5,  value = TRUE)[1]
zona_eleitoral
zona_eleitoral <- str_remove(zona_eleitoral, "Zona Eleitoral: ")
zona_eleitoral

## Recupernado o pattern de Local de Votacao
local_votacao <- grep("Local de Votação: ",logs_amostra$V5,  value = TRUE)[1]
local_votacao
local_votacao <- str_remove(local_votacao, "Local de Votação: ")
local_votacao 

## Gerando a seed para o hash do boletim
boletim_seed <- paste(municipio,zona_eleitoral,local_votacao,sessao_eleitoral, sep = "-")
boletim_seed


hash_identificacao_boletim <- sapply(boletim_seed, digest, algo="md5")
hash_identificacao_boletim

## Incluindo a hash no dataset do log
logs$hash_identificacao_boletim <- hash_identificacao_boletim

## Gerando a seed para o hash de identificação da urna para análises globais
urna_seed <- paste(municipio,zona_eleitoral,local_votacao,sessao_eleitoral,modelo_urna,codigo_urna, sep = "-")
urna_seed

hash_identificacao_urna <- sapply(urna_seed, digest, algo="md5")
hash_identificacao_urna

## Incluindo a hash no dataset do log
logs_amostra$hash_identificacao_urna <- hash_identificacao_urna
logs_amostra

## Enriquecendo o log
logs_amostra$municipio <- municipio
logs_amostra$zona_eleitoral <- zona_eleitoral
logs_amostra$local_votacao <- local_votacao
logs_amostra$sessao_eleitoral <- sessao_eleitoral
logs_amostra$modelo_urna <- modelo_urna

View(logs_amostra)

