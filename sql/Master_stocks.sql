-- Sample queries using pandasql on imported datasets (dataframes as tables)

-- Get all data from Infosys
SELECT * FROM infy LIMIT 10;

-- Get closing prices for Wipro
SELECT Date, Close FROM wipro;

-- Calculate average close price for TCS
SELECT AVG(Close) as avg_close FROM tcs;

-- Get correlation between Infosys and TCS closing prices
SELECT CORR(infy.Close, tcs.Close) as correlation FROM infy JOIN tcs ON infy.Date = tcs.Date;

-------------------------------
-- 1. VIEW RAW DATA
-------------------------------

SELECT * FROM infy;
SELECT * FROM tcs;
SELECT * FROM wipro;
SELECT * FROM hcl;

-- Displays raw historical data for all stocks

-------------------------------
-- 2. DATA CLEANING (WHERE FILTER)
-------------------------------
/*
DELETE FROM infy_5y WHERE Date = '';
DELETE FROM tcs_5y WHERE Date = '';
DELETE FROM wipro_5y WHERE Date = '';
DELETE FROM hcl_5y WHERE Date = '';
*/
-- Removes rows where Date is empty (invalid data)
-- In pandasql, cleaning is done on dataframes before querying
-- Example: Remove rows where Date is empty
-- This would be done in Python: df = df[df['Date'] != '']

-------------------------------
-- 3. COMBINING TABLES (UNION)
-------------------------------

-- Create master_stocks view (in notebook, create as dataframe)
SELECT 'INFY' AS Company, Date, Open, High, Low, Close, Volume FROM infy
UNION ALL
SELECT 'TCS' AS Company, Date, Open, High, Low, Close, Volume FROM tcs
UNION ALL
SELECT 'WIPRO' AS Company, Date, Open, High, Low, Close, Volume FROM wipro
UNION ALL
SELECT 'HCL' AS Company, Date, Open, High, Low, Close, Volume FROM hcl;

-- Combines all stock tables into one dataset
-- Adds a Company column to identify each stock

-------------------------------
-- 4. DUPLICATE CHECK (GROUP BY + HAVING)
-------------------------------

SELECT Date, Company, COUNT(*) 
FROM master_stocks 
GROUP BY Date, Company 
HAVING COUNT(*) > 1;

-- Groups data by Date and Company
-- Counts occurrences of each group
-- HAVING filters only duplicates

-------------------------------
-- 5. DAILY RETURN (WINDOW FUNCTION)
-------------------------------

SELECT 
    Company, 
    Date, 
    Close,
    (Close - LAG(Close) OVER (PARTITION BY Company ORDER BY Date)) / 
    LAG(Close) OVER (PARTITION BY Company ORDER BY Date) AS Daily_Return
FROM master_stocks;

-- LAG gets previous day's closing price
-- PARTITION BY separates calculation per company
-- Calculates daily percentage return

-------------------------------
-- 6. 52-WEEK HIGH & LOW (WHERE + GROUP BY)
-------------------------------

SELECT 
    Company, 
    MAX(High) AS Year_High, 
    MIN(Low) AS Year_Low
FROM master_stocks
WHERE Date >= DATE('now', '-1 year')
GROUP BY Company;

-- Filters last 1 year data
-- Finds highest and lowest price per company

-------------------------------
-- 7. VWAP (VOLUME WEIGHTED AVG PRICE)
-------------------------------

SELECT 
    Company,
    SUM(Close * Volume) / SUM(Volume) AS VWAP
FROM master_stocks
GROUP BY Company;

-- Calculates weighted average price using volume
-- More accurate than simple average

-------------------------------
-- 8. AVERAGE CLOSING PRICE (GROUP BY + ORDER BY)
-------------------------------

SELECT 
    Company, 
    AVG(Close) AS average_closing_price
FROM master_stocks
GROUP BY Company
ORDER BY average_closing_price DESC;

-- Computes average closing price per company
-- Orders from highest to lowest

-------------------------------
-- 9. ALL-TIME HIGH & LOW
-------------------------------

SELECT 
    Company, 
    MAX(High) AS all_time_high, 
    MIN(Low) AS all_time_low
FROM master_stocks
GROUP BY Company;

-- Finds maximum and minimum price over entire dataset

-------------------------------
-- 10. TOTAL VOLUME TRADED
-------------------------------

SELECT 
    Company, 
    SUM(Volume) AS total_shares_traded
FROM master_stocks
GROUP BY Company
ORDER BY total_shares_traded DESC;

-- Calculates total trading volume per company
-- Shows most actively traded stock first

-------------------------------
-- 11. VOLATILITY (DAILY SWING)
-------------------------------

SELECT 
    Company, 
    AVG(High - Low) AS average_daily_swing
FROM master_stocks
GROUP BY Company
ORDER BY average_daily_swing DESC;

-- Measures average daily price fluctuation
-- Higher value indicates more volatility