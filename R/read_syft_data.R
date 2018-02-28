#' Function to read Syft \code{.csv} files. 
#' 
#' The Syft instrument reports time with sub second accuracy. This is preserved 
#' but to view this extra precision, set the \code{digits.secs} option. 
#' 
#' @author Stuart K. Grange
#' 
#' @param file Vector of Syft \code{.csv} file names. 
#' 
#' @return Named list containing data frames. 
#' 
#' @examples 
#' \dontrun{
#' 
#' # Load a data file
#' file <- "data/Participant 3/Breath Romance-Participant 3-20180205-152112.csv"
#' list_syft <- read_syft_data(file)
#' 
#' # What units does the list contain? (purrr needs to be loaded)
#' map(list_syft, names) %>% 
#'   flatten_chr()
#'   
#' # Extract observations
#' data_observations <- map_dfr(
#'   list_syft, 
#'   `[[`, 
#'   "detailed_concentrations", 
#'   .id = "file"
#' )
#' 
#' }
#' 
#' @seealso \code{\link{set_sub_second_option}}
#' 
#' @export
read_syft_data <- function(file) {
  
  # Get units from files
  list_tables <- purrr::map(file, read_syft_data_worker)
  
  # Give names
  names(list_tables) <- basename(file)
  
  return(list_tables)
  
}


read_syft_data_worker <- function(file) {
  
  # Read as text
  text <- readLines(file, warn = FALSE)
  
  # Get settings observational unit
  df_settings <- get_syft_settings_table(text)
  
  # Extract date from settings unit, needed for observations
  date_start <- extract_syft_date(df_settings)
  
  # Get detailed concentrations observational unit
  df_detailed_concentrations <- get_detailed_syft_concentrations(text, date_start)
  
  # Other units to-do...
  
  # Build list for return
  list_syft <- list(
    settings = df_settings,
    detailed_concentrations = df_detailed_concentrations
  )
  
  return(list_syft)
  
}


get_syft_settings_table <- function(text) {
  
  # Get settings unit
  index_end_settings <- grep("version.firmware", text)
  text_filter <- text[1:index_end_settings]
  
  text_filter <- stringr::str_replace(text_filter, ",:$", "")
  text_filter <- stringr::str_c(text_filter, "\n")
  text_filter <- stringr::str_c(text_filter, collapse = "")
  
  df <- suppressWarnings(
    readr::read_csv(text_filter, col_names = c("variable", "value", "unit")) 
  )
  
  return(data.frame(df))
  
}


extract_syft_date <- function(df) {
  
  df %>% 
    filter(variable == "job.start.time") %>% 
    mutate(value = as.numeric(value),
           value = value / 1000,
           date = as.POSIXct(value, tz = "UTC", origin = "1970-01-01")) %>% 
    pull(date)
  
}


get_detailed_syft_concentrations <- function(text, date_start) {
  
  # Select tabular data we want
  index_start <- grep("Detailed", text)
  index_end <- tail(grep("Analyte vs Time", text), 1)
  
  # Filter to single table
  text_filter <- text[(index_start + 1):(index_end -2)]
  
  # Clean up
  text_filter <- stringr::str_replace(text_filter, ",:$", "")
  text_filter <- stringr::str_c(text_filter, collapse = "\n")
  
  # Read tabular data
  df <- readr::read_csv(text_filter)
  
  # Clean names
  names <- stringr::str_split_fixed(names(df), " |\\(|\\)|;", 6)[, 1]
  names <- stringr::str_to_lower(names)
  names <- stringr::str_replace_all(names, "-|\\.", "_")
  names <- stringr::str_replace_all(names, "\\+$", "")
  names[1] <- "time_elapsed"
  
  # Give names
  names(df) <- names
  
  # Calculate dates in data file
  df$date <- date_start + df$time_elapsed / 1000
  
  # Drop
  df$time_elapsed <- NULL
  
  # Lowercase phase
  df$phase <- stringr::str_to_lower(df$phase)
  
  # Arrange variables
  df <- select(df, date, everything())
  
  return(data.frame(df))
  
}
