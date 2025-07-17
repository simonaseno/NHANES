# NHANES Scripted Data Downloader

This repository contains reproducible R scripts to download, rename, and combine **NHANES** (National Health and Nutrition Examination Survey) datasets across multiple survey cycles from **1999 to 2018**. The focus is on two key data categories:

- **Complete Blood Count (CBC) datasets**
- **Demographics (DEMO) datasets**

These scripts automate the data retrieval process and structure outputs for immediate use in public health research, teaching, or modeling workflows.

## Project Overview

- **Language:** R  
- **R Version:** 4.0 or later  
- **License:** MIT  
- **Estimated Output Size:**  
  - Combined CBC Data: ~20–30 MB (.rds), ~60–80 MB (.csv)  
  - Combined DEMO Data: ~10–15 MB (.rds), ~30–50 MB (.csv)  
- **Last Updated:** July 2025

## Repository Contents

```

nhanes\_project/
├── nhanes\_data/                        # Downloaded CBC datasets
├── nhanes\_demo/                        # Downloaded DEMO datasets
├── cbc\_downloader.R                    # Script to process CBC datasets
├── demo\_downloader.R                   # Script to process DEMO datasets
├── cbc\_data\_combined\_1999\_2018.rds     # Final combined CBC file (.rds)
├── demo\_data\_combined\_1999\_2018.rds    # Final combined DEMO file (.rds)
├── cbc\_data\_combined\_1999\_2018.csv     # Final combined CBC file (.csv)
├── demo\_data\_combined\_1999\_2018.csv    # Final combined DEMO file (.csv)
├── README.md                           # Project documentation

````

## Setup Instructions

### 1. Install Required Packages

```r
install.packages(c("httr", "haven", "dplyr"))
````

### 2. Run the Download Scripts

* To download and process **CBC datasets**, run:

  ```r
  source("cbc_downloader.R")
  ```

* To download and process **DEMO datasets**, run:

  ```r
  source("demo_downloader.R")
  ```

## Applications

This project supports a range of use cases, including:

* Exploratory data analysis on health indicators
* Teaching data wrangling and preprocessing in R
* Building longitudinal models across NHANES cycles
* Prepping structured inputs for machine learning tasks
* Supporting grant proposals with ready-to-use national health data

## Data Source

All data are retrieved from the official NHANES public access portal:
[https://wwwn.cdc.gov/nchs/nhanes/](https://wwwn.cdc.gov/nchs/nhanes/)

## License

This project is released under the MIT License.
You are free to use, modify, and distribute this code with appropriate attribution.

## Author

**Simon Aseno**
Public Health & Data Science Consultant
GitHub: [github.com/simonaseno](https://github.com/simonaseno)
Medium: [medium.com/@sbaseno](https://medium.com/@sbaseno)


---

*This repository is part of a broader initiative to improve public access to health data and empower researchers, educators, and policymakers with clean and reproducible tools.*

