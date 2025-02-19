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

# Função para buscar despesas de um deputado (com paginação e tratamento de erro)
get_deputado_despesas <- function(deputado_id, anos = ANOS_ANALISE) {
  message("Coletando despesas do deputado ", deputado_id, "...")
  meses <- 1:12
  
  fetch_despesas <- function(ano, mes) {
    url <- paste0(BASE_URL, "/deputados/", deputado_id, "/despesas?ano=", ano, "&mes=", mes, "&itens=100&ordem=ASC&ordenarPor=ano")
    
    response <- tryCatch(
      GET(url),
      error = function(e) {
        message("Erro ao buscar despesas do deputado ", deputado_id, " para ", ano, "/", mes, ": ", e)
        return(NULL)
      }
    )
    
    if (!is.null(response) && status_code(response) == 200) {
      dados <- fromJSON(content(response, "text", encoding = "UTF-8"))$dados
      if (length(dados) > 0) {
        dados <- as.data.frame(dados)
        dados$deputado_id <- deputado_id
        message("Obtidas ", nrow(dados), " despesas para o deputado ", deputado_id, " em ", ano, "/", mes)
        return(dados)
      }
    }
    message("Nenhuma despesa encontrada para o deputado ", deputado_id, " em ", ano, "/", mes)
    return(NULL)
  }
  
  despesas <- future_map2(anos, meses, fetch_despesas, .progress = TRUE)
  despesas <- bind_rows(despesas)
  return(despesas)
}

# Obtendo a lista de deputados
deputados <- get_deputados()

if (nrow(deputados) > 0) {
  message("Iniciando coleta de despesas para todos os deputados...")
  
  handlers(global = TRUE)
  with_progress({
    pb <- progressor(along = deputados$id)
    
    despesas_list <- future_map(deputados$id, function(deputado_id) {
      pb()
      return(get_deputado_despesas(deputado_id))
    }, .progress = TRUE)
  })
  
  # Convertendo listas para data.frames
  despesas_df <- bind_rows(despesas_list)
  
  # Salvando os dados no Excel
  write_xlsx(
    list(
      "Deputados" = deputados,
      "Despesas" = despesas_df
    ),
    path = "deputados_despesas.xlsx"
  )
  
  message("Arquivo 'deputados_despesas.xlsx' salvo com sucesso!")
} else {
  message("Erro ao obter a lista de deputados.")
}
