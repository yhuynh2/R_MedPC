#_______________________________________________________________

#   Final Version of MEDPC2XL modified on August 2nd, 2019 (V6)
#_______________________________________________________________


# Description -------------------------------------------------------------

## This is the complete functional MedPC2XL equivalent.
## The only lines of code you change are the file paths for setting the working directory (wd).
## Once you set the working directory to the folder that contains the data files (or data sub-folders),
## You can run the code and it will take out all the files, including files from a sub-folder
## WITHOUT needing to change the working directory for each sub-folder 
## (i.e. a path like: /Users/wendy/Box Sync/Bevins Lab/MedPC2XL Converter/Practice Data
## will obtain ALL files inside the "Practice Data" folder (incl. subfolders).
## Make sure that the file path used for this consists of ONLY MPC data files (no .docx, .xlsx, files etc).
## Last bit of code (creating "final" object) take a while longer to run (~5 sec)
## NAs will be produced where the file lacks a value other files include.
## For example, if not all subj have variable Z606 (e.g., activity bin measure), will produce NA
## Make sure to change the wd AFTER you import all files using this code!! 


# Requirements ------------------------------------------------------------
# You must have two packages installed in order to use this converter: 
## tidyverse 
## splitstackshape

# Updates -----------------------------------------------------------------
#    - generalizable; DOESN'T need 'A' to be the first subsetted variable
#    - doesn't remove variables that are unused (all variables A-Z are present even if not used in program)
#    - Better accounts for last subsetted variable's values (last one cut off values after 5th subsetted ex. V(1)-V(5) but not V(6)+)
#    - Removed warning message for letter variables unused
#    - Ignore the warnings (NAs introduced by coercion)
#    - Removes excess functions and values after code has run
#    - Added Functions useful for data organization (SEM and as.numeric.factor)
#    - Removed Start.Time and End.Time that messes with the 0: identification
#    - Fixed Start.Time/End.Time identification issue; variables now included (v5)
#    - Changed as.tibble to as_tibble; added find.na function (v6)





#_____________________________________________________________________________

#                            Modify Path Code ONLY 
#_____________________________________________________________________________

## Change the pathcode to the file path that contains ONLY your data files
## If this file path includes anything other than raw MPC data files, you must 
## remove those files. No other files (excel, text files, etc.) should be in this file path!
pathcode <- "/Users/wendy/Box Sync/Bevins Lab/MedPC2XL Converter/Practice Data"



#_____________________________________________________________________________

#                         Data Set-up
#_____________________________________________________________________________
# Libraries  --------------------------------------------------------------
library(tidyverse)
library(splitstackshape)

# Set Wd ------------------------------------------------------------------
## WD must be the same location as the files you will import
setwd(str_c(pathcode, "/"))
list_of_files <- list.files(path = ".", recursive = T, full.names = TRUE)
list_of_files # checks the names of your files



#_____________________________________________________________________________

#                        Do not touch this chunk of code 
#_____________________________________________________________________________
# Useful Functions For Data Organization ----------------------------------

# Standard Error of the Mean
sem <- function(x, na.rm = FALSE) {
  out <-sd(x, na.rm = na.rm)/sqrt(length(x))
  return(out)
}

# Convert factors back to their numeric values; 
# this was used bc "final" tbl automatically assumed factor
as.numeric.factor <- function(x) {as.numeric(levels(x))[x]}

# Tells the user where any NA values are located (if any)
find.na <- function(x, na.rm = FALSE) {
  temp <- vector() 
  for (i in names(x)) {    
    temp1 <- colSums(is.na(x)) # counts number of NAs for EVERY column
    temp2 <- temp1[temp1 != 0] # view only: column names with NA and how many NA each col has
  }
  return(temp2)
}

