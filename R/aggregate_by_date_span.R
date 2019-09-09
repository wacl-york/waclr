#' Aggregate meteorological data from date span. 
#' 
#' Given averaged data with span ranges in \code{"date_start"} and 
#' \code{"date_end"} columns and met data with "date" column, average met data 
#' over span range and append to data frame
#'  
#' @param df Data frame containing span range. 
#' 
#' @param df_met Data frame containg met data. 
#' 
#' @param warn Should the function give warnings? 
#' 
#' @param progress Type of progress bar. Supply "time" for progress bar. 
#' 
#' @param ... Additional arguments to pass to openair::timeAverage
#' 
#' @author Will Drysdale and Stuart K. Grange
#' 
#' @return Data frame. 
#' 
#' @examples 
#' \dontrun{
#' 
#' # Combine GC and met data
#' data_all <- aggregate_by_date_span(data_gc, data_met)
#' 
#' }
#'  
#' @export
aggregate_by_date_span <- function(df, df_met, warn = TRUE, progress = "none",...) {
  
  # Do row-wise
  plyr::adply(df, 1, function(x) 
    aggregate_by_date_span_worker(x, df_met, warn), .progress = progress,...)
  
}


aggregate_by_date_span_worker <- function(df, df_met, warn,...) {
  
  # Get dates
  date_start <- df$date_start[1]
  date_end <- df$date_end[1]
  
  # Filter met by dates
  df_met_filter <- df_met[df_met$date >= date_start & df_met$date <= date_end, ]
  
  # Aggregate
  if (nrow(df_met_filter) >= 1) {
    
    # Do
    df_met_filter_agg <- openair::timeAverage(df_met_filter, avg.time = "year",...)
    
  } else {
    
    # Raise warning
    if (warn)
      warning(stringr::str_c("Skipping row: ", row.names(df)), call. = FALSE)
    
    # Reassign
    df_met_filter_agg <- df_met_filter
    
    # Ensure there is is an observation even if missing
    df_met_filter_agg[1, ] <- NA
    
  }
  
  # Drop unneeded date
  df_met_filter_agg$date <- NULL
  
  # Bind
  df <- dplyr::bind_cols(df, df_met_filter_agg)
  
  return(df)
  
}
