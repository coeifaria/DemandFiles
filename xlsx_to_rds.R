library(tidyverse)
library(readxl)

rename_data_files <- function(data_folder = "data") {
  files <- list.files(data_folder, pattern = "^Occupation.*?\\.[xX][lL][sS][xX]?$", full.names = TRUE)

  for (f in files) {
    if (basename(f) == ".gitkeep") next

    # Read Cover Page sheet to extract Q# and Year
    cp <- read_excel(f, sheet = "Cover Page", col_names = FALSE) %>% suppressMessages()
    cp_text <- paste(na.omit(unlist(cp)), collapse = " ")

    q_match <- str_extract(cp_text, "Q[1-4]|q[1-4]")
    year_match <- str_extract(cp_text, "20\\d{2}")

    if (!is.na(q_match) && !is.na(year_match)) {
      suffix <- paste0("_", str_to_upper(q_match), "_", year_match)

      # Replace trailing hex hash (e.g., _ae48ee4c25ae08e8) before .xlsx
      base_name <- basename(f)
      ext <- str_extract(base_name, "\\.[xX][lL][sS][xX]?$")
      stem <- str_remove(base_name, "\\.[xX][lL][sS][xX]?$")

      new_stem <- str_replace(stem, "_[a-fA-F0-9]{8,}$", suffix)

      # If no hex hash matched, append suffix if not already present
      if (new_stem == stem && !str_detect(stem, paste0(suffix, "$"))) {
        new_stem <- paste0(stem, suffix)
      }

      new_path <- file.path(data_folder, paste0(new_stem, ext))

      if (f != new_path) {
        file.rename(f, new_path)
        print(paste("Renamed raw file:", base_name, "->", paste0(new_stem, ext)))
      }
    }
  }
}

# Automatically rename raw files in data/ before processing
rename_data_files("data")

demand_hires <- list.files(
  path = "data",  # Assuming the files are in a "data" folder
  pattern = "^Occupation.*?(NCV|SCV|CVML|California).*\\.xlsx$",
  full.names = TRUE,
  ignore.case = TRUE
)

# Step 1: Identify problematic columns
find_problematic_columns <- function(df, pattern) {
  cols_with_issues <- vector("logical", length(names(df)))
  for (l in seq_along(names(df))) {
    cols_with_issues[l] <- any(str_detect(df[[l]], pattern))
  }
  return(na.omit(names(df)[cols_with_issues]))
}

fix_columns <- function(df) {
  removeables <- c("<10", "Insf. Data")
  for (remove_me in removeables) {
    fix_us <- find_problematic_columns(df, remove_me)
    for (columns in fix_us) {
      new_column <- df[[columns]] %>%
        na_if(remove_me) %>%
        as.numeric() %>%
        replace_na(0)
      if (remove_me == "<10") {
        new_column <- round(new_column)
      } else {
        new_column <- round(new_column, 2)
      }
      df[[columns]] <- new_column
    }
  }
  return(df)
}

demand_func_df <- function(region) {
  file_target <- demand_hires[str_detect(demand_hires, pattern = region)]
  if (length(file_target) == 0) {
    stop(paste("No matching Excel file found for region:", region))
  }
  file_target <- file_target[1] # Ensure single path string for read_excel
  read_excel(file_target, sheet = "Occs") %>%
    na.omit() %>%
    fix_columns() %>%
    suppressMessages()
}

