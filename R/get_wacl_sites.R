#' Function to get WACL's sites.  
#' 
#' \code{\link{get_wacl_sites}} is used to get the monitoring sites which are 
#' supported by \code{\link{get_wacl_data}}. 
#' 
#' @param json Should the return be in JSON format? Default is \code{FALSE}. 
#' 
#' @return Data frame or pretty printed JSON with correct data types. 
#' 
#' @author Stuart K. Grange
#' 
#' @seealso \code{\link{get_wacl_data}}
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
  file_temp <- basename(url)
  file_temp <- stringr::str_replace(file_temp, "\\?raw=true$", "")
  
  # Download file
  download_file(url, directory = tempdir(), file_output = file_temp)
  
  # Load downloaded data
  df <- read.csv(file.path(tempdir(), file_temp), stringsAsFactors = FALSE)
  
  # Parse dates
  df$date_start <- lubridate::ymd_hms(df$date_start, quiet = TRUE)
  df$date_end <- lubridate::ymd_hms(df$date_end, quiet = TRUE)
  
  # To json, not a helpful name here
  if (json) df <- jsonlite::toJSON(df, pretty = TRUE)
  
  # Return
  df
  
}
