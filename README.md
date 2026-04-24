# 🌍 Global Layoffs Data Analysis using MySQL

**(Data Cleaning + Exploratory Data Analysis Project)**

---

## 📌 Project Overview

This project focuses on analyzing global layoffs data using **MySQL**, covering the full pipeline from **raw data cleaning to extracting meaningful business insights**.

The dataset contains information about layoffs across companies, industries, countries, and time periods. The goal is to transform messy data into a structured format and uncover trends that explain how layoffs evolved globally.

---

## 🎯 Objectives

* Clean and prepare raw data for analysis
* Remove duplicates and handle missing values
* Standardize inconsistent data fields
* Perform exploratory data analysis (EDA)
* Identify trends, patterns, and key insights
* Apply advanced SQL techniques like **CTEs and Window Functions**

---

## 🗂️ Project Structure

```
global-layoffs-sql-analysis/
│
├── data-cleaning/
│   └── data_cleaning.sql
│
├── eda/
│   └── eda.sql
│
├── layoffs.csv
│
└── README.md
```

---

## 🧹 Data Cleaning Process

The raw dataset required several preprocessing steps:

### ✔️ 1. Removed Duplicates

* Used `ROW_NUMBER()` with `PARTITION BY`
* Identified and removed duplicate records

### ✔️ 2. Standardized Data

* Unified inconsistent values (e.g., "Crypto", "Crypto Currency")
* Cleaned country names (removed trailing characters like `.`)
* Converted date format using `STR_TO_DATE()`

### ✔️ 3. Handled Missing Values

* Replaced empty strings with `NULL`
* Filled missing industry values using self-joins
* Removed rows with insufficient data

### ✔️ 4. Data Type Fixes

* Converted date column from TEXT → DATE
* Ensured proper structure for analysis

---

## 📊 Exploratory Data Analysis (EDA)

After cleaning the dataset, structured SQL queries were used to explore trends and patterns.

### ✨ Code Quality & Structure

All SQL queries in this project are written in a **clean, structured, and readable format** with:

* Clear section-wise organization
* Meaningful query grouping (Basic → Aggregation → Advanced)
* Inline comments explaining the purpose of each query
* Consistent naming conventions for better understanding

👉 Example from the EDA script:

```
-- ============================================================
-- SECTION 3 : Advanced Queries (CTEs & Window Functions)
-- ========================================================

-- Rolling total of layoffs per month
-- first calculate monthly totals
-- then apply a window function to compute cumulative layoffs

WITH monthly_rolling_total AS
(
    SELECT 
        SUBSTRING(`date`,1,7) AS Month,
        SUM(total_laid_off) AS monthly_laid_off
    FROM layoffs_staging2
    GROUP BY Month
)
SELECT 
    Month,
    monthly_laid_off,
    SUM(monthly_laid_off) OVER (ORDER BY Month ASC) AS rolling_total_layoffs
FROM monthly_rolling_total;
```

---

## 📊 Analysis Performed

### 🔹 Basic Insights

* Maximum and minimum layoffs in a single event
* Range of layoff percentages
* Companies with 100% layoffs (shutdown cases)

---

### 🔹 Aggregation Analysis

* Top companies by total layoffs
* Layoffs by country and location
* Industry-wise layoffs impact
* Layoffs by company stage (startup, IPO, etc.)
* Year-wise layoffs trends

---

### 🔹 Advanced Analysis

#### 📌 Rolling Total Analysis

* Calculated cumulative layoffs over time (monthly basis)
* Used **CTE + Window Function (`SUM() OVER()`)**
* Helped visualize how layoffs increased over time

#### 📌 Top Companies by Year

* Used **CTEs + `DENSE_RANK()`**
* Ranked companies within each year
* Extracted top 5 companies with highest layoffs per year

---

## 🔧 SQL Concepts Used

* Data Cleaning Techniques
* Aggregate Functions (`SUM`, `MAX`, `MIN`)
* `GROUP BY` & `ORDER BY`
* CTEs (Common Table Expressions)
* Window Functions

  * `ROW_NUMBER()`
  * `DENSE_RANK()`
  * `SUM() OVER()`
* String Functions (`SUBSTRING`, `TRIM`)
* Date Functions (`YEAR`, `STR_TO_DATE`)

---

## 📈 Key Insights

* Several companies experienced **100% layoffs**, indicating shutdowns
* Layoffs were highly concentrated in industries like **Tech and Crypto**
* Some highly funded companies still failed, showing market volatility
* Layoff trends varied significantly across years and regions
* A noticeable increase in layoffs occurred during specific time periods

---

## 🚀 What I Learned

* Real-world data requires extensive cleaning before analysis
* Writing structured SQL queries improves readability and debugging
* Window functions are essential for advanced analytics
* CTEs help break complex logic into manageable steps
* SQL alone can be powerful for both transformation and analysis

---

## 📌 Future Improvements

* Build dashboards using Power BI or Tableau
* Add visualizations for trends and comparisons
* Perform deeper statistical analysis
* Integrate Python for advanced data processing

---

## 🤝 Connect With Me

Feel free to reach out for feedback, suggestions, or collaboration.

---

## ⭐ If you found this project useful

Consider giving it a star ⭐ on GitHub!
