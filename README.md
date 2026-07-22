# DemandFiles

A centralized repository for storing and transforming regional labor market demand data (Lightcast raw occupation tables) into optimized `.rds` datasets for Central Valley / Mother Lode regional dashboard applications.

---

## 📁 Repository Structure

- **`data/`**: Directory where raw Lightcast occupation table `.xlsx` files are placed (`NCV`, `SCV`, `CVML`, `California`).
- **`run_pipeline.bat`**: 1-click Windows batch script to execute the data pipeline and commit/push updates to GitHub.
- **`xlsx_to_rds.R`**: Core R script that cleans raw Excel data, creates structured `.rds` files, extracts regional metadata, and archives raw data folders to `data_<Month><Year>/`.
- **`occupation_tables_url_func.R`**: R helper function imported by external Shiny / R applications to fetch the latest `.rds` file directly from GitHub.
- **`demand_files_<Month><Year>.rds`**: Generated output file containing cleaned regional datasets and versioning metadata.
- **`xls_to_xlsx.R`**: Legacy format conversion script retained for reference.

---

## 🚀 How to Process New Data

### Option A: 1-Click Batch Script (Recommended)

1. Place the 4 new raw Lightcast Excel files (`.xlsx`) in the `data/` folder.
2. Double-click **`run_pipeline.bat`** (or execute `./run_pipeline.bat` in terminal).
3. The script will:
   - Run `xlsx_to_rds.R` to process raw files and generate the new `demand_files_<Month><Year>.rds`.
   - Rename `data/` to `data_<Month><Year>` to archive raw files and recreate a fresh `data/` folder.
   - Prompt for an optional Git commit message.
   - Automatically commit and push changes to `GithubRepo master`.

### Option B: Command Line (Rscript)

1. Place raw `.xlsx` files in `data/`.
2. Run:
   ```bash
   Rscript xlsx_to_rds.R
   ```
3. Stage, commit, and push updates:
   ```bash
   git add demand_files_*.rds data_* data/.gitkeep
   git commit -m "feat: update demand files for <Month><Year>"
   git push GithubRepo master
   ```

---

## 🔗 Pulling Data in External Apps

External applications use `occupation_tables_url_func.R` to fetch data dynamically from this repository:

```r
source("https://raw.githubusercontent.com/coeifaria/DemandFiles/master/occupation_tables_url_func.R")

# Fetch latest full dataset list
demand_data <- occupation_tables_url_func()

# Or fetch specific regional dataset directly (e.g., 'cvml', 'n', 's', 'ca')
cvml_df <- occupation_tables_url_func(section = "cvml")
```
