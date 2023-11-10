--From Challenge from https://preppindata.blogspot.com/2023/01/2023-week-1-data-source-bank.html


--1. Total Values of Transactions by each bank
SELECT SPLIT_PART(TRANSACTION_CODE,'-',1) as Bank, SUM(Value) as Value
FROM PD2023_WK01
GROUP BY Bank;

--2. Total Values by Bank, Day of the Week and Type of Transaction (Online or In-Person)
SELECT SPLIT_PART(TRANSACTION_CODE,'-',1) as Bank, 
       CASE WHEN ONLINE_OR_IN_PERSON=1 THEN 'Online'
            WHEN ONLINE_OR_IN_PERSON=2 THEN 'In-Person'
            END as Online_OR_InPerson,
           DAYNAME(TO_DATE(LEFT(TRANSACTION_DATE,10),'dd/mm/yyyy')) as Weekday,
           SUM(Value) as Value
FROM PD2023_WK01
GROUP BY Bank,Online_OR_InPerson,Weekday ;

--. Total Values by Bank and Customer Code
SELECT SPLIT_PART(TRANSACTION_CODE,'-',1) as Bank, 
      CUSTOMER_CODE,
      SUM(Value) as Value
FROM PD2023_WK01
GROUP BY Bank,CUSTOMER_CODE;

