--Preping Data 2023 Week 5  DSB Ranking https://preppindata.blogspot.com/2023/02/2023-week-5-dsb-ranking.html

--Input data
--Create the bank code by splitting out off the letters from the Transaction code, call this field 'Bank'
--Change transaction date to the just be the month of the transaction
--Total up the transaction values so you have one row for each bank and month combination
--Rank each bank for their value of transactions each month against the other banks. 1st is the highest value of transactions, 3rd the lowest. 
--Without losing all of the other data fields, find:
--The average rank a bank has across all of the months, call this field 'Avg Rank per Bank'
--The average transaction value per rank, call this field 'Avg Transaction Value per Rank'
--Output the data

WITH CTE AS(
SELECT SPLIT_PART(TRANSACTION_CODE,'-',1) as BANK, 
       MONTHNAME(DATE(transaction_date,'dd/MM/yyyy hh24:mi:ss')) as month,
       SUM(VALUE) as Transaction_value,
       RANK() OVER(PARTITION BY month ORDER BY Transaction_value ASC) as RNK
FROM pd2023_wk01
GROUP BY SPLIT_PART(TRANSACTION_CODE,'-',1),MONTHNAME(DATE(transaction_date,'dd/MM/yyyy hh24:mi:ss'))),

AVERAGE_VALUE AS(
SELECT RNK,
ROUND(AVG(Transaction_value),2) as Avg_Transaction_Value_per_Rank
FROM CTE
GROUP BY RNK),


AVERAGE_RANK AS(
SELECT BANK,
ROUND(AVG(RNK),2) as Avg_Rank_per_Bank
FROM CTE
GROUP BY BANK)

SELECT CTE.BANK, CTE.MONTH, CTE.TRANSACTION_VALUE,CTE.RNK as Bank_Rank_Per_Month,
Avg_Rank_per_Bank,
Avg_Transaction_Value_per_Rank
FROM CTE
INNER JOIN AVERAGE_RANK AS AR ON AR.BANK=CTE.BANK
INNER JOIN AVERAGE_VALUE AS AV ON AV.RNK=CTE.RNK;
