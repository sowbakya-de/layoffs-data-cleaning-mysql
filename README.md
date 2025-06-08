# 📉 Layoffs Data Cleaning using MySQL

Data Cleaning project using **MySQL** on a global **layoffs dataset**.  
The project follows the tutorial by [Alex The Analyst] covering **data cleaning** step by step.

---

## 📁 Dataset

- Source: [Kaggle - Layoffs dataset](https://www.kaggle.com/datasets/swaptr/layoffs-2022)
- Columns include:  
  `company`, `location`, `industry`, `total_laid_off`, `percentage_laid_off`, `date`, `stage`, `country`, `funds_raised_million`, `row_num`

---

🙌 Credits
Dataset by  Swapnil Tripathi on Kaggle

Tutorial by Alex The Analyst

---

## 🧰 Tools Used

- MySQL (Workbench)
- GitHub

---

## 🔧 Project Structure

layoffs-Raw Data.csv

├── README.md → Project Overview
├── Data Cleaning - SQL Queries.sql → SQL queries for data cleaning
└── Data Cleaning - SQL Final Output.csv → Cleaned data

---

## 🔎 Key SQL Operations
### ✅ Data Cleaning

```sql
USE world_layoffs;
SELECT * FROM layoffs;

-- 1. Remove Duplicates
-- 2. Standardize the data
-- 3. Null values or Blank values
-- 4. Remove any columns

CREATE TABLE layoffs_staging
LIKE Layoffs;

SELECT * FROM layoffs_staging;

INSERT INTO layoffs_staging
SELECT * FROM layoffs;

-- Insert Row Number & Used CTE to filter

SELECT *,
ROW_NUMBER() OVER(PARTITION BY company, location, industry, total_laid_off, percentage_laid_off, `date`, stage, country, funds_raised_millions
) AS row_num
FROM layoffs_staging;

WITH duplicate_cte AS (
SELECT *,
ROW_NUMBER() OVER(PARTITION BY company, location, industry, total_laid_off, percentage_laid_off, `date`, stage, country, funds_raised_millions
) AS row_num
FROM layoffs_staging
)
SELECT * FROM duplicate_cte
WHERE row_num > 1;

--
SELECT * FROM layoffs_staging
WHERE company = 'Casper';

-- Copy to Clipboard >> CREATE STATEMENT
CREATE TABLE `layoffs_staging1` (
  `company` text,
  `location` text,
  `industry` text,
  `total_laid_off` int DEFAULT NULL,
  `percentage_laid_off` text,
  `date` text,
  `stage` text,
  `country` text,
  `funds_raised_millions` int DEFAULT NULL,
  `row_num` INT
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_0900_ai_ci;

SELECT * FROM layoffs_staging1;

INSERT INTO layoffs_staging1
SELECT *,
ROW_NUMBER() OVER(PARTITION BY company, location, industry, total_laid_off, percentage_laid_off, `date`, stage, country, funds_raised_millions
) AS row_num
FROM layoffs_staging;

SELECT * FROM layoffs_staging1
WHERE row_num > 1;

DELETE 
FROM layoffs_staging1
WHERE row_num > 1;
 
-- 2. Standardize
-- TRIM
-- company
SELECT * FROM layoffs_staging1;

SELECT company, TRIM(company)
FROM layoffs_staging1;

UPDATE layoffs_staging1
SET company = TRIM(company);

-- industry 
SELECT industry FROM layoffs_staging1;

SELECT DISTINCT(industry)
FROM layoffs_staging1
WHERE industry LIKE 'Crypto%';

UPDATE layoffs_staging1
SET industry = 'Crypto'
WHERE industry LIKE 'Crypto%';

SELECT country FROM layoffs_staging1
WHERE country LIKE 'United States%';

-- Trailing - coming at the end

SELECT DISTINCT(country), TRIM(TRAILING '.' FROM country)
FROM layoffs_staging1;

UPDATE layoffs_staging1
SET country = TRIM(TRAILING '.' FROM country)
WHERE country LIKE 'United States%';

SELECT * FROM layoffs_staging1;

-- date
SELECT `date`, 
STR_TO_DATE (`date`, '%m/%d/%Y')
FROM layoffs_staging1;

UPDATE layoffs_staging1
SET `date` = STR_TO_DATE (`date`, '%m/%d/%Y');

ALTER TABLE layoffs_staging1
MODIFY `date` DATE;

-- 3. Remove NULL, Blank value
SELECT * FROM layoffs_staging1
WHERE total_laid_off IS NULL AND percentage_laid_off IS NULL;

UPDATE layoffs_staging1
SET industry = NULL
WHERE industry = '';

SELECT * FROM layoffs_staging1
WHERE industry IS NULL OR industry = '';

SELECT * FROM layoffs_staging1
WHERE company = 'Airbnb';

-- Self Join
SELECT *
FROM layoffs_staging1 t1
JOIN layoffs_staging1 t2
ON t1.company = t2.company
WHERE (t1.industry IS NULL OR t1.industry = '')
 AND t2.industry IS NOT NULL;
 
 
SELECT t1.industry, t2.industry
FROM layoffs_staging1 t1
JOIN layoffs_staging1 t2
ON t1.company = t2.company
WHERE t1.industry IS NULL
 AND t2.industry IS NOT NULL;
 
 
UPDATE layoffs_staging1 t1
JOIN layoffs_staging1 t2
ON t1.company = t2.company
SET t1.industry = t2.industry
WHERE t1.industry IS NULL
 AND t2.industry IS NOT NULL;

-- Substring
SELECT * FROM layoffs_staging1;

SELECT substring(`date`,1,7) AS `Month`, SUM(total_laid_off)
FROM layoffs_staging1
WHERE substring(`date`,1,7) IS NOT NULL
GROUP BY `Month`
ORDER BY `Month`;

-- Rolling Total
WITH Rolling_Total AS
(
SELECT substring(`date`,1,7) AS `Month`, SUM(total_laid_off) AS total_off
FROM layoffs_staging1
WHERE substring(`date`,1,7) IS NOT NULL
GROUP BY `Month`
ORDER BY `Month`
) 
SELECT `Month`, total_off, SUM(total_off)
OVER (ORDER BY `Month`) AS rolling_total
FROM Rolling_Total;

--
SELECT company, YEAR(`date`), SUM(total_laid_off)
FROM layoffs_staging1
GROUP BY company, YEAR(`date`)
ORDER BY 3 desc;

-- RANK

WITH company_year
(company, years, total_laid_off) AS
(
SELECT company, YEAR(`date`), SUM(total_laid_off)
FROM layoffs_staging1
GROUP BY company, YEAR(`date`)
), company_year_rank AS
(
SELECT *, DENSE_RANK() OVER (PARTITION BY years ORDER BY total_laid_off DESC) AS Ranking
FROM company_year
WHERE years IS NOT NULL
)
SELECT * FROM company_year_rank
WHERE Ranking <=5;

--
