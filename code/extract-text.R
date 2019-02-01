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
