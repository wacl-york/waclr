#' Function to get WACL's invalidations.   
#' 
#' This function is now defunct. Please access offical data from ceda 
#' http://www.ceda.ac.uk/. 
#' 
#' \code{\link{get_wacl_invalidations}} is used to get date ranges where data 
#' is considered invlid. The invalidation table and ranges is dynamic so may 
#' change at anytime. 
#' 
#' @param json Should the return be in JSON format? Default is \code{FALSE}. 
#' 
#' @return Data frame or pretty printed JSON with correct data types. 
#' 
#' @author Stuart K. Grange
#' 
#' @seealso \code{\link{get_wacl_data}}, \code{\link{get_wacl_sites}},
#' \code{\link{get_wacl_processes}}
#' 
#' @examples 
#' \dontrun{
#' 
#' # Get sites
#' data_invalidations <- get_wacl_invalidations()
#' 
#' # Or print as json
#' get_wacl_invalidations(json = TRUE)
#' 
#' }
#' 
#' @export
get_wacl_invalidations <- function(json = FALSE) {
  
  # This function will no longer work
  message <- "This function is now defunct.\nPlease access offical data from ceda: http://www.ceda.ac.uk/"
  .Defunct(package = "waclr", msg = message)
  
  # Straight to the file
  url_base <- "https://github.com/skgrange/web.server/blob/master/data/wacl/"
  file_name <- "wacl_invalidations.csv.bz2"
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
  df$date_start <- lubridate::ymd_hms(df$date_start, tz = "UTC")
  df$date_end <- lubridate::ymd_hms(df$date_end, tz = "UTC")
  
  # To json, not a helpful name here
  if (json) df <- jsonlite::toJSON(df, pretty = TRUE)
  
  # Return
  df
  
}
