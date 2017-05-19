#' Function to transform a \code{NetCDF} file from FAAM activites to a data 
#' frame.
#' 
#' @param file File names of FAAM \code{NetCDF} files. 
#' 
#' @author Stuart K. Grange
#' 
#' @return Data frame. 
#' 
#' @examples 
#' \dontrun{
#' 
#' # Create tidy data from a single file
#' data_faam <- tidy_faam_netcdf(file = "data/core_faam_1hz.nc")
#' 
#' # Transform multiple files
#' files <- c("data/core_faam_1hz.nc", "data/core_faam_10hz.nc")
#' data_faam_many <- tidy_faam_netcdf(file = files)
#' 
#' }
#' 
#' @export
tidy_faam_netcdf <- function(file) {
  
  data_frame(file = file) %>% 
    rowwise() %>% 
    do(tidy_faam_netcdf_worker(.$file)) %>% 
    ungroup()
  
}


tidy_faam_netcdf_worker <- function(file, tz = "UTC") {
  
  # Connect to file
  ncdf <- ncdf4::nc_open(file)
  
  # Extract date from netcdf file, not within the variable structure
  date_ncdf <- extract_date(ncdf, tz = tz)
  
  # Get variables in netcdf file
  variables <- names(ncdf$var)
  
  # Extract all variables in netcdf file
  list_variables <- lapply(variables, function(x) extract_variable(ncdf, x))
  
  # Bind to form a single data frame
  df <- do.call(cbind, list_variables)
  
  # Add date to data frame and arrange variable order
  df <- df %>% 
    mutate(file = basename(file),
           date = date_ncdf) %>% 
    select(file,
           date, 
           starts_with("lat_", ignore.case = TRUE),
           starts_with("lon_", ignore.case = TRUE),
           starts_with("alt_", ignore.case = TRUE),
           everything())
  
  return(df)
  
}


# Define the functions
extract_date <- function(ncdf, tz) {
  
  # Get date piece
  date <- ncdf$dim$Time
  
  # Parse date start
  date_anchor <- date$units
  date_anchor <- stringr::str_split_fixed(date_anchor, " ", 3)[, 3]
  date_anchor <- lubridate::ymd_hms(date_anchor, tz = tz)
  
  # Get the date vector
  date <- date$vals
  
  # Add vector to date anchor, just an epoch date
  date <- date + date_anchor
  
  return(date)
  
}


extract_variable <- function(ncdf, variable) {
  
  # Get variable's values
  value <- ncdf4::ncvar_get(ncdf, variable)
  
  # Make a data frame
  df <- data.frame(
    value,
    stringsAsFactors = FALSE
  )
  
  # Give name
  names(df) <- variable
  
  return(df)
  
}
