-- **Exploratory Data Analysis (EDA): World Layoffs Dataset**

-- **Skills Used:** Window Functions, Aggregate Functions, CTEs, Data Filtering, Trend Analysis, Ranking

-- **Author:** [Emil Makowski]

-- **Date:** [2024-11-28]

-- **Dataset Source:** https://www.kaggle.com/datasets/swaptr/layoffs-2022

-- **Objective:**
-- This project involves analyzing trends, patterns, and outliers in the 'World Layoffs' dataset to gain insights.
-- **Cel:**
-- Projekt obejmuje analizę trendów, wzorców i wartości odstających w danych „Światowe Zwolnienia” w celu uzyskania wniosków.

---------------------------------------------------------------------
-- **Step 1: Initial Exploration**
-- **Krok 1: Wstępna eksploracja**

-- Purpose: Understand the dataset structure and get an overview of the key statistics.
-- Cel: Zrozumienie struktury zestawu danych i uzyskanie ogólnego przeglądu kluczowych statystyk.

SELECT * 
FROM world_layoffs.layoffs_staging2
LIMIT 10;

---------------------------------------------------------------------
-- **Step 2: Identify Key Trends and Outliers**
-- **Krok 2: Identyfikacja kluczowych trendów i wartości odstających**

-- **2.1** Find the company with the largest single-day layoff.
-- **2.1** Znajdź firmę z największym jednorazowym zwolnieniem.

SELECT 
    company, 
    total_laid_off 
FROM 
    world_layoffs.layoffs_staging2
ORDER BY 
    total_laid_off DESC
LIMIT 1;

-- **2.2** Analyze the percentage of workforce laid off to identify extreme cases.
-- **2.2** Analizuj procent zwolnionych pracowników, aby zidentyfikować skrajne przypadki.

SELECT 
    MAX(percentage_laid_off) AS max_percentage,  
    MIN(percentage_laid_off) AS min_percentage
FROM 
    world_layoffs.layoffs_staging2
WHERE  
    percentage_laid_off IS NOT NULL;

-- **2.3** Identify companies where the entire workforce was laid off (100% layoffs).
-- **2.3** Zidentyfikuj firmy, w których zwolniono całą siłę roboczą (100% zwolnień).

SELECT *
FROM 
    world_layoffs.layoffs_staging2
WHERE 
    percentage_laid_off = 1
ORDER BY 
    funds_raised_millions DESC;

-- **Insight:** Many of these cases are startups, including Quibi, which raised billions before going out of business.
-- **Wniosek:** Wiele z tych przypadków to startupy, w tym Quibi, które zebrało miliardy przed zamknięciem.

---------------------------------------------------------------------
-- **Step 3: Grouped Analysis**
-- **Krok 3: Analiza grupowa**

-- **3.1** Companies with the most total layoffs.
-- **3.1** Firmy z największą łączną liczbą zwolnień.

SELECT 
    company, 
    SUM(total_laid_off) AS total_laid_off
FROM 
    world_layoffs.layoffs_staging2
GROUP BY 
    company
ORDER BY 
    total_laid_off DESC
LIMIT 10;

-- **3.2** Locations with the highest layoffs.
-- **3.2** Lokalizacje z największą liczbą zwolnień.

SELECT 
    location, 
    SUM(total_laid_off) AS total_laid_off
FROM 
    world_layoffs.layoffs_staging2
GROUP BY 
    location
ORDER BY 
    total_laid_off DESC
LIMIT 10;

-- **3.3** Annual layoffs trends.
-- **3.3** Trendy roczne zwolnień.

SELECT 
    YEAR(date) AS year, 
    SUM(total_laid_off) AS total_laid_off
FROM 
    world_layoffs.layoffs_staging2
GROUP BY 
    YEAR(date)
ORDER BY 
    year ASC;

-- **3.4** Industries with the highest layoffs.
-- **3.4** Branże z największą liczbą zwolnień.

SELECT 
    industry, 
    SUM(total_laid_off) AS total_laid_off
FROM 
    world_layoffs.layoffs_staging2
GROUP BY 
    industry
ORDER BY 
    total_laid_off DESC
LIMIT 10;

