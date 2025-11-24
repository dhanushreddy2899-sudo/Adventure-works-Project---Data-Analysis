use adventureworks;
# loaded the csv datasets to insert  data into database
select * from dimcustomer;
select * from dimdate; 
select * from dimprodcategory;
select * from dimprodsubcategory;
select * from dimproduct;
select * from dimsalesterritory;
select * from fact_internet_sales;
select * from fact_internet_sales_new;
show tables;
#  Total Number of Orders
SELECT COUNT(Productkey) AS Total_Orders
FROM Fact_Internet_Sales;
# Answer: Returns how many sales orders exist in the dataset.

# Total Revenue and Profit
SELECT 
    ROUND(SUM(SalesAmount), 2) AS Total_Revenue,
    ROUND(SUM(SalesAmount - TotalProductCost), 2) AS Total_Profit
FROM Fact_Internet_Sales;
# Explaination:Shows total revenue and profit (difference between SalesAmount and TotalProductCost).


# Top 10 Selling Products

SELECT 
    p.EnglishProductName AS Product,
    ROUND(SUM(f.SalesAmount), 2) AS Total_Sales
FROM Fact_Internet_Sales f
JOIN DimProduct p 
    ON f.ProductKey = p.ProductKey
GROUP BY p.EnglishProductName
ORDER BY Total_Sales DESC
LIMIT 10;
# Explaination: Lists the 10 products with the highest sales revenue.

# Sales by Product Category

SELECT 
    pc.EnglishProductCategoryName AS Category,
    ROUND(SUM(f.SalesAmount), 2) AS Total_Sales
FROM Fact_Internet_Sales f
JOIN DimProduct p ON f.ProductKey = p.ProductKey
JOIN DimProdSubCategory sc ON p.ProductSubcategoryKey = sc.ProductSubcategoryKey
JOIN DimProdCategory pc ON sc.ProductCategoryKey = pc.ProductCategoryKey
GROUP BY pc.EnglishProductCategoryName;
# Explaination: Displays revenue for each product category like Bikes


#  Average Order Value
SELECT 
    ROUND(SUM(SalesAmount) / COUNT(DISTINCT SalesOrderNumber), 2) AS Avg_Order_Value
FROM Fact_Internet_Sales;
# Explaination: The average value per order — a key sales KPI.

# Monthly Sales Trend
SELECT 
    d.CalendarYear,
    d.EnglishMonthName,
    ROUND(SUM(f.SalesAmount), 2) AS Monthly_Sales
FROM Fact_Internet_Sales f
JOIN DimDate d ON f.OrderDateKey = d.FullDateAlternateKey
GROUP BY d.CalendarYear, d.EnglishMonthName
ORDER BY d.CalendarYear, MIN(d.MonthNumberOfYear);
# Explaination: Shows how sales change month-to-month across years.

# Highest Revenue Territory
SELECT 
    t.SalesTerritoryRegion,
    ROUND(SUM(f.SalesAmount), 2) AS Region_Revenue
FROM Fact_Internet_Sales f
JOIN DimSalesTerritory t ON f.SalesTerritoryKey = t.SalesTerritoryKey
GROUP BY t.SalesTerritoryRegion
ORDER BY Region_Revenue DESC
LIMIT 1;
# Explanation : Identifies the top-performing region by total revenue.

# Number of Customers per Territory

SELECT 
    t.SalesTerritoryRegion,
    COUNT(DISTINCT c.CustomerKey) AS Customer_Count
FROM DimCustomer c
JOIN Fact_Internet_Sales f ON c.CustomerKey = f.CustomerKey
JOIN DimSalesTerritory t ON f.SalesTerritoryKey = t.SalesTerritoryKey
GROUP BY t.SalesTerritoryRegion;
# Explaination: Finds how many unique customers each sales region serves.


#  Repeat Customers

SELECT 
    COUNT(*) AS Repeat_Customers
FROM (
    SELECT CustomerKey
    FROM Fact_Internet_Sales
    GROUP BY CustomerKey
    HAVING COUNT(DISTINCT SalesOrderNumber) > 1
) AS multiple_orders;
# Explainatiom Number of customers who placed more than one order.

# Most Profitable Product
SELECT 
    p.EnglishProductName AS Product,
    ROUND(SUM(f.SalesAmount - f.TotalProductCost), 2) AS Total_Profit
FROM Fact_Internet_Sales f
JOIN DimProduct p ON f.ProductKey = p.ProductKey
GROUP BY p.EnglishProductName
ORDER BY Total_Profit DESC
LIMIT 1;
#Explaination: Product that generated the most total profit.

# Sales Growth by Year

SELECT 
    d.CalendarYear,
    ROUND(SUM(f.SalesAmount), 2) AS Total_Sales,
    ROUND(
        (SUM(f.SalesAmount) - LAG(SUM(f.SalesAmount)) 
        OVER (ORDER BY d.CalendarYear)) / 
        LAG(SUM(f.SalesAmount)) 
        OVER (ORDER BY d.CalendarYear) * 100, 2
    ) AS YoY_Growth_Percent
FROM Fact_Internet_Sales f
JOIN DimDate d ON f.OrderDateKey = d.FullDateAlternateKey
GROUP BY d.CalendarYear;
# Explaination: Year-over-year sales growth rate.

# Customer Demographics: Marital Status
SELECT 
    c.MaritalStatus,
    ROUND(SUM(f.SalesAmount), 2) AS Total_Sales
FROM DimCustomer c
JOIN Fact_Internet_Sales f ON c.CustomerKey = f.CustomerKey
GROUP BY c.MaritalStatus;
# explaination: Compares total sales from married (M) vs single (S) customers.

#Average Profit Margin per Product
SELECT 
    p.EnglishProductName AS Product,
    ROUND(AVG((f.SalesAmount - f.TotalProductCost) / f.SalesAmount * 100), 2) AS Avg_Margin_Percent
FROM Fact_Internet_Sales f
JOIN DimProduct p ON f.ProductKey = p.ProductKey
GROUP BY p.EnglishProductName
ORDER BY Avg_Margin_Percent DESC;
# Explainatio: Average profit margin percentage for each product.

# Sales by Country
SELECT 
    t.SalesTerritoryCountry AS Country,
    ROUND(SUM(f.SalesAmount), 2) AS Total_Sales
FROM Fact_Internet_Sales f
JOIN DimSalesTerritory t ON f.SalesTerritoryKey = t.SalesTerritoryKey
GROUP BY t.SalesTerritoryCountry
ORDER BY Total_Sales DESC;
#Explaination:Total sales by each country (e.g., United States, Canada).
#  Highest Tax and Freight Costs
SELECT 
    SalesOrderNumber,
    ROUND(SUM(TaxAmt), 2) AS Total_Tax,
    ROUND(SUM(Freight), 2) AS Total_Freight
FROM Fact_Internet_Sales
GROUP BY SalesOrderNumber
ORDER BY (SUM(TaxAmt) + SUM(Freight)) DESC
LIMIT 5;
# Explaination: Finds 5 orders with the highest combined tax and freight costs.
