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
#' @param progress Depreciated as purrr::map_Df is used over plyr::adply
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
aggregate_by_date_span <- function(df, df_met, warn = TRUE, progress = NULL, ...) {
  
  if(!is.null(progress)) # warning in the case of backwards compatibility
    warning("progress argument is depreciated")
  
  df %>% split(seq(nrow(df))) %>% # convert data.frame to a list of its rows
    purrr::map_df(aggregate_by_date_span_worker,df_met = df_met, warn = warn,...)
  
  
}


aggregate_by_date_span_worker <- function(df, df_met, warn, ...) {
  
  # Get dates
  date_start <- df$date_start[1]
  date_end <- df$date_end[1]
  
  if(is.na(date_start) | is.na(date_end)){
    if(warn){
      warning(stringr::str_c("Skipping row: ", row.names(df)), call. = FALSE)
      return(NULL)
    }else{
      return(NULL)
    }
  }
  
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
