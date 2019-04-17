#' Function to extract time-zone from a POSIXct date.  
#' 
#' @author Stuart K. Grange
#' 
#' @param date Date vector
#' 
#' @return Character vector with a length of one. 
#' 
#' @examples 
#' 
#' # A date vector
#' x <- lubridate::ymd_h("2018-05-05 11", tz = "Europe/Zurich")
#' time_zone(x)
#' 
#' @export
time_zone <- function(date) attr(date, "tzone")


#' Function to conveniently parse a vector of unix time to a POSIXct date vector. 
#' 
#' @author Stuart K. Grange
#' 
#' @param x An integer- or numeric-vector of unix times. 
#' 
#' @param tz Time-zone string. \code{parse_unix_time} defaults to \code{"UTC"}. 
#' 
#' @param origin Origin of epoch. By definition, unix time is \code{"1970-01-01"},
#' but other epochs are in use. 
#' 
#' @return A POSIXct vector with the length of x. 
#' 
#' @examples
#'
#' # A vector
#' unix_time_vector <- c(1460034000, 1460034703)
#' 
#' # Parse time, will be in UTC time-zone
#' parse_unix_time(unix_time_vector)
#' 
#' # Or in Berlin's time-zone
#' parse_unix_time(unix_time_vector, tz = "Europe/Berlin")
#' 
#' @export 
parse_unix_time <- function(x, tz = "UTC", origin = "1970-01-01") {
  
  # A switch for my common usage
  if (tz == "nz") tz <- "Etc/GMT-12"
  
  # Parse
  x <- as.POSIXct(x, tz = tz, origin = origin)
  
  return(x)
  
}


#' Function to parse Microsoft Excel's numeric date. 
#' 
#' Depending on what version of Microsoft Excel, there are two origins used. 
#' 
#' @author Stuart K. Grange
#' 
#' @param x Numeric vector. 
#' 
#' @param tz Time-zone. Default is \code{"UTC"}. 
#' 
#' @param type Type of Microsoft Excel date. Can be \code{"windows"} or 
#' \code{"os_x_2007"}. 
#' 
#' @seealso \href{http://stackoverflow.com/questions/1703505/excel-date-to-unix-timestamp}{stackoverflow},
#' \code{\link{unix_time_to_excel_date}}
#' 
#' @export
parse_excel_date <- function(x, tz = "UTC", type = "windows") {
  
  # Check
  type <- stringr::str_to_lower(type)
  type <- stringr::str_replace_all(type, "\\.| ", "_")
  
  if (!type %in% c("windows", "os_x_2007")) {
    stop("Type must be 'windows' or 'os_x_2007'", call. = FALSE)
  }
  
  # To numeric
  if (!class(x) == "numeric") x <- as.numeric(x)
  
  # To unix time, different origins depending on version
  if (type == "windows") x <- (x - 25569) * 86400
  if (type == "os_x_2007") x <- (x - 24107) * 86400
  
  # To POSIXct
  x <- parse_unix_time(x, tz = tz)
  
  return(x)
  
}


#' Function to convert unix time to a Microsoft Excel date. 
#' 
#' Depending on what version of Microsoft Excel, there are two origins used. 
#' 
#' @author Stuart K. Grange
#' 
#' @param x Numeric vector. 
#' 
#' @param tz Time-zone. Default is \code{"UTC"}. 
#' 
#' @param type Type of Microsoft Excel date. Can be \code{"windows"} or 
#' \code{"os_x_2007"}. 
#' 
#' @seealso \href{http://stackoverflow.com/questions/1703505/excel-date-to-unix-timestamp}{stackoverflow},
#' \code{\link{parse_excel_date}}
#' 
#' @export
unix_time_to_excel_date <- function(x, tz = "UTC", type = "windows") {
  
  # Check
  type <- stringr::str_to_lower(type)
  type <- stringr::str_replace_all(type, "\\.| ", "_")
  
  if (!type %in% c("windows", "os_x_2007")) {
    stop("Type must be 'windows' or 'os_x_2007'", call. = FALSE)
  }
  
  # To numeric
  suppressWarnings(
    if (!class(x) == "numeric") x <- as.numeric(x)
  )
  
  # To Excel date, different origins depending on version
  if (type == "windows") x <- (x / 86400) + 25569
  if (type == "os_x_2007") x <- (x / 86400) + 24107
  
  return(x)
  
}


#' Function to test if dates are during the weekend or not. 
#' 
#' @author Stuart K. Grange
#' 
#' @param x Date vector.
#' 
#' @return Logical vector.
#' 
#' @export
weekend <- function(x) {
  
  x <- lubridate::wday(x)
  x <- if_else(x %in% c(1, 7), TRUE, FALSE)
  return(x)
  
}
