# Pulled from threadr package
# No export
str_drop_xml_tags <- function(string) {
  
  string <- stringr::str_replace_all(string, "<.*?>", "")
  string <- stringr::str_trim(string)
  string
  
}


os_type <- function() stringr::str_to_lower(unname(Sys.info()["sysname"]))
