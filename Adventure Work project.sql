/* First step is to creating separate database to import table from local device */
create database Adventure;

Use Adventure;
/* Above Query is use to specify database*/

select * from factinternetsales; -- this query is use to read the table
select * from fact_internet_sales_new;
desc factinternetsales; -- this query use to describe the column,datatype,key,etc..,

/* 0. Union of Fact Internet sales and Fact internet sales new */
create table all_sales_of_fact_internet as select * from factinternetsales union all select * from fact_internet_sales_new;

select * from dimproduct;
select * from dimcustomer;
select * from all_sales_of_fact_internet;

/*1.Lookup the productname from the Product sheet to Sales sheet.*/
select p.EnglishProductName As ProductName , s.* from all_sales_of_fact_internet s join dimproduct p on s.ProductKey = p.ProductKey;

/*2.Lookup the Customerfullname from the Customer and Unit Price from Product sheet to Sales sheet.*/
select Concat_ws(c.FirstName,c.MiddleName,c.LastName) as FullName,p.Unitprice,s.* from all_sales_of_fact_internet s join dimcustomer c on s.CustomerKey = c.CustomerKey
join dimproduct as p on s.ProductKey =  p.ProductKey;
create table Orderdatekey as select ProductKey,Orderdatekey from all_sales_of_fact_internet;

Alter table OrderdateKey add column OrderDate Date;-- Here I just Add the column of OrderDate
SET sql_safe_updates = 0; -- here just off safe updates to use update function
Update OrderdateKey Set OrderDate = STR_TO_date(OrderDateKey,'%Y%m%d'); -- here i change format of orderdatekey and add to orderdate column
select * from OrderdateKey;

   /*A.Year*/
select year(OrderDate) from OrderdateKey;
/*   B.Monthno*/
select month(OrderDate) from OrderdateKey;
/*   C.Monthfullname*/
select monthname(OrderDate) from OrderdateKey;
/*   D.Quarter(Q1,Q2,Q3,Q4)*/
Select concat('Q',Quarter(OrderDate)) as label from orderdatekey;
/*   E. YearMonth ( YYYY-MMM)*/
select date_format(OrderDate,'%Y-%b') from orderdatekey;
/*   F. Weekdayno*/
select weekday(OrderDate) from Orderdatekey;
/*   G.Weekdayname*/
select dayname(orderDate) from Orderdatekey;
/*   H.FinancialMOnth*/
select month(Orderdatekey) as month_column,
case
When Month(Orderdatekey) >= 4 Then month(Orderdatekey) - 3
else
Month(Orderdatekey) + 9
End as FinancialMonth
from Orderdatekey;

/*   I. Financial Quarter */
select Month(Orderdatekey),
case
when month(Orderdatekey) between 4 and 6 then 'Q1'
when month(Orderdatekey) between 7 and 9 then 'Q2'
when month(Orderdatekey) between 10 and 12 then 'Q3'
else 'Q4'
end as financial_Quarder
from Orderdatekey;

/*4.Calculate the Sales amount uning the columns(unit price,order quantity,unit discount)*/
select UnitPrice,OrderQuantity,UnitPriceDiscountPct,((Unitprice*OrderQuantity)-(UnitPriceDiscountPct*OrderQuantity)) as Sales from all_sales_of_fact_internet;

/*5.Calculate the Productioncost uning the columns(unit cost ,order quantity)*/
select OrderQuantity,(ProductStandardcost*Orderquantity) as Productioncost from all_sales_of_fact_internet;

/*6.Calculate the profit.*/
With Profit_calculation as ( select ProductKey,UnitPrice,OrderQuantity,UnitPriceDiscountPct,((Unitprice*OrderQuantity)-(UnitPriceDiscountPct*OrderQuantity)) as Sales,
(ProductStandardcost*Orderquantity) as Productioncost,TaxAmt,Freight from all_sales_of_fact_internet) 
select *,(Sales-Productioncost-TaxAmt-Freight) as Net_Profit from Profit_calculation;





