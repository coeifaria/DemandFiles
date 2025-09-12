library(readxl)
# List files matching the criteria

file_path <- file.path(getwd(), "data")
xls_files <- list.files("data", pattern = "\\.xls$")
xlsx_files <- list.files("data", pattern = "\\.xlsx")

if (length(xls_files) > 0 & length(xlsx_files)==0){

  ps_script_path <- file.path(getwd(), "convert.ps1")
  #source_file <- "convert.ps1"
  #destination_file <- "../convert.ps1" # One directory up from R's current working directory
  source_path_full <- normalizePath(ps_script_path, winslash="\\", mustWork=TRUE)
  #destination_path_full <- normalizePath(destination_file, winslash="\\", mustWork=FALSE) # Destination might not exist yet
  # Path to the PowerShell script that performs the move
  #move_ps_script <- normalizePath("move_convert_script.ps1", winslash="\\", mustWork=TRUE)

  system2(
    "powershell.exe",
    args = c(
      "-NoProfile",
      "-ExecutionPolicy", "Bypass",
      "-File", paste0('"', ps_script_path, '"')
      #"-SourcePath", paste0('"', source_path_full, '"')#,
#      "-DestinationPath", paste0('"', destination_path_full, '"')
    ),
    stdout = TRUE, # Capture output for debugging
    stderr = TRUE, # Capture errors for debugging
    wait = TRUE
  )

  setwd("data")
  print(getwd())
  output <- system2(
    "powershell.exe",
    args = c("-NoProfile", "-ExecutionPolicy", "Bypass", "-File", "../convert.ps1"),
    stdout = TRUE, # Capture standard output
    stderr = TRUE # Capture standard error
  )
  cat(output)
  print(list.files())
  setwd("..")
  print(getwd())
} else {
  print(".xlsx files present")
}
