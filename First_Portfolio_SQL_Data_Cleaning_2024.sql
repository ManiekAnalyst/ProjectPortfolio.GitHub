
-- Data Cleaning Project: World Layoffs Dataset
-- Projekt oczyszczania danych: Światowe dane dotyczące zwolnień

-- Skills Used: Joins, CTE's, Temp Tables, Window Functions, Aggregate Functions, Creating Views, Converting Data Types


-- Author: [Emil Makowski]

-- Date: [2024-11-27]

-- Dataset Source: https://www.kaggle.com/datasets/swaptr/layoffs-2022
-- Źródło danych: https://www.kaggle.com/datasets/swaptr/layoffs-2022

-- Objective: This project involves cleaning the 'World Layoffs' dataset to prepare it for analysis.
-- Cel: Projekt polega na oczyszczeniu zestawu danych „Światowe Zwolnienia” w celu przygotowania go do analizy.

-- Key steps include creating a staging table, deduplicating data, handling null values, and ensuring data consistency.
-- Kluczowe kroki obejmują utworzenie tabeli tymczasowej, usunięcie duplikatów, obsługę wartości null i zapewnienie spójności danych.

--------------------------------------------------------------------------------
-- Step 1: Create a Staging Table
-- Krok 1: Utwórz tabelę tymczasową

-- Purpose: Preserve raw data by creating a duplicate table for data cleaning operations.
-- Cel: Zachowanie danych surowych poprzez utworzenie duplikatu tabeli do operacji czyszczenia danych.

CREATE TABLE world_layoffs.layoffs_staging 
LIKE world_layoffs.layoffs;

INSERT INTO world_layoffs.layoffs_staging
SELECT * FROM world_layoffs.layoffs;

--------------------------------------------------------------------------------
-- Step 2: Deduplication
-- Krok 2: Usuwanie duplikatów

-- Purpose: Remove duplicate records to ensure data quality.
-- Cel: Usuń zduplikowane rekordy w celu zapewnienia jakości danych.

DELETE FROM world_layoffs.layoffs_staging
WHERE id IN (
    SELECT id
    FROM (
        SELECT id, ROW_NUMBER() OVER (PARTITION BY employee_name, date ORDER BY last_modified) AS row_num
        FROM world_layoffs.layoffs_staging
    ) subquery
    WHERE row_num > 1
);

--------------------------------------------------------------------------------
-- Step 3: Handling Null Values
-- Krok 3: Obsługa wartości null

-- Purpose: Replace missing values with meaningful defaults where applicable.
-- Cel: Zamień brakujące wartości na domyślne, tam gdzie to możliwe.

UPDATE world_layoffs.layoffs_staging
SET company = 'Unknown'
WHERE company IS NULL;

UPDATE world_layoffs.layoffs_staging
SET date = '1970-01-01'
WHERE date IS NULL;

--------------------------------------------------------------------------------
-- Step 4: Data Type Validation
-- Krok 4: Walidacja typów danych

-- Purpose: Change the data type to make all columns correct.
-- Cel: Zmień typ danych żeby wszystkie kolumny były poprawne

ALTER TABLE world_layoffs.layoffs_staging
MODIFY COLUMN layoffs_count INT;

--------------------------------------------------------------------------------
-- Notes:
-- Notatki:

-- Deduplication was prioritized to ensure the dataset is free from redundancy, which could skew analytical results.
-- Priorytetem było usunięcie duplikatów, aby upewnić się, że dane nie zawierają nadmiarowych informacji, które mogłyby zniekształcić wyniki analizy.

-- Missing values were replaced with defaults to maintain dataset integrity without introducing null-related errors.
-- Brakujące wartości zostały zastąpione wartościami domyślnymi, aby zachować integralność danych i uniknąć błędów związanych z brakami.

-- Data type adjustments were applied to standardize the dataset and avoid inconsistencies in downstream analysis.
-- Dostosowano typy danych, aby ujednolicić zestaw danych i uniknąć niespójności w kolejnych etapach analizy.


--------------------------------------------------------------------------------
