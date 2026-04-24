-- ============================================================
-- PROJECT   : World Layoffs - Exploratory Data Analysis (EDA)
-- DATASET   : https://www.kaggle.com/datasets/swaptr/layoffs-2022
-- DATABASE  : world_layoffs
-- PURPOSE   : Explore the cleaned layoffs data to find trends,
--             patterns, and outliers across companies, industries,
--             locations, and time periods
-- NOTE      : no strict hypothesis here -- just looking around
--             to see what the data tells us
-- ============================================================

-- ============================================================
-- INITIAL INSPECTION
-- ============================================================
select *
from world_layoffs.layoffs_staging2;

-- ======================================================
-- SECTION 1 : Simple Metrics (Easier Queries)
-- ======================================================
-- 1a. Max and Min single-day layoff count & percentage in the dataset

-- select distinct company
-- from layoffs_staging2;

select max(total_laid_off) as max_layoff , min(total_laid_off) as min_layoff
from layoffs_staging2;

--  b. Range of percentage_laid_off across all companies
-- checking the spread to understand how severe layoffs were

select max(percentage_laid_off) as max_laidoff_percentage , min(percentage_laid_off) as min_laidoff_percentage
from layoffs_staging2

-- 1c. Companies that laid off 100% of their workforce
-- percentage_laid_off = 1 means the entire company was shut down

SELECT *
FROM layoffs_staging2
WHERE percentage_laid_off = 1;

-- ordering by funds_raised_millions to see how large some of these companies were
-- mostly startups that went out of business during this period

SELECT *
FROM layoffs_staging2
WHERE percentage_laid_off = 1
order by funds_raised_millions desc;

-- ============================================================
-- SECTION 2 : Group By Queries
-- ============================================================
 
-- 2a. Companies with the biggest single-day layoff ---
-- this is just one day, not their total across the dataset

select company , total_laid_off
from layoffs_staging2
order by 2 desc;

-- 2b. Companies with the most total layoffs overall
select company , sum(total_laid_off) as Total_Laidoff
from layoffs_staging2
group by company
order by 2 desc;

-- 2c. Total layoffs by industry

select industry,sum(total_laid_off) as Total_Laidoff_by_Ind
from layoffs_staging2
group by industry
order by 2 desc;

-- 2d. Total layoffs by country

select country,sum(total_laid_off) as Total_Laidoff_by_Country
from layoffs_staging2
group by country
order by 2 desc;

-- 2e. Total layoffs by year
select year(`date`),sum(total_laid_off) as Total_Laidoff_by_Year
from layoffs_staging2
group by year(`date`)
order by 1 desc;

-- 2f. Total layoffs by company stage
select stage,sum(total_laid_off) as Total_Laidoff_by_Year
from layoffs_staging2
group by stage
order by 2 desc;

-- ========================================================
-- SECTION 3 : Advanced Queries (CTEs & Window Functions)
-- ========================================================

-- 3a. Rolling total of layoffs per month 
-- first get the each year's monthly totals
select substring(`date`,1,7) as `Month`, sum(total_laid_off)
from layoffs_staging2
where substring(`date`,1,7) is not null
group by `Month`
order by 1 asc;

-- then use a CTE to build a running total on top of the monthly totals
with monthly_rolling_total as
(
select substring(`date`,1,7) as `Month`, sum(total_laid_off) as monthly_laid_off
from layoffs_staging2
where substring(`date`,1,7) is not null
group by `Month`
)
select `Month` , monthly_laid_off , 
sum(monthly_laid_off)
over( order by `Month` asc) as   rolling_total_layoffs
from monthly_rolling_total;


-- 3b. Top 5 companies with the most layoffs per year
-- using DENSE_RANK() partitioned by year to rank companies within each year


select company , year(`date`) , sum(total_laid_off) as Total_Laidoff
from layoffs_staging2
group by company , year(`date`)
order by 3 desc;

with company_year (company , years,total_laid_off) as
(
select company , year(`date`) , sum(total_laid_off)
from layoffs_staging2
group by company , year(`date`)
), 
year_ranking as
(
select * , dense_rank() over(partition by years  order by total_laid_off desc) as ranking
from company_year
where years is not null
)
select *
from year_ranking
where ranking <=5;