-- ----------------------------------------------
-- Data Exploration and Cleaning (Optional)
-- ----------------------------------------------

-- 1. Check for Missing Values in Important Columns
-- Checking if any critical columns like 'loan_amount', 'issue_date', or 'int_rate' have NULL values

SELECT COUNT(*) AS Missing_Values
FROM Bank_Loan_Data
WHERE loan_amount IS NULL OR issue_date IS NULL OR int_rate IS NULL;

-- 2. Handle Missing Values (if any)
-- For example, filling missing loan_amount with 0 if NULL
UPDATE Bank_Loan_Data
SET loan_amount = 0
WHERE loan_amount IS NULL;

-- 3. Remove Duplicate Entries Based on 'id'
-- Check for duplicate loan applications
SELECT id, COUNT(*) AS Duplicate_Count
FROM Bank_Loan_Data
GROUP BY id
HAVING COUNT(*) > 1;

-- Remove duplicates, keeping only the first occurrence
WITH CTE AS (
    SELECT id, ROW_NUMBER() OVER (PARTITION BY id ORDER BY issue_date) AS RowNum
    FROM Bank_Loan_Data
)
DELETE FROM CTE WHERE RowNum > 1;

-- 4. Validate Data Types (Ensure loan_amount is numeric and issue_date is a valid date)
-- Check for non-numeric loan_amount values
SELECT id, loan_amount
FROM Bank_Loan_Data
WHERE TRY_CAST(loan_amount AS DECIMAL(10, 2)) IS NULL;

-- Check if issue_date is valid
SELECT id, issue_date
FROM Bank_Loan_Data
WHERE TRY_CAST(issue_date AS DATE) IS NULL;

-- 5. Handle Outliers (e.g., loan_amount < 100 or > 1,000,000; int_rate < 0.01 or > 0.30)
-- Check for extreme loan amounts (outliers)
SELECT id, loan_amount
FROM Bank_Loan_Data
WHERE loan_amount < 100 OR loan_amount > 1000000;

-- Check for extreme interest rates (outliers)
SELECT id, int_rate
FROM Bank_Loan_Data
WHERE int_rate < 0.01 OR int_rate > 0.30;

-- ----------------------------------------------
-- Data Analysis Queries (Requirements)
-- ----------------------------------------------

-- Total Applications
SELECT COUNT(id) AS Total_Applications FROM Bank_Loan_Data;

-- MTD Total Applications (December 2021)
SELECT COUNT(id) AS MTD_Total_Applications 
FROM Bank_Loan_Data
WHERE MONTH(issue_date) = 12 AND YEAR(issue_date) = 2021;

-- Total Funded Amount
SELECT SUM(loan_amount) AS Total_Funded_Amount FROM Bank_Loan_Data;

-- MTD Total Funded Amount (December 2021)
SELECT SUM(loan_amount) AS Total_Funded_Amount 
FROM Bank_Loan_Data
WHERE MONTH(issue_date) = 12 AND YEAR(issue_date) = 2021;

-- Total Amount Received
SELECT SUM(total_payment) AS Total_Amount_Received FROM Bank_Loan_Data;

-- MTD Total Amount Received (December 2021)
SELECT SUM(total_payment) AS MTD_Total_Amount_Received 
FROM Bank_Loan_Data
WHERE MONTH(issue_date) = 12 AND YEAR(issue_date) = 2021;

-- Average Interest Rate
SELECT CONCAT(ROUND(AVG(int_rate) * 100, 2), ' %') AS Avg_Interest_Rate 
FROM Bank_Loan_Data;

-- MTD Average Interest Rate (December 2021)
SELECT CONCAT(ROUND(AVG(int_rate) * 100, 2), ' %') AS MTD_Avg_Interest_Rate 
FROM Bank_Loan_Data
WHERE MONTH(issue_date) = 12 AND YEAR(issue_date) = 2021;

-- ----------------------------------------------
--DASHBOARD - 1(Summary)
-- ----------------------------------------------

--Good Loan Measures
-- ---------------------------------------------- 

-- Good Loan Percentage (Fully Paid or Current)
SELECT CONCAT(ROUND(
    (COUNT(CASE WHEN loan_status = 'Fully Paid' OR loan_status = 'Current' THEN id END) * 100) 
    / COUNT(id), 2), ' %') AS Good_Loan 
FROM Bank_Loan_Data;

--Good Loan Application
SELECT COUNT(id) as Good_Loan_Applications FROM Bank_Loan_Data
WHERE loan_status = 'Fully Paid' OR loan_status = 'Current'

