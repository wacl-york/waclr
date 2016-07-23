#' Function to get WACL's processes. 
#' 
#' @param json Should the return be in JSON format? Default is \code{FALSE}. 
#' 
#' @return Data frame or JSON with correct data types. 
#' 
#' @author Stuart K. Grange
#' 
#' @examples 
#' \dontrun{
#' 
#' # Get processes
#' data_processes <- get_wacl_processes()
#' 
#' # Or print as json
#' get_wacl_processes(json = TRUE)
#' 
#' }
#' 
#' @export
get_wacl_processes <- function(json = FALSE) {
  
  # Straight to the file
  url_base <- "https://github.com/skgrange/web.server/blob/master/data/wacl/"
  file_name <- "wacl_processes.csv.bz2"
  url_suffix <- "?raw=true"
  
  # Concatenate
  url <- stringr::str_c(url_base, file_name, url_suffix)
  
  # Get files
  download_file(url, directory = tempdir())
  
  # Load file
  df <- read.csv(file.path(tempdir(), basename(url)), stringsAsFactors = FALSE)
  
  # Parse dates
  df$date_start <- lubridate::ymd_hms(df$date_start, tz = "UTC", quiet = TRUE)
  df$date_end <- lubridate::ymd_hms(df$date_end, tz = "UTC", quiet = TRUE)
  
  # To json, not a helpful name here
  if (json) df <- jsonlite::toJSON(df, pretty = TRUE)
  
  # Return
  df
  
}