{
  # Reading in text from subject files
  data <- list() 
  for (i in seq_along(list_of_files)) {
    data[[i]] <- readLines(list_of_files[i])
  }
  
  # Combines two strings that contain values of a letter variable for
  # each letter variable 
  # (i.e. if "L" has 10 values, it combines the string from 0: row and 5: row)
  str_combine <<- function(x, sep = " ") {
    if (length(x) > 1) {
      str_c(str_c(x[-length(x)], collapse = sep), x[length(x)])
    } else {
      x
    }
  }
  
  # Retreive variable letters
  # function arguments (x = list, var_letter = "--capital letter--")
  get_var <- function(x, var_letter) {
    # Retain only subsetted letter variables
    z <- which(str_detect(x, "A:"))[1]-1
    x <- x[-(1:z)]
    # Remove "0:" "5:" strings (exclude start/end times)
    x <- str_replace(x, "\\d+:\\s+", "") 
    # Retreive length of list
    nl <- length(x)
    # Detect the start of a line with values of one letter variable
    # (i.e. all values in letter "L")
    start <- which(str_detect(x, var_letter))
    # Debugging used for last letter variable; ignore the warning
    if (length(start) == 0) {
      return(NA)
    }
    # Sets the end of the last letter variable value (last value of letter
    # variable "L")
    
    end <- start + which(str_detect(x[(start+1):nl], "[:alpha:]:$"))[1] - 1
    if (is.na(end)) {
      end <- start + tail(which(str_detect(x[(start+1):(nl)], "\\d$")), n=1)
    }
    return(x[(start + 1):(end)])
  }
  
  # Split letter variable values into individual columns, so each value
  # has a unique column
  splitting <- function(x, label) {
    out <- as.numeric(unlist(str_split(x, "[:space:]+")))
    out <- out[!is.na(out) & out != ""]
    names(out) <- str_c(label, 1:length(out)-1)
    return(out)
  }
  
  # Function that contains info from subj files that DO NOT have subsetted 
  # letter variables (i.e. letter variables with only 1 value,
  # Subject/Program/Group/Date:Time variables)
  beginning <- function(x) {
    beginsubset <- which(str_detect(x, "A:"))[1]
    return(x[-c(1:3, beginsubset:length(x))])
  }
  
  
  
  # Function iterating all subject files through secondary functions
  # argument x = list of subject files to iterate through
  multiple <- function(x) {
    
    # Empty list that will later hold complete variables/values from
    # looping through the get_var function with every letter (A-Z)
    calc <- list()
    # Setting up numerous strings, each containing one capital letter
    # letters_subsetted only contains letters that ARE subsetted
    # letters_not_subsetted contains letters that ARE NOT subsetted
    letters_not_subsetted <- str_extract(beginning(x), "^[:alpha:]:")
    letters_not_subsetted <- str_extract(letters_not_subsetted, "[:alpha:]")
    letters_not_subsetted <- letters_not_subsetted[!is.na(letters_not_subsetted)]
    letters_subsetted <- setdiff(LETTERS, letters_not_subsetted)
    # For-loop iterating through get_var()
    for (j in seq_along(letters_subsetted)) {
      calc[[letters_subsetted[[j]]]] <- get_var(x, letters_subsetted[[j]])
    }
    # Iterates through calc list to find and combine letter variables
    # with multiple lines of values
    for (m in seq_along(calc)) {
      calc[[m]] <- str_combine(calc[[m]])
    }
    # Removing letter variables from the calc list that only have NA values
    if (any(is.na(calc)) == TRUE){
      m <- which(is.na(calc))
      calc <- calc[-m]
    } else {
      calc
    }
    # Removing letter variables from the calc list that only have NA values
    if (any(is.na(calc)) == TRUE){
      cc <- is.na(calc)
      m <- which(cc == c("TRUE"))
      calc <- calc[-m]
    } 
    
    # Setting up list of letter variables that are used in the current program
    letters_used <- names(calc) 
    # For-loop iterating through the calc list searching for only the letter 
    # variables found in the program/subj file
    new <- vector()
    for (i in letters_used) {
      new <- c(new, splitting(calc[[i]], label = i))
    }
    # Object containing non-subsetted letter/other variables
    temp <- beginning(x)
    # Reading through temp object as a debian file (.dcf) and converting
    # to dataframe
    return(cbind(t(new), data.frame(read.dcf(textConnection(temp)))))
  }
  
  # Empty list that will contain iterated subject files through the multiple() function
  calc2 <- list()
  # For-loop that iterates all datafiles through the multiple function and saves it into calc2
  for (w in seq_along(data)){
    calc2[[w]] <- multiple(data[[w]])
  }
  
  # Creating the final dataset (I converted it to a tibble instead of traditional dataframe, 
  # but tibble will function the same)
  final <- data.table::rbindlist(calc2, fill = TRUE)
  final <- as_tibble(final)
  final <- final %>% select(Start.Date, End.Date, Start.Time, End.Time, Subject, Experiment, Group, MSN, Box, everything()) # rearrange columns; put startdate to the front of the tibble
  
  
  # Removes extra values, functions, and objects so that the environment is clean for data organization
  rm(calc2, data, i, list_of_files, pathcode, w, beginning, get_var, multiple, splitting, str_combine)
  names(final)
}

## CHANGE YOUR WD AFTER EXECUTING THIS CODE!
