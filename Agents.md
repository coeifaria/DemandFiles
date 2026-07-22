# DemandFiles Agent Context

The Data Vista demand files have been updated for 2026.

## Automated Workflow
- Raw Lightcast occupation tables are uploaded to `data/` (`NCV`, `SCV`, `CVML`, `California`).
- `run_pipeline.bat` (or `Rscript xlsx_to_rds.R`) processes raw files into `demand_files_<Month><Year>.rds` and renames `data/` to `data_<Month><Year>`.
- Changes are pushed to `GithubRepo master`.
- External apps retrieve datasets dynamically via `occupation_tables_url_func.R`.
