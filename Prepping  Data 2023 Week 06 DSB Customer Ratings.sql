-- Preppin' Data 2023 Week 06 https://preppindata.blogspot.com/2023/02/2023-week-6-dsb-customer-ratings.html

-- Reshape the data so we have 5 rows for each customer, with responses for the Mobile App and Online Interface being in separate fields on the same row
-- Clean the question categories so they don't have the platform in from of them
--     - e.g. Mobile App - Ease of Use should be simply Ease of Use
-- Exclude the Overall Ratings, these were incorrectly calculated by the system
-- Calculate the Average Ratings for each platform for each customer 
-- Calculate the difference in Average Rating between Mobile App and Online Interface for each customer
-- Catergorise customers as being:
--     - Mobile App Superfans if the difference is greater than or equal to 2 in the Mobile App's favour
--     - Mobile App Fans if difference >= 1
--     - Online Interface Fan
--     - Online Interface Superfan
--     - Neutral if difference is between 0 and 1
-- Calculate the Percent of Total customers in each category, rounded to 1 decimal place

WITH CTE AS(
SELECT *
FROM pd2023_wk06_dsb_customer_survey
UNPIVOT (
value FOR pivot_columns IN (
MOBILE_APP___EASE_OF_USE, MOBILE_APP___EASE_OF_ACCESS, MOBILE_APP___NAVIGATION, MOBILE_APP___LIKELIHOOD_TO_RECOMMEND, MOBILE_APP___OVERALL_RATING, ONLINE_INTERFACE___EASE_OF_USE, ONLINE_INTERFACE___EASE_OF_ACCESS, ONLINE_INTERFACE___NAVIGATION, ONLINE_INTERFACE___LIKELIHOOD_TO_RECOMMEND, ONLINE_INTERFACE___OVERALL_RATING
)) as pvt),

PP AS(
SELECT CUSTOMER_ID,
       SPLIT_PART(PIVOT_COLUMNS,'___',1) AS DEVICE,
       SPLIT_PART(PIVOT_COLUMNS,'___',2) AS FACTOR,
       VALUE
FROM CTE),

PT AS(

SELECT*
FROM PP
PIVOT
(SUM(VALUE)
FOR DEVICE IN ('MOBILE_APP','ONLINE_INTERFACE')) as PP
WHERE FACTOR <> 'OVERALL_RATING'),

DP AS(
SELECT
CUSTOMER_ID,
ROUND(AVG("'MOBILE_APP'"),2) AS AVG_MOBILE,
ROUND(AVG("'ONLINE_INTERFACE'"),2) AS AVG_ONLINE,
(AVG_MOBILE)-(AVG_ONLINE) AS DIFFERENCE,
CASE
WHEN DIFFERENCE >= 2 THEN 'Mobile App Superfan'
WHEN DIFFERENCE >=1 AND DIFFERENCE < 2 THEN 'Mobile App Fans'
WHEN DIFFERENCE >=0 AND DIFFERENCE < 1 THEN 'Netrual'
WHEN DIFFERENCE < 0 AND DIFFERENCE >=-1 THEN 'Netrual'
WHEN DIFFERENCE <-1 AND DIFFERENCE >-2 THEN 'Online Interface Fan'
WHEN DIFFERENCE <=-2 THEN 'Online Interface Superfan'
END as Preference
FROM PT
GROUP BY CUSTOMER_ID)

SELECT
ROUND(((COUNT (DISTINCT CUSTOMER_ID)/ 
(SELECT COUNT (DISTINCT CUSTOMER_ID)
FROM CTE))*100),2) as PERCENT_OF_CUSTOMERS,
       PREFERENCE
FROM DP 
GROUP BY PREFERENCE;
