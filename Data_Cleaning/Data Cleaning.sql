-- ============================================================
-- PROJECT   : Global Layoffs Data Cleaning
-- DATASET   : https://www.kaggle.com/datasets/swaptr/layoffs-2022
-- DATABASE  : world_layoffs
-- PURPOSE   : Clean and standardize raw layoffs data for EDA
-- STEPS     : 1. Remove duplicates
--             2. Standardize data and fix errors
--             3. Handle NULL values
--             4. Remove unnecessary columns and rows


-- INITIAL INSPECTION

SELECT 
    *
FROM
    layoffs;

-- =======================================================
-- STEP 0 : Create a Staging Table
-- =======================================================
-- never want to work on the raw data directly -- always good to have a backup
-- creating a staging table to do all the cleaning work on

create table layoffs_staging
like layoffs;

select *
from layoffs_staging;

insert layoffs_staging
select *
from layoffs;



-- ============================================================
-- Step 1. Remove duplicates
-- ============================================================
-- no unique ID column in this dataset, so using ROW_NUMBER()
-- partitioned across ALL columns to catch true duplicates
-- row_num > 1 means that exact record already appeared earlier


-- 1a. Detect duplicates using all columns in the PARTITION

with duplicate_cte as
(
select *, row_number() over(partition by company, location,industry,total_laid_off,percentage_laid_off,`date`,stage,country,funds_raised_millions)
as row_num
from layoffs_staging
) select * 
from duplicate_cte
where row_num > 1;

-- 1b. creating a second staging table with the row numbers included
--     CTEs don't support DELETE directly in MySQL, so this is the cleanest way to do it
CREATE TABLE `layoffs_staging2` (
  `company` text,
  `location` text,
  `industry` text,
  `total_laid_off` int DEFAULT NULL,
  `percentage_laid_off` text,
  `date` text,
  `stage` text,
  `country` text,
  `funds_raised_millions` int DEFAULT NULL,
  `row_num` int
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

select *
from layoffs_staging2;

-- 1c. populating staging2 with row numbers assigned per duplicate group

insert into layoffs_staging2
select *, row_number() over(partition by company, location,industry,total_laid_off,percentage_laid_off,`date`,stage,country,funds_raised_millions)
as row_num
from layoffs_staging;

-- 1d. deleting duplicates -- keeping only the first occurrence (row_num = 1)

-- check before delete
select *
from layoffs_staging2
where row_num > 1;



delete
from layoffs_staging2
where row_num > 1;


-- check every duplicate records are deleted correctly
select *
from layoffs_staging2
where row_num > 1;

-- ============================================================
-- STEP 2 : Standardize Data
-- ============================================================

select * from layoffs_staging2;

-- --- 2a. Remove extra spaces ---
select company, trim(company)
from layoffs_staging2;

update layoffs_staging2
set company = trim(company);

select  distinct industry
from layoffs_staging2
order by 1;

-- 2b. Consolidate inconsistent industry labels
select industry
from layoffs_staging2
where industry like 'Crypto%';


update layoffs_staging2
set industry = 'Crypto'
where industry like 'Crypto%';

-- 2c. Fix trailing punctuation in country names

select distinct country
from layoffs_staging2
order by 1;


select distinct country, trim(trailing '.' from country)
from layoffs_staging2
order by 1;

update layoffs_staging2
set country = trim(trailing '.' from country)
where country like 'United States%';

select distinct country
from layoffs_staging2
order by 1;

-- 2d. Convert date column from TEXT to proper DATE type 

select `date`, str_to_date(`date`,'%m/%d/%Y')
from layoffs_staging2;

update layoffs_staging2
set `date`= str_to_date(`date`,'%m/%d/%Y');
select `date`
from layoffs_staging2;

alter table layoffs_staging2
modify column `date` date;

select *
from layoffs_staging2;

-- 2e. Fix blank and NULL industry values 
-- some rows have an empty string instead of NULL for industry
-- first converting blanks to NULL so everything is handled the same way,
-- then backfilling from another row of the same company where industry is populated

select *
from layoffs_staging2
where industry is null
or industry = '';

select *
from layoffs_staging2
where company = 'Airbnb';

select t1.company, t1.industry, t2.industry
from layoffs_staging2 t1
join layoffs_staging2 t2
on t1.company = t2.company
where (t1.industry is null or t1.industry = '')
and t2.industry is not null;

-- converting empty strings to NULL
update layoffs_staging2
set industry = null
where industry = '';

-- backfilling NULLs by self-joining on company name
update layoffs_staging2 t1
join layoffs_staging2 t2
on t1.company = t2.company
set t1.industry = t2.industry
where t1.industry is null
and t2.industry is not null;

-- Bally's expected to stay NULL -- no other row to backfill from
SELECT *
FROM world_layoffs.layoffs_staging2
WHERE industry IS NULL 
OR industry = ''
ORDER BY industry;

-- ============================================================
-- STEP 4 : Remove Unusable Rows and Cleanup
-- ============================================================

-- rows missing BOTH total_laid_off and percentage_laid_off have no usable layoff data
select company, total_laid_off, percentage_laid_off
from layoffs_staging2
where total_laid_off is null and percentage_laid_off is null;

-- deleting useless data we can't really use
delete
from layoffs_staging2
where total_laid_off is null and percentage_laid_off is null;

-- dropping the row_num helper column -- no longer needed

alter table layoffs_staging2
drop column  row_num;

-- ============================================================
-- FINAL CHECK
-- ============================================================
 
SELECT * 
FROM world_layoffs.layoffs_staging2;

