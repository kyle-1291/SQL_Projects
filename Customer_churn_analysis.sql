select * from churn
--1. Finding the total number of customers
Select Distinct COUNT(CustomerID) as Total_customer_number From churn
--2. Checking for duplicate rows
Select CustomerID, count(CustomerID) as Dublicates from churn group by CustomerID having count(CustomerID) > 1
--3. Checking for null values
SELECT 'Tenure' as ColumnName, COUNT(*) AS NullCount FROM churn WHERE Tenure IS NULL 
union 
Select 'PreferredLoginDevice' as ColumnName, COUNT(*) as NullCount From churn Where PreferredLoginDevice IS NULL
union 
Select 'WarehouseToHome' as ColumnName, COUNT(*) as NullCount From churn Where WarehouseToHome IS NULL
union 
Select 'HourSpendonApp' as ColumnName, COUNT(*) as NullCount From churn Where HourSpendOnApp IS NULL
union
Select 'OrderAmountHikeFromLastYear' as ColumnName, COUNT(*) as NullCount From churn Where OrderAmountHikeFromLastYear IS NULL
union
Select 'CouponUsed' as ColumnName, COUNT(*) as NullCount From churn Where CouponUsed IS NULL
union
Select 'OrderCount' as ColumnName, COUNT(*) as NullCount From churn Where OrderCount IS NULL
union
Select 'DaySinceLastOrder' as ColumnName, COUNT(*) as NullCount From churn Where DaySinceLastOrder IS NULL

--3.1 Handling null values
UPDATE churn
SET Hourspendonapp = (SELECT AVG(Hourspendonapp) FROM churn)
WHERE Hourspendonapp IS NULL 

UPDATE churn
SET tenure = (SELECT AVG(tenure) FROM churn)
WHERE tenure IS NULL 

UPDATE churn
SET orderamounthikefromlastyear = (SELECT AVG(orderamounthikefromlastyear) FROM churn)
WHERE orderamounthikefromlastyear IS NULL 

UPDATE churn
SET WarehouseToHome = (SELECT  AVG(WarehouseToHome) FROM churn)
WHERE WarehouseToHome IS NULL 

UPDATE churn
SET couponused = (SELECT AVG(couponused) FROM churn)
WHERE couponused IS NULL 

UPDATE churn
SET ordercount = (SELECT AVG(ordercount) FROM churn)
WHERE ordercount IS NULL 

UPDATE churn
SET daysincelastorder = (SELECT AVG(daysincelastorder) FROM churn)
WHERE daysincelastorder IS NULL 

--4. Creating a new column from an already existing ?churn?, "complain" column
ALTER TABLE churn
ADD churn_stat varchar(50)

UPDATE churn 
SET churn_stat = 
CASE
WHEN churn = 1 THEN 'churned'
WHEN churn = 0 THEN 'stayed'
END

ALTER TABLE churn 
ADD complain_stat varchar(50)

UPDATE churn
SET complain_stat =
CASE 
WHEN Complain = 1 THEN 'yes'
WHEN Complain = 0 THEN 'no'
END

--Checking for distinct valuse in each column 
 SELECT DISTINCT PreferredLoginDevice FROM churn 

UPDATE churn 
SET PreferredLoginDevice = 'Phone' WHERE PreferredLoginDevice = 'Mobile Phone'  

SELECT DISTINCT PreferredPaymentMode FROM churn

UPDATE churn
SET PreferredPaymentMode  = 'Cash on Delivery'
WHERE PreferredPaymentMode  = 'COD'

SELECT DISTINCT preferedordercat 
FROM churn

UPDATE churn
SET preferedordercat = 'Mobile Phone' 
WHERE preferedordercat = 'Mobile'

SELECT DISTINCT warehousetohome
FROM churn
--looks like 127 and 126 seems tobe outlier ,hence we replace 127 with 27 and 126 with 26

UPDATE churn
SET WarehouseToHome = 27
WHERE WarehouseToHome = 127

UPDATE churn
SET WarehouseToHome = 26
WHERE WarehouseToHome = 126

--DATA EXPLORATION
--1. What is the overall customer churn rate?