---------------------------------------------------------------------
-- **Step 4: Advanced Analysis**
-- **Krok 4: Zaawansowana analiza**

-- **4.1** Top companies with the most layoffs per year.
-- **4.1** Największe firmy z największą liczbą zwolnień w każdym roku.

WITH Company_Year AS (
    SELECT 
        company, 
        YEAR(date) AS year, 
        SUM(total_laid_off) AS total_laid_off
    FROM 
        world_layoffs.layoffs_staging2
    GROUP BY 
        company, YEAR(date)
),
Company_Year_Rank AS (
    SELECT 
        company, 
        year, 
        total_laid_off, 
        DENSE_RANK() OVER (PARTITION BY year ORDER BY total_laid_off DESC) AS ranking
    FROM 
        Company_Year
)
SELECT 
    company, 
    year, 
    total_laid_off, 
    ranking
FROM 
    Company_Year_Rank
WHERE 
    ranking <= 3
ORDER BY 
    year ASC, total_laid_off DESC;

-- **4.2** Rolling total of layoffs over time.
-- **4.2** Narastająca suma zwolnień w czasie.

WITH MonthlyLayoffs AS (
    SELECT 
        DATE_FORMAT(date, '%Y-%m') AS month, 
        SUM(total_laid_off) AS monthly_laid_off
    FROM 
        world_layoffs.layoffs_staging2
    GROUP BY 
        DATE_FORMAT(date, '%Y-%m')
)
SELECT 
    month, 
    SUM(monthly_laid_off) OVER (ORDER BY month ASC) AS rolling_total
FROM 
    MonthlyLayoffs;

-- **4.3** Highlight companies with layoffs significantly above industry averages.
-- **4.3** Wyróżnij firmy ze zwolnieniami znacznie powyżej średnich branżowych.

WITH IndustryStats AS (
    SELECT 
        industry, 
        AVG(total_laid_off) AS avg_industry_layoffs
    FROM 
        world_layoffs.layoffs_staging2
    GROUP BY 
        industry
)
SELECT 
    l.company, 
    l.industry, 
    l.total_laid_off, 
    i.avg_industry_layoffs, 
    (l.total_laid_off - i.avg_industry_layoffs) AS difference
FROM 
    world_layoffs.layoffs_staging2 l
JOIN 
    IndustryStats i
ON 
    l.industry = i.industry
WHERE 
    l.total_laid_off > i.avg_industry_layoffs * 2
ORDER BY 
    difference DESC;

---------------------------------------------------------------------
-- Notes:
-- Notatki:

-- Exploratory queries were designed to identify key trends, such as industries with the highest layoffs, companies with the most layoffs per year, and rolling totals over time.
-- Zapytania eksploracyjne zostały skonstruowane, aby zidentyfikować kluczowe trendy, takie jak branże z największą liczbą zwolnień, firmy z największą liczbą zwolnień w poszczególnych latach oraz narastające sumy zwolnień w czasie.

-- Extreme cases, such as startups with 100% layoffs or companies exceeding industry averages by a large margin, were highlighted for further analysis.
-- Ekstremalne przypadki, takie jak startupy z 100% zwolnień lub firmy przekraczające średnie branżowe o dużą wartość, zostały uwypuklone do dalszej analizy.

-- Annual and monthly trends were analyzed to identify patterns, such as spikes in layoffs during significant global events.
-- Roczne i miesięczne trendy zostały przeanalizowane, aby zidentyfikować wzorce, takie jak skoki liczby zwolnień podczas ważnych wydarzeń globalnych.

-- Techniques like CTEs, window functions, and ranking were used to enhance analysis precision and provide detailed insights.
-- Wykorzystano techniki takie jak CTE, funkcje okienkowe i rankingi, aby zwiększyć precyzję analizy i dostarczyć szczegółowych wniosków.

-- Insights can support stakeholders in understanding economic trends, identifying vulnerable sectors, and improving decision-making processes.
-- Wnioski mogą wspierać interesariuszy w zrozumieniu trendów gospodarczych, identyfikacji podatnych sektorów oraz usprawnieniu procesów podejmowania decyzji.
---------------------------------------------------------------------
