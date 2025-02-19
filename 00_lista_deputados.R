library(httr)
library(jsonlite)
library(dplyr)
library(writexl)

# URL Base da API
BASE_URL <- "https://dadosabertos.camara.leg.br/api/v2"

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

# Obtendo a lista de deputados
deputados <- get_deputados()

if (nrow(deputados) > 0) {
  # Salvando os dados no Excel
  write_xlsx(
    list("Deputados" = deputados),
    path = "deputados_lista.xlsx"
  )
  
  message("Arquivo 'deputados_lista.xlsx' salvo com sucesso!")
} else {
  message("Erro ao obter a lista de deputados.")
}