--Good Loan Funded Amount
SELECT SUM(loan_amount) as Good_Loan_Funded_Amount FROM Bank_Loan_Data
WHERE loan_status = 'Fully Paid' OR loan_status = 'Current'

--Good Loan Amount Recieved 
SELECT SUM(total_payment) as Good_Loan_Amount_recieved FROM Bank_Loan_Data
WHERE loan_status = 'Fully Paid' OR loan_status = 'Current'


--Bad Loan Measures
-- ----------------------------------------------

--Bad Loan Percentage (Charged Off)
SELECT CONCAT(ROUND(
    (COUNT(CASE WHEN loan_status = 'Charged Off' THEN id END) * 100) 
    / COUNT(id), 2), ' %') AS Bad_Loan 
FROM Bank_Loan_Data;

--Bad Loan Application
SELECT COUNT(id) as Bad_Loan_Applications FROM Bank_Loan_Data
WHERE loan_status = 'Charged Off'

--Bad Loan Funded Amount
SELECT SUM(loan_amount) as Bad_Loan_Funded_Amount FROM Bank_Loan_Data
WHERE loan_status = 'Charged Off'

--Bad Loan Amount Recieved 
SELECT SUM(total_payment) as Bad_Loan_Amount_recieved FROM Bank_Loan_Data
WHERE loan_status = 'Charged Off'


-- Loan Status-1: Breakdown by loan status (applications, funded amount, received amount, interest rate, and DTI)
SELECT 
    loan_status,
    COUNT(id) AS Total_Loan_Applications,
    SUM(total_payment) AS Total_Amount_Received,
    SUM(loan_amount) AS Total_Funded_Amount,
    AVG(int_rate * 100) AS Interest_Rate,
    AVG(dti * 100) AS DTI
FROM bank_loan_data
GROUP BY loan_status;

----Loan status-2 (MTD Measures for applications, funded amount, received amount, interest rate, and DTI)
SELECT
loan_status,
SUM(total_payment) AS MTD_Total_Amount_Recived,
SUM(loan_amount) AS MTD_Total_Funded_Amount
FROM Bank_Loan_Data
WHERE MONTH(issue_date)=12
GROUP BY loan_status

-- ----------------------------------------------
--DASHBOARD -2 (Overview)
-- ----------------------------------------------

-- Monthly Trends for KPIs
SELECT 
    MONTH(issue_date) AS Month_Number,
    DATENAME(MONTH, issue_date) AS Month_Name,
    COUNT(id) AS Total_Loan_Applications,
    SUM(loan_amount) AS Total_Funded_Amount,
    SUM(total_payment) AS Total_Received_Amount
FROM bank_loan_data
GROUP BY MONTH(issue_date), DATENAME(MONTH, issue_date)
ORDER BY MONTH(issue_date);

-- Regional Trends (Group by State)
SELECT 
    address_state AS State,
    COUNT(id) AS Total_Loan_Applications,
    SUM(loan_amount) AS Total_Funded_Amount,
    SUM(total_payment) AS Total_Received_Amount
FROM bank_loan_data
GROUP BY address_state
ORDER BY address_state;

--Loan term analysis for KPI's
SELECT 
    term AS Term,
    COUNT(id) AS Total_Loan_Applications,
    SUM(loan_amount) AS Total_Funded_Amount,
    SUM(total_payment) AS Total_Received_Amount
FROM 
    bank_loan_data
GROUP BY 
   term
ORDER BY 
    term

--Emp length analysis for KPI's
SELECT 
    emp_length AS Emp_Length,
    COUNT(id) AS Total_Loan_Applications,
    SUM(loan_amount) AS Total_Funded_Amount,
    SUM(total_payment) AS Total_Received_Amount
FROM 
    bank_loan_data
GROUP BY 
   emp_length
ORDER BY 
    emp_length

--Loan purpose analysis for KPI's
SELECT 
    purpose AS Loan_purpose,
    COUNT(id) AS Total_Loan_Applications,
    SUM(loan_amount) AS Total_Funded_Amount,
    SUM(total_payment) AS Total_Received_Amount
FROM 
    bank_loan_data
GROUP BY 
   purpose
ORDER BY 
    purpose

--Home ownership analysis for KPI's
SELECT 
    home_ownership AS Home_Ownership,
    COUNT(id) AS Total_Loan_Applications,
    SUM(loan_amount) AS Total_Funded_Amount,
    SUM(total_payment) AS Total_Received_Amount
FROM 
    bank_loan_data
GROUP BY 
   home_ownership
ORDER BY 
    home_ownership

-- ----------------------------------------------
--DASHBOARD -3 (Details)
-- ----------------------------------------------
SELECT*FROM Bank_Loan_Data