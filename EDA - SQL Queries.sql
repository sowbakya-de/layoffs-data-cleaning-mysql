-- EDA
SELECT * 
FROM layoffs_staging1;

-- MIN, MAX
SELECT MAX(total_laid_off), MAX(percentage_laid_off)
FROM layoffs_staging1;

SELECT *
FROM layoffs_staging1
WHERE percentage_laid_off = 1
ORDER BY funds_raised_millions DESC;

-- GROUP BY company
SELECT company, SUM(total_laid_off)
FROM layoffs_staging1
GROUP BY company
ORDER BY 2 DESC;

--MIN, MAX
SELECT MIN(`date`), MAX(`date`)
FROM layoffs_staging1;

-- GROUP BY industry
SELECT industry, SUM(total_laid_off)
FROM layoffs_staging1
GROUP BY industry
ORDER BY 2 DESC;
 
-- GROUP BY country
SELECT country, SUM(total_laid_off) 
FROM layoffs_staging1
GROUP BY country
ORDER BY SUM(total_laid_off) DESC;

-- GROUP BY date
SELECT `date`, SUM(total_laid_off)
FROM layoffs_staging1
GROUP BY `date`
ORDER BY `date` DESC;

-- Convert it into Year
SELECT YEAR(`date`), SUM(total_laid_off)
FROM layoffs_staging1
GROUP BY YEAR(`date`)
ORDER BY 1 DESC;

-- GROUP BY stage
SELECT stage, SUM(total_laid_off)
FROM layoffs_staging1
GROUP BY stage
ORDER BY 2 DESC;

SELECT * FROM layoffs_staging1;

SELECT stage, AVG(percentage_laid_off)
FROM layoffs_staging1
GROUP BY stage
ORDER BY 1 ASC;