#' Function to get European data for WACL (Wolfson Atmospheric Laboratory) uses.
#' 
#' Data imported by this function are sourced from the European AirBase and 
#' e-Reporting data repositories. \code{get_europe_data} will attempt to 
#' find any data with the sites used, but this does not guarantee that these 
#' sites' data are available. 
#' 
#' This function is very simple and does not allow for control of dates and
#' variables yet. If useful, the function will be developed further. 
#' 
#' @param site Site(s) to get data for. \code{site} is a site code such as 
#' \code{"ch0001a"}. \code{\link{get_europe_sites}} can be used to find the 
#' sites available. 
#' 
#' @author Stuart K. Grange
#' 
#' @return Data frame.
#' 
#' @seealso \code{\link{get_europe_sites}}
#' 
#' @examples 
#' \dontrun{
#' 
#' # Get some swiss data, two sites
#' data_ch <- get_europe_data(site = c("ch0001a", "ch0038a"))
#' 
#' }
#' 
#' @export
get_europe_data <- function(site) {
  
  # Build remote file name
  file_prefix <- "european_air_quality_data_site_"
  url_prefix <- "https://github.com/skgrange/web.server/blob/master/data/european_air_quality/observations/"
  url_suffix <- "?raw=true"
  
  # All sites
  url <- stringr::str_c(url_prefix, "/", file_prefix, site, ".rds", url_suffix)
  
  # Get files
  suppressWarnings(
    download_to_temporary(url, quiet = TRUE)
  )
  
  # Get file list of files downloaded
  site_collapsed <- stringr::str_c(site, collapse = "|")
  file_list <- list.files(tempdir(), site_collapsed, full.names = TRUE)
  
  # Check
  if (length(file_list) == 0) stop("No data could be found.", call. = FALSE)
  
  # # Load data
  # df <- data_frame(file = file_list) %>% 
  #   rowwise() %>% 
  #   do(readRDS(.$file)) %>% 
  #   ungroup() %>% 
  #   data.frame()
  
  # Load data
  df <- plyr::ldply(file_list, readRDS)
  
  # Trash files 
  invisible(
    file.remove(file_list)
  )
  
  # Return
  df
  
}
