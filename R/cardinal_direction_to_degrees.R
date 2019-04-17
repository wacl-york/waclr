#' Function to transform cardinal direction wind directions to decimal degrees. 
#' 
#' @param x Character vector with cardinal direction elements. 
#' 
#' @param north_is What decimal degree should north be transformed to? Can be 
#' either 360 or 0. 
#' 
#' @author Stuart K. Grange. 
#' 
#' @return Numeric vector. 
#' 
#' @examples  
#' 
#' # Function uses uppercase and abbreviated cardinal directions
#' x <- c(
#'   "N", "NNE", "NE", "ENE", "E", "ESE", "SE", "SSE", "S", "SSW", "SW", "WSW", 
#'   "W", "WNW", "NW", "NNW"
#' )
#' 
#' # Transform to decimal degrees
#' cardinal_direction_to_degrees(x)
#' 
#' # Transform but use 0 degrees for north
#' cardinal_direction_to_degrees(x, north_is = 0)
#' 
#' @export
cardinal_direction_to_degrees <- function(x, north_is = 360) {
  
  # Check inputs
  stopifnot(north_is %in% c(360, 0))
  
  # Make sure vector is uppercase
  x <- stringr::str_to_upper(x)
  
  # Change northerly degrees to zero
  if (north_is == 0) {
    df_look_up <- cardinal_directions_look_up() %>% 
      mutate(degrees_direction_mean = if_else(cardinal_direction == "N", 0, degrees_direction_mean))
  } else {
    df_look_up <- cardinal_directions_look_up()
  }
  
  # Do the transformation with a join
  x <- tibble(cardinal_direction = x) %>% 
    left_join(df_look_up, by = "cardinal_direction") %>% 
    pull(degrees_direction_mean)
  
  return(x)

}


# Scraped from http://snowfence.umn.edu/Components/winddirectionanddegreeswithouttable3.htm
cardinal_directions_look_up <- function(minimal = TRUE) {
  
  df <- dplyr::tribble(
    ~cardinal_direction, ~degrees_direction_min, ~degrees_direction_max, ~degrees_direction_mean,
    "N",                 348.75,                 11.25,                  360,                    
    "NNE",               11.25,                  33.75,                  22.5,                   
    "NE",                33.75,                  56.25,                  45,                     
    "ENE",               56.25,                  78.75,                  67.5,                   
    "E",                 78.75,                  101.25,                 90,                     
    "ESE",               101.25,                 123.75,                 112.5,                  
    "SE",                123.75,                 146.25,                 135,                    
    "SSE",               146.25,                 168.75,                 157.5,                  
    "S",                 168.75,                 191.25,                 180,                    
    "SSW",               191.25,                 213.75,                 202.5,                  
    "SW",                213.75,                 236.25,                 225,                    
    "WSW",               236.25,                 258.75,                 247.5,                  
    "W",                 258.75,                 281.25,                 270,                    
    "WNW",               281.25,                 303.75,                 292.5,                  
    "NW",                303.75,                 326.25,                 315,                    
    "NNW",               326.25,                 348.75,                 337.5
  )
  
  # Select variables 
  if (minimal) df <- select(df, cardinal_direction, degrees_direction_mean)
  
  return(df)
  
}