demand_func_validate <- function(region) {
  file_target <- demand_hires[str_detect(demand_hires, pattern = region)]
  if (length(file_target) == 0) {
    stop(paste("No matching Excel file found for region:", region))
  }
  file_target <- file_target[1] # Ensure single path string for read_excel

  pull_df <- read_excel(file_target, sheet = "Parameters") %>% suppressMessages()
  if (ncol(pull_df) == 2) {
    r <- pull(pull_df, 2) %>% na.exclude()
    l <- pull(pull_df, 1) %>% na.exclude()
  } else {
    l <- pull(pull_df, 1) %>% na.exclude()
    r <- ifelse(region == "California", "ca", str_to_lower(region))
  }

  pull_type <- as.character(last(l))
  pull_range <- as.character(l[which(str_detect(l, pattern = "\\d{4} \\- \\d{4}"))])
  pull_region <- paste(r[-1], collapse = " | ")

  file_string <- pull(read_excel(file_target, sheet = "Cover Page")) %>% suppressMessages()
  foi <- character(0)
  for (val in file_string) {
    if (is.na(val)) {
      ind <- FALSE
    } else {
      ind <- (str_split_1(val, " ")[1] %in% month.name)
    }
    foi <- as.logical(append(foi, ind))
  }

  file_date <- file_string[which(foi)[1]]

  file_month <- str_split_1(file_date, " ")[1]
  file_year <- str_split_1(file_date, " ")[2]

  version <- list(
    region = ifelse(region == "California", "ca", str_to_lower(region)),
    pull_region = pull_region,
    pull_type = pull_type,
    pull_range = pull_range,
    file_month = file_month,
    file_year = file_year
  )
  n_version <- list(version)
  names(n_version) <- region
  return(n_version)
}

all_demand_regions <- c("NCV", "SCV", "CVML", "California")
ncv_demand <- demand_func_df(all_demand_regions[1])
scv_demand <- demand_func_df(all_demand_regions[2])
cvml_demand <- demand_func_df(all_demand_regions[3])
ca_demand <- demand_func_df(all_demand_regions[4])

demand_files <- list()
demand_files[["version"]] <- list()

overall_pull_type <- vector("character")
overall_pull_range <- vector("character")
overall_file_month <- vector("character")
overall_file_year <- vector("character")

for (regions in all_demand_regions) {
  v_info <- demand_func_validate(regions)[[regions]]
  pull_type_i  <- v_info[["pull_type"]]
  pull_range_i <- v_info[["pull_range"]]
  file_month_i <- v_info[["file_month"]]
  file_year_i  <- v_info[["file_year"]]

  overall_pull_type  <- unique(c(overall_pull_type, pull_type_i))
  overall_pull_range <- unique(c(overall_pull_range, pull_range_i))
  overall_file_month <- unique(c(overall_file_month, file_month_i))
  overall_file_year  <- unique(c(overall_file_year, file_year_i))
  rm(pull_type_i, pull_range_i, file_month_i, file_year_i)
}

version <- list(overall = c(paste0(overall_file_month, " ", overall_file_year), overall_pull_type, overall_pull_range))
for (regions in all_demand_regions) {
  version <- c(version, demand_func_validate(regions))
}

demand_files[["version"]] <- version
demand_files[["n"]] <- ncv_demand
demand_files[["s"]] <- scv_demand
demand_files[["cvml"]] <- cvml_demand
demand_files[["ca"]] <- ca_demand

demand_file_name_saving <- str_remove_all(demand_files[["version"]][["overall"]][1], "\\s")
demand_file_name <- paste0("demand_files_", demand_file_name_saving, ".rds")
saveRDS(demand_files, demand_file_name)

print(paste("Saved RDS file:", demand_file_name))

# Define the old and new folder names
old_folder_name <- "data"
new_folder_name <- paste0("data_", demand_file_name_saving)

# Check if the source folder actually exists
if (dir.exists(old_folder_name)) {

  if (!dir.exists(new_folder_name)) {
    file.rename(from = old_folder_name, to = new_folder_name)
    print(paste("Folder successfully renamed from", old_folder_name, "to", new_folder_name))
  } else {
    # Move raw files from data/ into existing archive folder
    files_to_move <- list.files(old_folder_name, full.names = TRUE)
    for (f in files_to_move) {
      if (basename(f) != ".gitkeep") {
        file.copy(f, file.path(new_folder_name, basename(f)), overwrite = TRUE)
        file.remove(f)
      }
    }
    print(paste("Files archived into existing folder:", new_folder_name))
  }

} else {
  print(paste("Error: The source folder '", old_folder_name, "' does not exist."))
}

dir.create("data", showWarnings = FALSE)
file.create("data/.gitkeep")
