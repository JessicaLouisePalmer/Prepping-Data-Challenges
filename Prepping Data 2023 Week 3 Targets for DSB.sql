--Preppin' Data 2023 Week 03 https://preppindata.blogspot.com/2023/01/2023-week-3-targets-for-dsb.html

-- For the transactions file:
    -- Filter the transactions to just look at DSB (help)
        -- These will be transactions that contain DSB in the Transaction Code field
    -- Rename the values in the Online or In-person field, Online of the 1 values and In-Person for the 2 values
    -- Change the date to be the quarter (help)
    -- Sum the transaction values for each quarter and for each Type of Transaction (Online or In-Person) (help)
-- For the targets file:
    -- Pivot the quarterly targets so we have a row for each Type of Transaction and each Quarter (help)
    -- Rename the fields
    -- Remove the 'Q' from the quarter field and make the data type numeric (help)
-- Join the two datasets together (help)
    -- You may need more than one join clause!
-- Remove unnecessary fields
-- Calculate the Variance to Target for each row 





WITH CTE AS(
SELECT CASE WHEN ONLINE_OR_IN_PERSON=1 THEN 'Online'
              WHEN ONLINE_OR_IN_PERSON=2 THEN 'In-Person'
              END as Online_InPerson,
             QUARTER( TO_DATE(LEFT(TRANSACTION_DATE,10), 'dd/mm/yyyy')) as quarter_date, 
             SUM(VALUE) as Total_Value
            FROM PD2023_WK01
            WHERE TRANSACTION_CODE LIKE 'DSB%'
            GROUP BY Online_InPerson,quarter_date)
            
SELECT V.Online_InPerson, V.quarter_date as quarter, V.Total_Value as Value, T.Target as Quarterly_Target, (SUM(V.Total_Value)-SUM(T.Target)) as Variance_To_Target
FROM PD2023_WK03_TARGETS as T
UNPIVOT (target for quarter_date IN (Q1,Q2,Q3,Q4))
INNER JOIN CTE AS V ON  V.Online_InPerson= T.ONLINE_OR_IN_PERSON AND REPLACE(T.quarter_date,'Q','')::int = V.quarter_date
GROUP BY V.Online_InPerson, V.quarter_date, V.Total_Value, T.Target;