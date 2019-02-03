extract_wiki_articles <- function(input, processes = 1, output){
  # create output folder if it doesn't exist
  suppressWarnings({
    output %>%
      dir.create()
  })
  
  system2(
    command = "wikiextractor/WikiExtractor.py", 
    args = c("--processes", processes, 
             "--output", output, 
             "--bytes", "10M",
             "--json", 
             # "--compress", 
             "--no-templates", 
             input), 
    stdout = TRUE)
}

get_lemma_frequency <- function(extracted_text_folder, lang_model_info){
  require(data.table)
  future::plan(future::multiprocess)
  lang_model <- udpipe::udpipe_load_model(lang_model_info$file_model)
  
  tokens <- list.files(extracted_text_folder, recursive = T, full.names = TRUE) %>%
    furrr::future_map_dfr(get_lemmas_file, lang_model, .progress = TRUE)
  
  tokens[, sum(N), .(lemma, upos)]
  
}

get_lemmas_file <- function(file_name, lang_model){
  tokens <- file_name %>%
    readLines() %>%
    purrr::map_dfr(get_lemmas_document, lang_model)
  
  # count lemmatized tokens per part of speech
  tokens[, .N, by = .(lemma, upos)]
}


get_lemmas_document <- function(x, lang_model){
  
  article_json <- jsonlite::fromJSON(x)
  
  annotated <- article_json %$%
    udpipe::udpipe_annotate(object = lang_model, x = text, parser = "none") %>%
    as.data.table() 
  
  annotated[, .(lemma, upos)]
}

filter_lemmas <- function(xx){
  require(data.table)
  xx <- xx[!upos %in% c("PUNCT", "NUM", "PROPN")][order(-V1)]
  xx[, freq := V1/sum(V1)]
}