SELECT COUNT(*) as Total_no_customer ,
SUM(CASE WHEN churn_stat = 'churned' THEN 1 ELSE 0 END) AS Total_churned_customer,
CAST(SUM(CASE WHEN churn_stat = 'churned' THEN 1 ELSE 0 END)*1.0/COUNT(*)*100
        AS DECIMAL(10,2)
    ) AS ChurnRate
FROM churn 

/*The churn rate of 16.84% indicates that a significant portion of customers in the dataset 
  have ended their association with the company.*/

--2. How does the churn rate vary based on the preferred login device?

SELECT PreferredLoginDevice as LoginMethod,
COUNT(*) AS total_cusotmer,
SUM(CASE WHEN churn_stat = 'churned' THEN 1 ELSE 0 END) AS churned_customer_loginmethod,
CAST(SUM(CASE WHEN churn_stat = 'churned' THEN 1 ELSE 0 END)*1.0/COUNT(*)*100
        AS DECIMAL(10,2)
    ) AS ChurnRates
FROM churn
GROUP BY PreferredLoginDevice

--3.What is the distribution of customers across different city tiers?
SELECT CityTier as City,
COUNT(*) AS total_cusotmer,
SUM(CASE WHEN churn_stat = 'churned' THEN 1 ELSE 0 END) AS churned_customer_city,
CAST(SUM(CASE WHEN churn_stat = 'churned' THEN 1 ELSE 0 END)*1.0/COUNT(*)*100
        AS DECIMAL(10,2)
    ) AS ChurnRates
FROM churn
GROUP BY CityTier
ORDER BY ChurnRates DESC

--4. Is there any correlation between the warehouse-to-home distance and customer churn?
ALTER TABLE churn
ADD wth_distance varchar(50)

UPDATE churn
SET wth_distance = 
CASE 
WHEN warehousetohome <= 10 THEN 'Very close distance'
    WHEN warehousetohome > 10 AND warehousetohome <= 20 THEN 'Close distance'
    WHEN warehousetohome > 20 AND warehousetohome <= 30 THEN 'Moderate distance'
    WHEN warehousetohome > 30 THEN 'Far distance'
END

SELECT wth_distance as WarehoursetoHome_dist,
COUNT(*) AS total_cusotmer,
SUM(CASE WHEN churn_stat = 'churned' THEN 1 ELSE 0 END) AS churned_WarehoursetoHome_dist,
CAST(SUM(CASE WHEN churn_stat = 'churned' THEN 1 ELSE 0 END)*1.0/COUNT(*)*100
        AS DECIMAL(10,2)
    ) AS ChurnRates
FROM churn
GROUP BY wth_distance
ORDER BY wth_distance ASC

--5. Which is the most preferred payment mode among churned customers?

SELECT PreferredPaymentMode as Mode_of_Payment,
COUNT(*) AS total_cusotmer,
SUM(CASE WHEN churn_stat = 'churned' THEN 1 ELSE 0 END) AS churned_mop,
CAST(SUM(CASE WHEN churn_stat = 'churned' THEN 1 ELSE 0 END)*1.0/COUNT(*)*100
        AS DECIMAL(10,2)
    ) AS ChurnRates
FROM churn
GROUP BY PreferredPaymentMode

--6. What is the typical tenure for churned customers?

ALTER TABLE churn
ADD TenureRange NVARCHAR(50)

UPDATE churn
SET TenureRange =
CASE 
    WHEN tenure <= 6 THEN '6 Months'
    WHEN tenure > 6 AND tenure <= 12 THEN '1 Year'
    WHEN tenure > 12 AND tenure <= 24 THEN '2 Years'
    WHEN tenure > 24 THEN '2 years +'
END

SELECT TenureRange as Tenure,
COUNT(*) AS total_cusotmer,
SUM(CASE WHEN churn_stat = 'churned' THEN 1 ELSE 0 END) AS churned_tenure,
CAST(SUM(CASE WHEN churn_stat = 'churned' THEN 1 ELSE 0 END)*1.0/COUNT(*)*100
        AS DECIMAL(10,2)
    ) AS ChurnRates
FROM churn
GROUP BY TenureRange

--7. Is there any difference in churn rate between male and female customers?

SELECT Gender as Tenure,
COUNT(*) AS total_cusotmer,
SUM(CASE WHEN churn_stat = 'churned' THEN 1 ELSE 0 END) AS churned_gender,
CAST(SUM(CASE WHEN churn_stat = 'churned' THEN 1 ELSE 0 END)*1.0/COUNT(*)*100
        AS DECIMAL(10,2)
    ) AS ChurnRates
