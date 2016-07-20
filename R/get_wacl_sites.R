#' Function to get WACL's sites.  
#' 
#' @param json Should the return be in JSON format? Default is \code{FALSE}. 
#' 
#' @return Data frame or pretty printed JSON with correct data types. 
#' 
#' @author Stuart K. Grange
#' 
#' @examples 
#' \dontrun{
#' 
#' # Get sites
#' data_sites <- get_wacl_sites()
#' 
#' # Or print as json
#' get_wacl_sites(json = TRUE)
#' 
#' }
#' 
#' @export
get_wacl_sites <- function(json = FALSE) {
  
  # Straight to the file
  url_base <- "https://github.com/skgrange/web.server/blob/master/data/wacl/"
  file_name <- "wacl_sites.csv.bz2"
  url_suffix <- "?raw=true"
  
  # Concatenate
  url <- stringr::str_c(url_base, file_name, url_suffix)
  
  # Assign some useful things
  temp_directory <- tempdir()
  
  download_file(url, directory = temp_directory)
  
  # Load file
  df <- read.csv(file.path(temp_directory, basename(url)), stringsAsFactors = FALSE)
  
  # To json, not a helpful name here
  if (json) df <- jsonlite::toJSON(df, pretty = TRUE)
  
  # Return
  df
  
}