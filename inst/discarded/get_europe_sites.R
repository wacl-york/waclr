#' Function to get European's sites for WACL (Wolfson Atmospheric Laboratory) 
#' uses.
#' 
#' \code{\link{get_europe_sites}} is used to get the monitoring sites which are 
#' supported by \code{\link{get_europe_data}}. 
#' 
#' @return Data frame. 
#' 
#' @author Stuart K. Grange
#' 
#' @seealso \code{\link{get_europe_data}}
#' 
#' @examples 
#' \dontrun{
#' 
#' # Get sites
#' data_sites <- get_europe_sites()
#' 
#' }
#' 
#' @export
get_europe_sites <- function() {
  
  # Get page as text
  text <- readLines("https://github.com/skgrange/web.server/tree/master/data/european_air_quality/observations",
                    warn = FALSE)
  
  # Filter to files
  text_filter <- grep("european_air_quality_data_site_", text, value = TRUE)
  text_filter <- str_drop_xml_tags(text_filter)
  
  # Get site piece
  sites <- stringr::str_split_fixed(text_filter, "_|\\.", 7)[, 6]
  
  # Make data frame
  df <- data.frame(
    site = sites,
    stringsAsFactors = FALSE
  )
  
  # Return
  df
  
}
