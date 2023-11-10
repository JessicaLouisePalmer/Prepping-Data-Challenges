--Prepping Data 2023 Week 7 Flagging Fraudulent Suspicions https://preppindata.blogspot.com/2023/02/2023-week-7-flagging-fraudulent.html

-- For the Transaction Path table:
--     - Make sure field naming convention matches the other tables
--         - i.e. instead of Account_From it should be Account From
-- For the Account Information table:
--     - Make sure there are no null values in the Account Holder ID
--     - Ensure there is one row per Account Holder ID
--         - Joint accounts will have 2 Account Holders, we want a row for each of them
-- For the Account Holders table:
--     - Make sure the phone numbers start with 07
-- Bring the tables together
-- Filter out cancelled transactions 
-- Filter to transactions greater than £1,000 in value 
-- Filter out Platinum accounts


WITH ACC as (
SELECT 
ACCOUNT_NUMBER, 
ACCOUNT_TYPE, 
value as ACCOUNT_HOLDER_ID, 
BALANCE_DATE, 
BALANCE
FROM pd2023_wk07_account_information, LATERAL SPLIT_TO_TABLE(account_holder_id,', ')
WHERE account_holder_id IS NOT NULL
),

AH AS(
SELECT ACCOUNT_HOLDER_ID,
       NAME,
       DATE_OF_BIRTH,
       to_varchar(contact_number) as Contact_Number,
       FIRST_LINE_OF_ADDRESS
FROM PD2023_WK07_ACCOUNT_HOLDERS)


SELECT AH.ACCOUNT_HOLDER_ID,
       AH.NAME,
       AH.DATE_OF_BIRTH,
       AH.CONTACT_NUMBER,
       to_varchar(ACC.ACCOUNT_NUMBER) AS ACCOUNT_NUMBER,
       ACC.ACCOUNT_TYPE,
       ACC.BALANCE_DATE,
       ACC.BALANCE,
       P.ACCOUNT_FROM,
       P.ACCOUNT_TO,
       P.TRANSACTION_ID,
       D.TRANSACTION_DATE,
       D.VALUE
FROM AH
INNER JOIN ACC ON ACC.ACCOUNT_HOLDER_ID = AH.ACCOUNT_HOLDER_ID
INNER JOIN PD2023_WK07_TRANSACTION_PATH AS P ON P.ACCOUNT_FROM= ACC.ACCOUNT_NUMBER
INNER JOIN PD2023_WK07_TRANSACTION_DETAIL AS D ON D.TRANSACTION_ID = P.TRANSACTION_ID
WHERE D.CANCELLED_ = 'N'
AND D.VALUE > 1000
AND ACC.ACCOUNT_TYPE <> 'Platinum';
