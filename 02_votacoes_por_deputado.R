library(httr)
library(jsonlite)
library(dplyr)
library(writexl)
library(furrr)
library(progressr)

# Configurando paralelização com o número máximo de núcleos disponíveis
plan(multisession, workers = parallel::detectCores() - 1)

# URL Base da API
BASE_URL <- "https://dadosabertos.camara.leg.br/api/v2"

# Definição do range de anos
ANOS_ANALISE <- 2025  # Pode ser substituído por um range como 2009:2025

# Função para buscar a lista de deputados com tratamento de erro
get_deputados <- function() {
  message("Buscando a lista de deputados...")
  url <- paste0(BASE_URL, "/deputados")
  response <- tryCatch(
    GET(url),
    error = function(e) {
      message("Erro ao acessar API de deputados: ", e)
      return(NULL)
    }
  )
  
  if (!is.null(response) && status_code(response) == 200) {
    deputados <- fromJSON(content(response, "text", encoding = "UTF-8"))$dados
    message("Obtidos ", nrow(deputados), " deputados da API.")
    return(deputados)
  }
  message("Erro ao obter lista de deputados.")
  return(data.frame())
}

# Função para buscar todas as votações de um deputado
get_votacoes_por_deputado <- function(deputado_id, anos = ANOS_ANALISE) {
  message("Buscando votações do deputado ", deputado_id, "...")
  votacoes <- list()
  
  fetch_votacoes <- function(ano, pagina = 1) {
    url <- paste0(BASE_URL, "/votacoes?dataInicio=", ano, "-01-01&dataFim=", ano, "-12-31&itens=100&ordem=DESC&ordenarPor=data&pagina=", pagina)
    
    response <- tryCatch(
      GET(url),
      error = function(e) {
        message("Erro ao buscar votações para o ano ", ano, " página ", pagina, ": ", e)
        return(NULL)
      }
    )
    
    if (!is.null(response) && status_code(response) == 200) {
      dados <- fromJSON(content(response, "text", encoding = "UTF-8"))$dados
      if (length(dados) > 0) {
        dados <- as.data.frame(dados)
        return(dados)
      }
    }
    return(NULL)
  }
  
  for (ano in anos) {
    pagina <- 1
    repeat {
      dados_pagina <- fetch_votacoes(ano, pagina)
      if (is.null(dados_pagina) || nrow(dados_pagina) == 0) break
      votacoes <- append(votacoes, list(dados_pagina))
      pagina <- pagina + 1
    }
  }
  
  votacoes <- bind_rows(votacoes)
  return(votacoes)
}

# Obtendo a lista de deputados
deputados <- get_deputados()

if (nrow(deputados) > 0) {
  message("Iniciando coleta de votações para todos os deputados...")
  
  handlers(global = TRUE)
  with_progress({
    pb <- progressor(along = deputados$id)
    
    votacoes_list <- future_map(deputados$id, function(deputado_id) {
      pb()
      return(get_votacoes_por_deputado(deputado_id))
    }, .progress = TRUE)
  })
  
  votacoes_df <- bind_rows(votacoes_list)
  
  # Salvando os dados no Excel
  write_xlsx(
    list(
      "Deputados" = deputados,
      "Votacoes" = votacoes_df
    ),
    path = "deputados_votacoes.xlsx"
  )
  
  message("Arquivo 'deputados_votacoes.xlsx' salvo com sucesso!")
} else {
  message("Erro ao obter a lista de deputados.")
}
