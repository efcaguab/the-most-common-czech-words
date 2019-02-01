library(magrittr)

functions <- list.files("code", full.names = T) %>%
  lapply(source)

# Download data -----------------------------------------------------------

# download wikipedia articles and index only when there has been an update
wiki_download <- drake::drake_plan(
  wiki_dump_page = get_wiki_dump_page(),
  latest_article_date = get_latest_wiki_article_date(wiki_dump_page),
  latest_index_date = get_latest_wiki_index_date(wiki_dump_page),
  drake::target(
    command = download_wiki_articles(
      drake::file_out(file.path("data", basename(wiki_articles())))), 
    trigger = drake::trigger(change = latest_index_date)), 
  drake::target(
    command = download_wiki_index(
      drake::file_out(file.path("data", basename(wiki_article_index())))), 
    trigger = drake::trigger(change = latest_index_date)), 
  strings_in_dots = "literals"
)


# Extract text data -------------------------------------------------------

# To extract data I use the script provided by wikiextractor
# It was downloaded on 2019-02-01

extract_text_plan <- drake::drake_plan(
  nCores = parallel::detectCores() - 1,
  stdout_extraction = extract_wiki_articles(input = drake::file_in(file.path("data", basename(wiki_articles()))), 
                                            processes = nCores, 
                                            output = "data/extracted-text"),
  strings_in_dots = "literals"
)

full_plan <- dplyr::bind_rows(
  wiki_download, 
  extract_text_plan
)

drake::make(full_plan)