FROM churn
GROUP BY Gender
 --8.How does the average time spent on the app differ for churned and non-churned customers?
SELECT churn_stat as Churned_Status,AVG(HourSpendOnApp) as Average_hour FROM churn
GROUP BY churn_stat

--9. Does the number of registered devices impact the likelihood of churn?
  SELECT NumberOfDeviceRegistered as no_of_device,
  COUNT(*) AS total_customer,
  SUM(CASE WHEN churn_stat = 'churned' THEN 1 ELSE 0 END) AS churn_cutomer,
  CAST(SUM (CASE WHEN churn_stat = 'churned' THEN 1 ELSE 0 END)*1.0/count(*)*100 AS DECIMAL (10,2)
  ) AS ChurnRates
  FROM churn
  GROUP BY NumberofDeviceRegistered
  ORDER BY NumberOfDeviceRegistered DESC

  --10. Which order category is most preferred among churned customers?
  
  SELECT PreferedOrderCat  as prefered_device,
  COUNT(*) AS total_customer,
  SUM(CASE WHEN churn_stat = 'churned' THEN 1 ELSE 0 END) AS churn_cutomer,
  CAST(SUM (CASE WHEN churn_stat = 'churned' THEN 1 ELSE 0 END)*1.0/count(*)*100 AS DECIMAL (10,2)
  ) AS ChurnRates
  FROM churn
  GROUP BY PreferedOrderCat

 -- 11. Is there any relationship between customer satisfaction scores and churn?
  SELECT SatisfactionScore  as sataf_score,
  COUNT(*) AS total_customer,
  SUM(CASE WHEN churn_stat = 'churned' THEN 1 ELSE 0 END) AS churn_cutomer,
  CAST(SUM (CASE WHEN churn_stat = 'churned' THEN 1 ELSE 0 END)*1.0/count(*)*100 AS DECIMAL (10,2)
  ) AS ChurnRates
  FROM churn
  GROUP BY SatisfactionScore
  ORDER BY SatisfactionScore, ChurnRates DESC

  --12. Does the marital status of customers influence churn behavior?
  SELECT MaritalStatus  as Marriage_status,
  COUNT(*) AS total_customer,
  SUM(CASE WHEN churn_stat = 'churned' THEN 1 ELSE 0 END) AS churn_cutomer,
  CAST(SUM (CASE WHEN churn_stat = 'churned' THEN 1 ELSE 0 END)*1.0/count(*)*100 AS DECIMAL (10,2)
  ) AS ChurnRates
  FROM churn
  GROUP BY MaritalStatus
  ORDER BY ChurnRates DESC
  
  --13. Do customer complaints influence churned behavior?
  SELECT complain_stat  as Complain_status,
  COUNT(*) AS total_customer,
  SUM(CASE WHEN churn_stat = 'churned' THEN 1 ELSE 0 END) AS churn_cutomer,
  CAST(SUM (CASE WHEN churn_stat = 'churned' THEN 1 ELSE 0 END)*1.0/count(*)*100 AS DECIMAL (10,2)
  ) AS ChurnRates
  FROM churn
  GROUP BY complain_stat
  ORDER BY ChurnRates DESC
  --14. Is there any correlation between cashback amount and churn rate?


ALTER TABLE churn
ADD cashbackamountrange NVARCHAR(50)

UPDATE churn
SET cashbackamountrange =
CASE 
    WHEN cashbackamount <= 100 THEN 'Low Cashback Amount'
    WHEN cashbackamount > 100 AND cashbackamount <= 200 THEN 'Moderate Cashback Amount'
    WHEN cashbackamount > 200 AND cashbackamount <= 300 THEN 'High Cashback Amount'
    WHEN cashbackamount > 300 THEN 'Very High Cashback Amount'
END

--Finding the correlation between cashback amount range and churned rate

SELECT cashbackamountrange,
       COUNT(*) AS TotalCustomer,
       SUM(Churn) AS CustomerChurn,
       CAST(SUM(Churn) * 1.0 /COUNT(*) * 100 AS DECIMAL(10,2)) AS Churnrate
FROM churn
GROUP BY cashbackamountrange
ORDER BY Churnrate DESC
