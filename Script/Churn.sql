CREATE DATABASE Churn;

SELECT * FROM  telecom;

USE Churn;


-- 1.	Calculate the overall churn rate from the main customer data.
SELECT 
    (COUNT(*) / (SELECT 
            COUNT(*)
        FROM
            telecom) * 100) AS Churn_Rate
FROM
    telecom
WHERE
    churn = 'Yes';

-- 2.	Find the average monthly charges for churned vs non-churned customers.
SELECT 
    Churn,
    ROUND(AVG(MonthlyCharges), 2) AS Average_MonthlyCharges
FROM
    telecom
GROUP BY Churn;

-- 3.	List the top 5 payment methods with the highest churn rates.
SELECT 
    t.PaymentMethod,
    (COUNT(*) / total.total_count) * 100 AS churn_rate_percentage
FROM
    telecom t
        JOIN
    (SELECT 
        PaymentMethod, COUNT(*) AS total_count
    FROM
        telecom
    GROUP BY PaymentMethod) AS total ON t.PaymentMethod = total.PaymentMethod
WHERE
    t.churn = 'Yes'
GROUP BY t.PaymentMethod , total.total_count
ORDER BY churn_rate_percentage DESC
LIMIT 5;

-- 4.	Display the number of customers on each contract type who have churned.
SELECT 
    Contract, COUNT(*) AS Number_of_Customers_Churned
FROM
    telecom
WHERE
    Churn = 'Yes'
GROUP BY Contract;

-- 5.	Count how many customers have tenure less than 12 months and have churned.
SELECT 
     COUNT(*) AS No_of_Customers
FROM
    telecom
WHERE
    Churn = 'Yes' AND Tenure < 12;

-- 6.	Identify how many customers have paperless billing and are paying through electronic check.
SELECT 
    COUNT(*) AS Number_of_Customers
FROM
    telecom
WHERE
    PaperlessBilling = 'Yes'
        AND PaymentMethod = 'Electronic check';

-- 7.	Calculate the total revenue generated from non-churned customers only.
SELECT 
    ROUND(SUM(TotalCharges), 2) AS Total_Revenue_Generated
FROM
    telecom
WHERE
    Churn = 'No';

-- 8.	List customers who have never used phone service or internet service.
SELECT 
    CustomerID
FROM
    telecom
WHERE
    MultipleLines = 'No phone service'
        AND InternetService = 'No';

-- 9.	Find the number of customers with ‘Month-to-month’ contracts and no online security.
SELECT 
    COUNT(*) AS Number_of_Customers
FROM
    telecom
WHERE
    Contract = 'Month-to-month'
        AND OnlineSecurity = 'No';

-- 10.	Show the churn rate grouped by senior citizen status.
SELECT 
    SeniorCitizen,
    (SELECT 
            (COUNT(*) / (SELECT 
                        COUNT(*)
                    FROM
                        telecom) * 100) AS Churn_Rate
        FROM
            telecom
        WHERE
            churn = 'Yes') AS Churn_Rate
FROM
    telecom
GROUP BY SeniorCitizen;

-- 11.	Determine the average customer age for churned vs non-churned customers.
SELECT 
    Churn, AVG(YEAR(CURRENT_DATE()) - Year) AS Avg_Age
FROM
    telecom
GROUP BY Churn;

-- 12.	List customers with Fiber optic internet who are using all entertainment services (StreamingTV and StreamingMovies).
SELECT 
     CustomerID , InternetService
FROM
    telecom
WHERE InternetService = 'Fiber optic' AND StreamingTV = 'Yes' AND StreamingMovies = 'Yes'
;

-- 13.	Identify the top 5 customers who have paid the highest total charges but still churned.
SELECT 
     CustomerID , TotalCharges , Churn
FROM
    telecom
WHERE Churn = 'Yes'
ORDER BY TotalCharges DESC
LIMIT 5;

-- 14.	Find customers who are not senior citizens now, but will turn 65 within the next 2 years.
SELECT 
     CustomerID , Year, YEAR(CURRENT_DATE()) - Year AS Age
FROM
    telecom
WHERE (YEAR(CURRENT_DATE()) - Year) BETWEEN 63 AND 64;

-- 15.	Get a list of customers who are using all possible services (phone, internet, backup, security, streaming, tech support).
SELECT 
    CustomerID
FROM
    telecom
WHERE
    PhoneService = 'Yes'
        AND InternetService IN ('Fiber optic' , 'DSL')
        AND OnlineBackup = 'Yes'
        AND OnlineSecurity = 'Yes'
        AND StreamingMovies = 'Yes'
        AND StreamingTV = 'Yes'
        AND TechSupport = 'Yes';

-- 16.	Calculate the churn rate by age group: <30, 30–50, 51–64, 65+.
SELECT 
  CASE
    WHEN YEAR(CURRENT_DATE()) - Year < 30 THEN '<30'
    WHEN YEAR(CURRENT_DATE()) - Year BETWEEN 30 AND 50 THEN '30–50'
    WHEN YEAR(CURRENT_DATE()) - Year BETWEEN 51 AND 64 THEN '51–64'
    ELSE '65+'
  END AS Age_group, 
  SUM(Churn = 'Yes') * 100 / COUNT(*) AS Churn_Rate
FROM telecom
GROUP BY Age_group
;

-- 17.	Using a subquery, find customers whose total charges are above the average of all churned customers.
SELECT 
    CustomerID, TotalCharges
FROM
    telecom
WHERE
    TotalCharges > (SELECT 
            AVG(TotalCharges)
        FROM
            telecom
        WHERE
            Churn = 'Yes')
;

-- 18.	Determine the correlation between long tenure (>= 24 months) and churn. Do loyal customers churn less?
SELECT
    (AVG(tenure * (churn = 'yes')) - AVG(tenure) * AVG(churn = 'yes')) / (STDDEV_POP(tenure) * STDDEV_POP(churn = 'yes')) AS correlation
FROM
    churn_data.teledata
WHERE
    tenure >= 24;

-- 19.	Create a report showing monthly churn trend — how many customers churned each month.
SELECT 
    Tenure AS Tenure_Month, COUNT(*) AS Customers_Churn
FROM
    telecom
WHERE
    Churn = 'Yes'
GROUP BY Tenure
ORDER BY Tenure;

-- 20.	Rank customers by revenue (total charges) within each contract type using window functions.
SELECT CustomerID , Contract , 
dense_rank() OVER (PARTITION BY Contract 
ORDER BY TotalCharges DESC) AS Rankings
FROM telecom;

-- 21.	Using a CTE, list customers who have either no protection services (OnlineSecurity, Backup, DeviceProtection) and have churned.
WITH No_Protection AS
(SELECT * 
FROM telecom
WHERE OnlineSecurity = 'No'
AND OnlineBackup = 'No'
AND DeviceProtection = 'No')
SELECT CustomerID , OnlineSecurity , OnlineBackup , DeviceProtection
FROM No_Protection
WHERE churn = 'Yes';

-- 22.	I want a to check how many days, month and year is left for each and every employee to reach the Senior Citizen
SELECT 
  Day,
  Month,
  Year,
  STR_TO_DATE(CONCAT(Year, '-', Month, '-', Day), '%Y-%m-%d') AS DateOfBirth
FROM telecom;



