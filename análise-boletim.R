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

## Modelo de importação do arquivo

## Verificando o encoding do arquivo .dat
## file -I logd.dat
## logd.dat: text/plain; charset=iso-8859-1

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

boletim_salto_sp <- subset(boletim, CD_MUNICIPIO == 70050)
boletim_salto_sp

## Gerando a seed de identificação
boletim_salto_sp$SEED_IDENTIFICACAO <- paste(
  boletim_salto_sp$CD_MUNICIPIO,
  boletim_salto_sp$NR_ZONA_NORM,
  boletim_salto_sp$NR_LOCAL_VOTACAO,
  boletim_salto_sp$NR_SECAO_NORM,
  sep = "-"
)

boletim_salto_sp

## Gerando a hash de identificação da urna no boletim
boletim_salto_sp$HASH_IDENTIFICACAO <- sapply(boletim_salto_sp$SEED_IDENTIFICACAO, digest, algo="md5")
boletim_salto_sp

## Verificando a sessão 0004 de Salto
View(subset(boletim_salto_sp, HASH_IDENTIFICACAO == "96316cbb4150ba996f2bab85c46d537c"))

## Gerando um dataset com a sumarização de votos


View(boletim)

View(logs[])



