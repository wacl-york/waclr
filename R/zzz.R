#' Function to squash R check's global variable notes. 
#' 
if (getRversion() >= "2.15.1") {
  
  # What variables are causing issues?
  variables <- c(".", "variable", "value")
  
  # Squash the note
  utils::globalVariables(variables)
  
}
