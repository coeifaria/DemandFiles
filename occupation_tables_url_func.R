library(httr)
library(jsonlite)
library(stringr)
library(dplyr)
library(lubridate)

rds_from_url <- function(url) {
  tmp <- tempfile(fileext = ".rds")
  on.exit(unlink(tmp), add = TRUE)
  download.file(url, tmp, mode = "wb", quiet = TRUE)
  readRDS(tmp)
}


list_repo_files <- function(owner, repo, branch = "master") {
  url <- sprintf(
    "https://api.github.com/repos/%s/%s/git/trees/%s?recursive=1",
    owner, repo, branch
  )

  resp <- GET(url)
  stop_for_status(resp)

  tree <- fromJSON(content(resp, as = "text", encoding = "UTF-8"))$tree
  tree$path
}

find_latest_rds_file <- function(owner = "coeifaria",
                                 repo = "DemandFiles",
                                 branch = "master") {

  files <- list_repo_files(owner, repo, branch)

  rds_files <- files %>%
    .[str_detect(., "^demand_files_[A-Za-z]+\\d{4}\\.rds$")]

  parsed <- tibble(file = rds_files) %>%
    mutate(
      stem = str_remove(file, "^demand_files_") |> str_remove("\\.rds$"),
      year = as.integer(str_extract(stem, "\\d{4}")),
      month_name = str_remove(stem, "\\d{4}$"),
      month_num = match(month_name, month.name),
      file_date = make_date(year = year, month = month_num, day = 1)
    ) %>%
    filter(!is.na(month_num), !is.na(year)) %>%
    arrange(desc(file_date))

  parsed %>% slice(1)
}



occupation_tables_url_func <- function(
    month = NULL,
    year_f = NULL,
    section = NULL,
    branch = "master"
) {
  latest_file <- find_latest_rds_file()

  month_f <- if (is.null(month)) latest_file$month_num else month
  year_f <- if (is.null(year_f)) latest_file$year else year_f
  month_f <- as.character(lubridate::month(month_f, label = TRUE, abbr = FALSE))

  file_name <- paste0("demand_files_", month_f, year_f, ".rds")
  url_rds <- paste0(
    "https://raw.githubusercontent.com/coeifaria/DemandFiles/",
    branch, "/",
    file_name
  )

  df <- rds_from_url(url_rds)

  if (!is.null(section)) {
    df <- df[[section]]
  }

  df
}


#demand_files_url_list <- occupation_tables_url_func()
#demand_files_url_cvml_df <- occupation_tables_url_func(section = "cvml")
#demand_files_url_version <- occupation_tables_url_func(section = "version")
