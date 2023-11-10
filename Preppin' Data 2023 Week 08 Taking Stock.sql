-- Preppin' Data 2023 Week 08 Taking Stock https://preppindata.blogspot.com/2023/02/2023-week-8-taking-stock.html

-- Create a 'file date' using the month found in the file name
--     - The Null value should be replaced as 1
-- Clean the Market Cap value to ensure it is the true value as 'Market Capitalisation'
--     - Remove any rows with 'n/a'
-- Categorise the Purchase Price into groupings
    -- 0 to 24,999.99 as 'Low'
    -- 25,000 to 49,999.99 as 'Medium'
    -- 50,000 to 74,999.99 as 'High'
    -- 75,000 to 100,000 as 'Very High'
-- Categorise the Market Cap into groupings
    -- Below $100M as 'Small'
    -- Between $100M and below $1B as 'Medium'
    -- Between $1B and below $100B as 'Large' 
    -- $100B and above as 'Huge'
-- Rank the highest 5 purchases per combination of: file date, Purchase Price Categorisation and Market Capitalisation Categorisation.
-- Output only records with a rank of 1 to 5
WITH CTE AS (
SELECT 1 as file,* FROM pd2023_wk08_01

UNION ALL 

SELECT 2 as file,* FROM pd2023_wk08_02

UNION ALL 

SELECT 3 as file,* FROM pd2023_wk08_03

UNION ALL 

SELECT 4 as file,* FROM pd2023_wk08_04

UNION ALL 

SELECT 5 as file,* FROM pd2023_wk08_05

UNION ALL 

SELECT 6 as file,* FROM pd2023_wk08_06

UNION ALL 

SELECT 7 as file,* FROM pd2023_wk08_07

UNION ALL 

SELECT 8 as file,* FROM pd2023_wk08_08

UNION ALL 

SELECT 9 as file,* FROM pd2023_wk08_09

UNION ALL 

SELECT 10 as file,* FROM pd2023_wk08_10

UNION ALL 

SELECT 11 as file,* FROM pd2023_wk08_11

UNION ALL 

SELECT 12 as file,* FROM pd2023_wk08_12
),
GROUPINGS AS(
SELECT*,
DATE_FROM_PARTS(2023,file,1) as file_date,
CASE
WHEN (SUBSTR(purchase_price,2,LENGTH(purchase_price)))::float < 24999.99 THEN 'LOW'
WHEN (SUBSTR(purchase_price,2,LENGTH(purchase_price)))::float < 49999.99 THEN 'MEDIUM'
WHEN (SUBSTR(purchase_price,2,LENGTH(purchase_price)))::float < 74999.99 THEN 'HIGH'
WHEN (SUBSTR(purchase_price,2,LENGTH(purchase_price)))::float > 75000 THEN 'VERY HIGH'
END AS PP_CATERGORY,
CASE 
WHEN RIGHT(MARKET_CAP,1)='M' THEN (((SUBSTR(market_cap,2,LENGTH(market_cap)-2)):: float)
* 1000000)
WHEN RIGHT (MARKET_CAP,1)='B' THEN (((SUBSTR(market_cap,2,LENGTH(market_cap)-2)):: float)
* 1000000000)
END AS MARKET_CAPITLAISTAION,
(SUBSTR(purchase_price,2,LENGTH(purchase_price))) as INT_PURCHASE_PRICE,
CASE 
WHEN MARKET_CAPITLAISTAION < 100000000 THEN 'SMALL'
WHEN MARKET_CAPITLAISTAION > 100000000 THEN 'MEDIUM'
WHEN MARKET_CAPITLAISTAION  > 1000000000  THEN 'LARGE'
WHEN MARKET_CAPITLAISTAION > 100000000000 THEN 'HUGE'
END AS MC_CATERGORY
FROM CTE
WHERE SECTOR <> 'n/a' and MARKET_CAP <> 'n/a'),

RNK as (
SELECT*,
RANK() OVER(PARTITION BY FILE,PP_CATERGORY,MC_CATERGORY ORDER BY INT_PURCHASE_PRICE DESC) as RNK
FROM GROUPINGS)

SELECT 
PP_CATERGORY AS PURCHASE_PRICE_CATERGORY,
MC_CATERGORY AS MARKET_CAPITALISATION_CATERGORY,
FILE_DATE,
TICKER,
MARKET,
STOCK_NAME,
MARKET_CAP AS MARKET_CAPITALISATION,
PURCHASE_PRICE,
RNK AS RANK
FROM RNK
WHERE rnk <=5;