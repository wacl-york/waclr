# Pulled from threadr package
download_file <- function(url, directory = NA, file_output = NA, quiet = TRUE, 
                          progress = "none") {
  
  # Check
  if (!length(url) == length(file_output) & !is.na(file_output[1]))
    stop("'url' and 'file_output' must be the same length.", call. = FALSE)
  
  # Use working directory by default
  if (is.na(directory[1])) directory <- getwd()
  if (is.na(file_output[1])) file_output <- basename(url)
  
  # Catch factors
  url <- as.character(url)
  directory <- as.character(directory)
  file_output <- as.character(file_output)
  
  # Create directory if needed
  create_directory(directory, quiet)
  
  # Build two dimensional object
  df_map <- data.frame(
    url = url, 
    directory = directory, 
    file_output = file_output,
    stringsAsFactors = FALSE
  )
  
  # Download multiple files
  plyr::a_ply(df_map, 1, download_to_directory, quiet, .progress = progress)
  
  # No return
  
}


# No export
download_to_directory <- function(df_map, quiet) {
  
  # Get things from mapping data frame
  file <- file.path(df_map$directory, df_map$file_output)
  
  # Download file
  tryCatch({
    
    if (os_type() == "windows") {
      
      download.file(url = df_map$url, destfile = file, quiet = quiet, 
                    mode = "wb")
        
    } else {
      
      download.file(url = df_map$url, destfile = file, quiet = quiet)
      
    }
    
  }, warning = function(w) {
    
    # Make errors only warnings
    warning(stringr::str_c(df_map$url, " was not found."), call. = FALSE)
    
  }, error = function(e) {
    
    # Errors will not stop function
    invisible()
    
  })
  
  # No return
  
}


download_to_temporary <- function(url, quiet = TRUE) {
  
  # Get temp directory
  directory <- tempdir()
  
  # Download file
  download_file(url, directory = directory, quiet = quiet)
  
  # No return
  
}


create_directory <- function(directory, quiet = TRUE)
  plyr::l_ply(directory, directory_creator, quiet)


# The actual function
directory_creator <- function(x, quiet) {
  
  if (!dir.exists(x)) {
    
    # Create
    dir.create(x, recursive = TRUE)
    
    # Message
    if (!quiet) message(stringr::str_c("Created '", x, "' directory."))
    
  }
  
}


str_drop_xml_tags <- function(string) {
  
  string <- stringr::str_replace_all(string, "<.*?>", "")
  string <- stringr::str_trim(string)
  string
  
}

os_type <- function() stringr::str_to_lower(unname(Sys.info()["sysname"]))
