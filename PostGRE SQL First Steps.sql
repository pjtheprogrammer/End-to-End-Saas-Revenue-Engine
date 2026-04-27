---Creating Tables---
CREATE TABLE Customers (
CustomerID INT PRIMARY KEY,
CompanyName VARCHAR(100) NOT NULL,
Region VARCHAR(50) DEFAULT 'Global',
Segment VARCHAR(50) CHECK(Segment IN ('Enterprise', 'SMB', 'Individual'))
);

CREATE TABLE Subscriptions(
SubID INT PRIMARY KEY,
CustomerID INT NOT NULL,
MonthlyPrice DECIMAL(10, 2) CHECK(MonthlyPrice > 0),
StartDate DATE NOT NULL,
EndDate DATE,

---Defining Constraints---
CONSTRAINT fk_customer
	FOREIGN KEY (CustomerID)
	REFERENCES Customers(CustomerID)
);

---Populating Tables---
INSERT INTO Customers (CustomerID, CompanyName, Region, Segment)
VALUES (008, 'Alpha Tech', 'North America', 'Enterprise');
INSERT INTO Customers (CustomerID, CompanyName, Region, Segment)
VALUES (002, 'Mish Kapaz Auto', 'Europe', 'Individual');
INSERT INTO Customers (CustomerID, CompanyName, Region, Segment)
VALUES (003, 'Johnsons', 'North America', 'Enterprise');
INSERT INTO Customers (CustomerID, CompanyName, Region, Segment)
VALUES (001, 'McKer''s', 'Europe', 'Enterprise');
INSERT INTO Customers (CustomerID, CompanyName, Region, Segment)
VALUES (004, 'Kliffinger Chambers', 'North America', 'Individual');

INSERT INTO Subscriptions (SubID, CustomerID, MonthlyPrice, StartDate)
VALUES (101, 008, 1200.00, '2026-04-01');
INSERT INTO Subscriptions (SubID, CustomerID, MonthlyPrice, StartDate, EndDate)
VALUES (102, 002, 800.00, '2024-06-21', '2025-06-06');
INSERT INTO Subscriptions (SubID, CustomerID, MonthlyPrice, StartDate)
VALUES (103, 003, 1000.00, '2024-02-27');
INSERT INTO Subscriptions (SubID, CustomerID, MonthlyPrice, StartDate, EndDate)
VALUES (104, 001, 700.00, '2024-02-15', '2025-07-19');
INSERT INTO Subscriptions (SubID, CustomerID, MonthlyPrice, StartDate)
VALUES (105, 004, 1800.00, '2026-02-03');

---Queries to display information---
SELECT * FROM Customers;
SELECT * FROM Subscriptions;

SELECT
	s.MonthlyPrice,
	s.StartDate,
	c.CompanyName,
	c.Segment
FROM Subscriptions s
JOIN Customers c ON s.CustomerID = c.CustomerID;

SELECT 
	c.Segment,
	SUM (s.MonthlyPrice) AS ActiveMRR,
	COUNT (s.SubID) AS ActiveSubscriptions
FROM Subscriptions s
JOIN Customers c ON s.CustomerID = c.CustomerID
WHERE s.StartDate <= CURRENT_DATE AND (s.EndDate IS NULL OR s.EndDate > CURRENT_DATE)
GROUP BY c.Segment;
	
SELECT 
	s.*,
	c.CompanyName
FROM Customers c
JOIN Subscriptions s ON c.CustomerID = s.CustomerID

SELECT
	c.Segment,
	SUM(s.MonthlyPrice) AS Lost_MRR,
	COUNT(s.SubID) AS Churned_Accounts
FROM Customers c
JOIN Subscriptions s ON c.CustomerID = s.CustomerID
WHERE s.EndDate < CURRENT_DATE
GROUP BY c.Segment;

---Working with views---
CREATE VIEW vw_Executive_Revenue AS
SELECT
	c.CompanyName,
	c.Region,
	c.Segment,
	s.MonthlyPrice,
	s.StartDate,
	s.EndDate,
	CASE
		WHEN CURRENT_DATE >= s.StartDate AND (s.EndDate > CURRENT_DATE OR s.EndDate IS NULL) THEN 'Active'
		WHEN CURRENT_DATE < s.StartDate THEN 'Pending'
		ELSE 'Churned'
	END AS Subscription_Status
FROM Customers c
JOIN Subscriptions s ON c.CustomerID = s.CustomerID;

---Working with Custom Table Expressions (CTEs)---
WITH SubscriptionState AS (
SELECT 
	SubID,
	CustomerID,
	CASE 
		WHEN EndDate IS NOT NULL AND EndDate <= CURRENT_DATE THEN 'Churned'
		ELSE 'Active'
	END AS Status
FROM Subscriptions),

MonthlyGrossRevenue AS (
SELECT 
	SUM (s.MonthlyPrice) AS MonthlyGross
FROM Subscriptions s
JOIN SubscriptionState ss ON s.CustomerID = ss.CustomerID
WHERE ss.Status = 'Active'),

MonthlyChurnedRevenue AS (
SELECT 
	SUM (s.MonthlyPrice) AS MonthlyChurn
FROM Subscriptions s
JOIN SubscriptionState ss ON s.CustomerID = ss.CustomerID
WHERE ss.Status = 'Churned')

SELECT 
	g.MonthlyGross - c.MonthlyChurn AS NetRevenue
FROM MonthlyGrossRevenue g, MonthlyChurnedRevenue c;
	
	
