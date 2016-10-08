#' Function to get data for WACL (Wolfson Atmospheric Laboratory) uses.
#' 
#' The data imported by this function should always be regarded as preliminary 
#' and is often not validated or ratified. \code{get_wacl_data} will attempt to 
#' find any data with site and year combinations which are used, but this does 
#' not guarantee that these data are available.
#' 
#' This function may return different table (data frane) formats depending on 
#' the \code{period} argument. 
#' 
#' @author Stuart K. Grange 
#' 
#' @param site Site(s) to get data for. Use \code{\link{get_wacl_sites}} to
#' find sites which are available. \code{site} is a site code such as 
#' \code{"kirb"}. 
#' 
#' @param year Year(s) to get data for. A vector of integers.
#' 
#' @param period Aggregation period to get data for. Default is \code{"hour"}.
#' \code{"source"} can be used to get "source" data. Beware that the importing 
#' of source data can be slow because it is common for sites to have several 
#' million observations for a year. 
#' 
#' @return Data frame containing sites' monitoring data with correct data types. 
#' 
#' @seealso \code{\link{get_wacl_sites}}, \code{\link{get_wacl_processes}}
#' 
#' @import dplyr
#' 
#' @examples 
#' \dontrun{
#' 
#' # Get hourly data for the kirb site for 2016
#' data_kirb_2016 <- get_wacl_data(site = "kirb", year = 2016, period = "hour")
#' 
#' # Get hourly data for two sites for many years
#' data_two_sites <- get_wacl_data(site = c("kirb", "litp"), year = 2015:2017, 
#'                                 period = "hour")
#'                                 
#' # Get source data, one-minute data for a site
#' data_kirb_source <- get_wacl_data(site = "kirb", year = 2016, period = "source")
#' 
#' }
#' 
#' @export
get_wacl_data <- function(site, year, period = "hour") {
  
  # Straight to the file
  url_base <- "https://github.com/skgrange/web.server/blob/master/data/wacl/"
  url_suffix <- "?raw=true"
  
  # All combinations of site and year
  df_strings <- expand.grid(site, year, stringsAsFactors = FALSE)
  names(df_strings) <- c("site", "year")
  
  # Buld url strings
  file_names <- stringr::str_c(df_strings$year, "_", df_strings$site, 
                               "_", period, "_data.csv.bz2")
  
  # Add base and suffix
  urls <- stringr::str_c(url_base, file_names, url_suffix)
  files <- basename(urls)
  files <- stringr::str_replace_all(files, "\\?raw=true", "")
  
  # Download files, do not warn if missing.
  suppressWarnings(
    download_file(urls, directory = tempdir(), file_output = files)
  )
  
  # Load files
  file_list <- list.files(tempdir(), stringr::str_c(files, collapse = "|"), 
                          full.names = TRUE)
  
  # Check
  if (length(file_list) == 0) stop("No data could be found.", call. = FALSE)
  
  # Load data
  suppressMessages(
    df <- plyr::ldply(file_list, readr::read_csv, progress = FALSE)
  )
  
  # Trash files, needed if function is used multiple times during the same 
  # session
  invisible(
    file.remove(file_list)
  )
  
  # Parse dates
  df$date <- lubridate::ymd_hms(df$date, tz = "UTC")
  
  # Sometimes not present in source data
  if (any(grepl("date_end", names(df))))
    df$date_end <- lubridate::ymd_hms(df$date_end, tz = "UTC")
  
  # Return, standard data frame
  data.frame(df)
  
}
