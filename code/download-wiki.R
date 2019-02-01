wiki_articles <- function(){
  "https://dumps.wikimedia.org/cswiki/latest/cswiki-latest-pages-articles-multistream.xml.bz2"
}

wiki_article_index <- function(){
  "https://dumps.wikimedia.org/cswiki/latest/cswiki-latest-pages-articles-multistream-index.txt.bz2"
} 

get_wiki_dump_page <- function(){
  htm <- xml2::read_html("https://dumps.wikimedia.org/cswiki/latest") 
  
  text <- htm %>%
    rvest::html_nodes("body") %>%
    rvest::html_text()
  
  links <- htm %>%
    rvest::html_nodes("a")
  
  df_links <- tibble::data_frame(
    link = rvest::html_attr(links, "href"), 
    filename = rvest::html_text(links)
  ) %>%
    dplyr::slice(-1)
  
  strsplit(text, "\n") %>%
    extract2(1) %>%
    extract(-c(1:2)) %>% 
    tibble::data_frame(line = .) %>%
    tidyr::separate(line, into = c("filename", "date", "time", "size"), sep = "\\s+", extra = "drop") %>% 
    dplyr::bind_cols(df_links) 
}

get_latest_wiki_article_date <- function(wiki_dump_page){
  wiki_dump_page %>%
    dplyr::filter(link == basename(wiki_articles())) %$%
    date %>%
    as.Date(format = "%d-%b-%Y") 
}

get_latest_wiki_index_date <- function(wiki_dump_page){
  wiki_dump_page %>%
    dplyr::filter(link == basename(wiki_article_index())) %$% 
    date %>%
    as.Date(format = "%d-%b-%Y")
}

download_wiki_index <- function(file_out){
  # create directory if it doesn't exist
  suppressWarnings({
    file_out %>%
      dirname() %>%
      dir.create()
  })
  download.file(
    url = wiki_article_index(), 
    destfile = file_out, 
    method = "auto")
}

download_wiki_articles <- function(file_out){
  # create directory if it doesn't exist
  suppressWarnings({
    file_out %>%
      dirname() %>%
      dir.create()
  })
  download.file(
    url = wiki_articles(), 
    destfile = file_out, 
    method = "auto")
}
