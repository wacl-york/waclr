#' Function to get data for WACL (Wolfson Atmospheric Laboratory) uses.
#' 
#' The data imported by this function should always be regarded as preliminary 
#' and not validated or ratified. \code{get_wacl_data} will attempt to find any
#' data with site and year combinations which are used, but this does not 
#' guarantee that these data are available.
#' 
#' @author Stuart K. Grange 
#' 
#' @param site Site to get data for. Currently only \code{"kirb"} and 
#' \code{"litp"} are supported. 
#' 
#' @param year Year(s) to get data for. 
#' 
#' @return Tidy data frame contains sites' monitoring data with correct data 
#' types. 
#' 
#' @import dplyr
#' 
#' @examples 
#' \dontrun{
#' 
#' # Get data for the kirb site for 2016
#' data_kirb_2016 <- get_wacl_data(site = "kirb", year = 2016)
#' 
#' # Get data for two sites for many years
#' data_two_sites <- get_wacl_data(site = c("kirb", "litp"), year = 2015:2017)
#' 
#' }
#' 
#' @export
get_wacl_data <- function(site, year = 2015:2017) {
  
  # Straight to the file
  url_base <- "https://github.com/skgrange/web.server/blob/master/data/wacl/"
  url_suffix <- "?raw=true"
  
  # Assign some useful things
  temp_directory <- tempdir()
  
  # All combinations of site and year
  df_strings <- expand.grid(site, year, stringsAsFactors = FALSE)
  names(df_strings) <- c("site", "year")
  
  # Buld url strings
  file_names <- stringr::str_c(df_strings$year, "_", df_strings$site, 
                               "_hourly_data.csv.bz2")
  
  # Add base and suffix
  urls <- stringr::str_c(url_base, file_names, url_suffix)
  
  # Download files, do not warn if missing.
  suppressWarnings(
    download_file(urls, directory = temp_directory)
  )
  
  # Load files
  file_list <- list.files(temp_directory, stringr::str_c(site, collapse = "|"), 
                          full.names = TRUE)
  
  if (length(file_list) == 0)
    stop("No data could be found.", call. = FALSE)
  
  df <- plyr::ldply(file_list, read.csv, stringsAsFactors = FALSE)
  
  # Trash files
  invisible(
    file.remove(file_list)
  )
  
  # Transform
  df <- df %>% 
    mutate(date = lubridate::ymd_hms(date, tz = "UTC"),
           date_end = lubridate::ymd_hms(date_end, tz = "UTC"))
  
  # Return
  df
  
}
