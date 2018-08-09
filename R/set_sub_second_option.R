#' Function to set R's options to print fractional seconds. 
#' 
#' @param digits Number of fractional seconds to display. 
#' 
#' @author Stuart K. Grange
#' 
#' @return Invisible, a change in R's global options.
#' 
#' @export
set_sub_second_option <- function(digits = 5) options(digits.secs = digits)
