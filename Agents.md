# AGENTS.md — DemandFiles Repository Context

This repository (`coeifaria/DemandFiles`) serves as the centralized data store for Lightcast regional occupation demand tables used across Central Valley / Mother Lode regional dashboard applications (e.g., Data Vista, Bachelor Degree Program reports).

---

## 🛠 Repository Components

### 1. Data Staging & Storage
- **`data/`**: Staging directory where raw Lightcast occupation table `.xlsx` files (`NCV`, `SCV`, `CVML`, `California`) are uploaded.
- **`data_<Month><Year>/`**: Historical archive directories (e.g., `data_July2026/`) created automatically after processing raw files.
- **`demand_files_<Month><Year>.rds`**: Output dataset generated per run, containing cleaned regional data frames (`n`, `s`, `cvml`, `ca`) and version metadata.

### 2. Core Scripts & Tooling
- **`run_pipeline.bat`**: 1-click Windows batch script that orchestrates the end-to-end workflow:
  1. Detects Rscript at `C:\Users\if001\AppData\Local\Programs\R\R-4.5.1\bin\Rscript.exe` (or PATH).
  2. Runs `xlsx_to_rds.R`.
  3. Stages generated `.rds`, archived `data_<Month><Year>/`, and `data/.gitkeep`.
  4. Prompts for an optional custom commit message (default: `feat: update demand files and raw data archive`).
  5. Commits and pushes to `GithubRepo master`.

- **`xlsx_to_rds.R`**: Core R transformation script that performs:
  1. **`rename_data_files()`**: Parses `Cover Page` tab, extracts Quarter (`Q1`–`Q4`) and Year (`2025`, `2026`), and replaces trailing hex hashes (e.g., `_0e2b54a0cb26fff2`) with `_Q3_2026`.
  2. **Data Cleaning (`fix_columns`)**: Replaces missing indicators (`<10`, `Insf. Data`) with `0` and rounds numeric values.
  3. **Metadata Extraction (`demand_func_validate`)**: Reads Cover Page and Parameters sheets dynamically per region (`NCV`, `SCV`, `CVML`, `California`).
  4. **RDS Compilation**: Saves structured list `demand_files` with elements `version`, `n`, `s`, `cvml`, and `ca`.
  5. **Archive & Cleanup**: Moves raw files into `data_<Month><Year>/` and recreates `data/` with `.gitkeep`.

- **`occupation_tables_url_func.R`**: R helper function used by external applications to fetch the latest `.rds` dataset directly from GitHub:
  ```r
  source("https://raw.githubusercontent.com/coeifaria/DemandFiles/master/occupation_tables_url_func.R")
  demand_data <- occupation_tables_url_func()
  ```

- **`xls_to_xlsx.R`**: Retained legacy format conversion script.

---

## 🚀 Standard Workflow

1. Place the 4 raw Lightcast Excel files into the `data/` folder.
2. Double-click `run_pipeline.bat` (or execute `run_pipeline.bat` from terminal).
3. Confirm completion; pipeline automatically cleans, transforms, archives, commits, and pushes to `GithubRepo master`.
