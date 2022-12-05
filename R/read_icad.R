#' read_ICAD
#' 
#' Simple function to read ICAD data. 
#' 
#' @param ch1 path to a channel 1 file
#' @param ch2 (optional) path to a channel 2 file. If not supplied the string "Channel1" will be replaced with "Channel2" from \code{ch1}
#' @param tz time zone to use when formatting date. default "UTC"
#' @param pad Should NO2, NO2x and NOmeasured channels be linealy interpolated between the different file times. Default false
#' 
#' @author W. S. Drysdale
#' 
#' @export
#' 

read_ICAD = function(ch1,
                     ch2 = NULL,
                     tz = "UTC",
                     pad = FALSE){
  
  require(dplyr)
  
  firstLine = readLines(ch1, n = 1)
  firstWord = stringr::word(firstLine,1,sep = " ")
  if(firstWord == "Analyser"){
    skip = 1
  }else{
    skip = 0
  }
    
  
  if(is.null(ch2) & firstWord == "Analyser"){
    ch2 = stringr::str_replace(ch1,"NO2_CHOCHO_Channel1","NOx_NO_Channel2")
  }
  
  if(is.null(ch2) & firstWord != "Analyser"){
    ch2 = stringr::str_replace(ch1,"Channel1","Channel2")
  }
  
  # sometimes the ICAD writes infinity symbols, the intToUtf8() calls attempt to remove them.
  dat = list(ch1,ch2) %>% 
    purrr::map_df(~.x %>% 
                    read.table(sep = "\t",
                               header = T,
                               comment.char = "",
                               skip = skip,
                               na.strings = c("nan",intToUtf8(8734),intToUtf8(c(45,8734)))) %>% 
                    dplyr::tibble() 
    ) %>% 
    dplyr::mutate(date = lubridate::ymd_hms(Start.Date.Time..UTC.,
                                 tz = tz)) %>% 
    dplyr::relocate(date) %>% 
    dplyr::arrange(date)
  
  if(pad){
    dat = dat %>% 
      dplyr::mutate(dplyr::across(any_of(c("NO2..ppb.", "NO2.x..ppb.", "NO.Measured..ppb.","NOx..ppb.")),
                                  ~zoo::na.approx(.x, na.rm = F)),
                    NO_calc = ifelse(skip == 0, NO2.x..ppb.-NO2..ppb., NOx..ppb.-NO2..ppb.))
    
  }

  # Return
  dat
}
