#' Function to get WACL's processes. 
#' 
#' @return Data frame with correct data types. 
#' 
#' @author Stuart K. Grange
#' 
#' @examples 
#' \dontrun{
#' 
#' # Get processes
#' data_processes <- get_wacl_processes()
#' 
#' }
#' 
#' @export
get_wacl_processes <- function() {
  
  # Straight to the file
  url_base <- "https://github.com/skgrange/web.server/blob/master/data/wacl/"
  file_name <- "wacl_processes.csv.bz2"
  url_suffix <- "?raw=true"
  
  # Concatenate
  url <- stringr::str_c(url_base, file_name, url_suffix)
  
  # Assign some useful things
  temp_directory <- tempdir()
  
  download_file(url, directory = temp_directory)
  
  # Load file
  df <- read.csv(file.path(temp_directory, basename(url)), stringsAsFactors = FALSE)
  
  df$date_start <- lubridate::ymd_hms(df$date_start, tz = "UTC", quiet = TRUE)
  df$date_end <- lubridate::ymd_hms(df$date_end, tz = "UTC", quiet = TRUE)
  
  # Return
  df
  
}
