
-- 1. List all customers.
SELECT Id, CONCAT(FirstName,  ' ', LastName) AS Cust_Name
FROM Customer

-- 2. List the first name, last name, and city of all customers.
SELECT CONCAT(FirstName,  ' ', LastName) AS Cust_Name, City
FROM Customer

--3. List the customers in Sweden. Remember it is "Sweden" and NOT "sweden" because 
-- filtering value is case sensitive in Redshift.
SELECT* 
FROM Customer
WHERE Country = 'Sweden'

-- 4. Create a copy of Supplier table. Update the city to Sydney for supplier starting 
-- with letter P.

SELECT * INTO Supplier_Copy
FROM Supplier

UPDATE Supplier_Copy SET  City = 'Sydney'
WHERE CompanyName LIKE 'p%'

select * from Supplier_Copy

-- 5. Create a copy of Products table and Delete all products with unit price higher than 
-- $50.

SELECT * INTO Product_Copy
FROM Product
WHERE UnitPrice < 50

-- 6. List the number of customers in each country.
SELECT Country, COUNT(ID) AS Cust_Count
FROM Customer
GROUP BY Country

-- 7. List the number of customers in each country sorted high to low.
SELECT Country, COUNT(ID) AS Cust_Count
FROM Customer
GROUP BY Country
ORDER BY Cust_Count DESC

-- 8. List the total amount for items ordered by each customer.
SELECT C.Id AS Cust_ID, SUM(TotalAmount) AS Sales
FROM Customer AS C
INNER JOIN Orders AS O
ON C.Id = O.CustomerId
GROUP BY C.Id

-- 9. List the number of customers in each country. Only include countries with more than 10
-- customers.
SELECT Country, COUNT(ID) AS Cust_Count
FROM Customer
GROUP BY Country
HAVING COUNT(ID) > 10

-- 10. List the number of customers in each country, except the USA, sorted high to 
-- low. Only include countries with 9 or more customers.
SELECT Country, COUNT(ID) AS Cust_Count
FROM Customer
WHERE Country <> 'USA'
GROUP BY Country
HAVING COUNT(ID) >= 9
ORDER BY CUST_COUNT DESC

-- 11. List all customers whose first name or last name contains "ill".
SELECT *
FROM Customer
WHERE CONCAT(FirstName,  ' ', LastName) LIKE '%ILL%'

-- 12. List all customers whose average of their total order amount is between $1000 and
-- $1200. Limit your output to 5 results.
SELECT TOP 5 C.Id Cust_ID, AVG(TotalAmount) AS Avg_Order_Amt
FROM Customer AS C
INNER JOIN Orders AS O
ON C.Id = O.CustomerId
GROUP BY C.Id
HAVING AVG(TotalAmount) BETWEEN 1000 AND 1200

-- 13. List all suppliers in the 'USA', 'Japan', and 'Germany', ordered by country from 
-- A-Z, and then by company name in reverse order.
SELECT *
FROM Supplier
WHERE Country IN ('USA', 'JAPAN', 'GERMANY')
ORDER BY Country ASC, CompanyName DESC

-- 14. Show all orders, sorted by total amount (the largest amount first), within each year.
SELECT YEAR(OrderDate) AS Years, OrderDate, TotalAmount
FROM Orders
ORDER BY YEARS ASC, TotalAmount DESC

-- 15. Products with UnitPrice greater than 50 are not selling despite promotions. You are 
-- asked to discontinue products over $25. Write a query to relfelct this. Do this in the 
-- copy of the Product table. DO NOT perform the update operation in the Product table.

DELETE FROM Product_Copy
WHERE UnitPrice > 25

-- 16. List top 10 most expensive products.
SELECT TOP 10 *
FROM Product_Copy
ORDER BY UnitPrice DESC

-- 17. Get all, but the 10 most expensive products sorted by price.
SELECT  *
FROM Product_Copy
ORDER BY UnitPrice DESC
OFFSET 10 ROWS

-- 18. Get the 10th to 15th most expensive products sorted by price.
SELECT  *
FROM Product_Copy
ORDER BY UnitPrice DESC
OFFSET 9 ROWS
FETCH NEXT 6 ROWS ONLY

-- 19. Write a query to get the number of supplier countries. Do not count duplicate values.
SELECT COUNT(DISTINCT Country) AS Supplier_Countires
FROM Supplier

-- 20. Find the total sales cost in each month of the year 2013.
SELECT MONTH(OrderDate) AS Months, SUM(TotalAmount) AS Sales
FROM Orders
WHERE YEAR(OrderDate) = 2013
GROUP BY MONTH(OrderDate)

-- 21. List all products with names that start with 'Ca'.
SELECT*
FROM Product
WHERE ProductName LIKE 'Ca%'

-- 22. List all products that start with 'Cha' or 'Chan' and have one more character.
SELECT * 
FROM Product_Copy
WHERE ProductName LIKE 'Cha_' OR ProductName LIKE 'Chan_'

-- 23. Your manager notices there are some suppliers without fax numbers. He seeks your help 
-- to get a list of suppliers with remark as "No fax number" for suppliers who do not have 
-- fax numbers (fax numbers might be null or blank).Also, Fax number should be displayed for
--customer with fax numbers.

-- 1st way: work on copy table
UPDATE Supplier_Copy SET Fax  = 'No FAX Number'
WHERE Fax IS NULL

SELECT * FROM Supplier_Copy

-- 2nd way: if the access is restricted.
SELECT ID, CompanyName, ContactName, ContactTitle, City, Country, Phone ,
CASE	
	WHEN Fax IS NULL OR Fax = ''	
		THEN 'No FAX Number'
	ELSE Fax
END AS Fax_Number  -- INTO SUPPLIER2
FROM Supplier

-- 24. List all orders, their orderDates with product names, quantities, and prices.
SELECT O.Id, OrderDate, ProductName, SUM(Quantity) AS Quantity, SUM(TotalAmount) Prices
FROM Orders AS O
INNER JOIN OrderItem AS OI
ON O.Id = OI.OrderId
INNER JOIN Product AS P
ON OI.ProductId = P.Id
GROUP BY O.Id, OrderDate, ProductName

-- 25. List all customers who have not placed any Orders.
SELECT*
FROM Customer AS C
LEFT JOIN Orders AS O
ON C.Id = O.CustomerId
WHERE TotalAmount IS NULL

-- 26. List suppliers that have no customers in their country, and customers that have no 
-- suppliers in their country, and customers and suppliers that are from the same country.
SELECT FirstName, LastName, C.Country AS CustomerCountry, s.Country as Supplier_Country,
CompanyName
FROM Supplier AS S
LEFT JOIN Customer AS C
ON S.Country = C.Country
WHERE C.Country IS NULL
UNION
SELECT FirstName, LastName, C.Country AS CustomerCountry, s.Country as Supplier_Country,
CompanyName
FROM Supplier AS S
RIGHT JOIN Customer AS C
ON S.Country = C.Country
WHERE S.Country IS NULL
UNION
SELECT FirstName, LastName, C.Country AS CustomerCountry, s.Country as Supplier_Country,
CompanyName
FROM Supplier AS S
INNER JOIN Customer AS C
ON S.Country = C.Country


-- 27. Match customers that are from the same city and country. That is you are asked to 
-- give a list of customers that are from same country and city. Display firstname, 
-- lastname, city and coutntry of such customers.
SELECT T1.FirstName AS FirstName1, T1.LastName as LastName1,
       T2.FirstName as FirstName2, T2.LastName as LastName2,
	   T1.City , T1.Country
FROM Customer AS T1
INNER JOIN Customer AS T2
ON T1.City = T2.City
          AND
T1.Country = T2.Country
WHERE T1.FirstName <> T2.FirstName
              AND
	 T1.LastName <> T2.LastName
ORDER BY Country, City

-- 28. List all Suppliers and Customers. Give a Label in a separate column as 'Suppliers' if 
-- he is a supplier and 'Customer' if he is a customer accordingly. Also, do not display 
-- firstname and lastname as two fields; Display Full name of customer or supplier.

-- 1st: using sub-querries:
SELECT
CASE
       WHEN Contact_Name IN (SELECT CONCAT(FirstName, ' ', LastName) FROM Customer)
	   THEN 'Customer'
	   ELSE 'Supplier'
END Type, *
FROM(
     SELECT CONCAT(FirstName, ' ', LastName) AS Contact_Name, City, Country, Phone
     FROM Customer
     UNION
     SELECT CompanyName, City, Country, Phone
	 FROM Supplier
) AS X;

-- 2nd way: using CTE:
;WITH Cust_Supp
AS (SELECT CONCAT(FirstName, ' ', LastName) AS Contact_Name, City, Country, Phone
    FROM Customer
    UNION
    SELECT CompanyName, City, Country, Phone
	FROM Supplier
),
Label_Type
AS(SELECT
   CASE
       WHEN Contact_Name IN (SELECT CONCAT(FirstName, ' ', LastName) FROM Customer)
	   THEN 'Customer'
	   ELSE 'Supplier'
END Type, *
FROM Cust_Supp)
SELECT* FROM Label_Type

-- 29. Create a copy of orders table. In this copy table, now add a column city of type 
-- varchar (40). Update this city column using the city info in customers table.
SELECT O.*, C.City INTO Order_Copy
FROM Orders AS O
INNER JOIN Customer AS C
ON O.CustomerId = C.Id

--30. Suppose you would like to see the last OrderID and the OrderDate for this last order 
-- that was shipped to 'Paris'. Along with that information, say you would also like to see
-- the OrderDate for the last order shipped regardless of the Shipping City. In addition to 
-- this, you would also like to calculate the difference in days between these two 
-- OrderDates that you get. Write a single query which performs this.

-- 1st: using sub-querries:
SELECT*, DATEDIFF(DAY, [Last Paris Order], [Last Order Date] ) AS [Difference in Days]
FROM(
       SELECT TOP 1 O.Id, OrderDate AS [Last Paris Order],
               (SELECT MAX(OrderDate) 
             FROM Customer AS C
             INNER JOIN Orders AS O
             ON C.Id = O.CustomerId
          ) AS [Last Order Date]
       FROM Customer AS C
       INNER JOIN Orders AS O
       ON C.Id = O.CustomerId
       WHERE City = 'Paris'
       ORDER BY OrderDate DESC
) AS X;

-- 2nd way: using CTE:
WITH Paris_Detail
AS( SELECT TOP 1 O.Id, OrderDate AS [Last Paris Order]
       FROM Customer AS C
       INNER JOIN Orders AS O
       ON C.Id = O.CustomerId
       WHERE City = 'Paris'
       ORDER BY OrderDate DESC
	),
Last_Order_Detail
AS (SELECT*, (SELECT MAX(OrderDate) 
             FROM Customer AS C
             INNER JOIN Orders AS O
             ON C.Id = O.CustomerId
          ) AS [Last Order Date]
     FROM Paris_Detail
	) 
SELECT*, DATEDIFF(DAY, [Last Paris Order], [Last Order Date] ) AS [Difference in Days]
FROM Last_Order_Detail 

--31. Find those customer countries who do not have suppliers. This might help you provide
-- better delivery time to customers by adding suppliers to these countires. Use SubQueries.
SELECT DISTINCT Country
FROM Customer
WHERE Country NOT IN (SELECT Country FROM Supplier);

-- 32. Suppose a company would like to do some targeted marketing where it would contact
--customers in the country with the fewest number of orders. It is hoped that this targeted
--marketing will increase the overall sales in the targeted country. You are asked to write
-- a query to get all details of such customers from top 5 countries with fewest numbers of 
-- orders. Use subqueries.

-- using CTEs:
WITH Top_5_Countries
AS (SELECT TOP 5 Country, COUNT(O.Id) AS Order_Count
		FROM Customer AS C
		INNER JOIN Orders AS O
		ON C.Id = O.CustomerId
		GROUP BY Country
		ORDER BY ORDER_COUNT ASC
	),
Cust_Info
AS (SELECT* 
     FROM Customer
	 WHERE Country IN (SELECT Country from Top_5_Countries) --SubQuery
	 )
SELECT* FROM Cust_Info
ORDER BY Country
   
--33. Let's say you want report of all distinct "OrderIDs" where the customer did not 
-- purchase more than 10% of the average quantity sold for a given product. This way 
-- you could review these orders, and possibly contact the customers, to help determine
-- if there was a reason for the low quantity order. Write a query to report such orderIDs.
SELECT DISTINCT OrderId
FROM OrderItem AS A
INNER JOIN (SELECT P.Id, AVG(Quantity) AS Avg_Qty_Sold
             FROM Product AS P
             INNER JOIN OrderItem AS OI
             ON P.Id = OI.ProductId
             GROUP BY P.Id
 ) AS B
 ON A.ProductId = B.Id
 WHERE Quantity < Avg_Qty_Sold*0.1

-- 34. Find Customers whose total orderitem amount is greater than 7500$ for the year 
-- 2013. The total order item amount for 1 order for a customer is calculated using 
-- the formula UnitPrice * Quantity * (1 - Discount). DO NOT consider the total amount 
-- column from 'Order' table to calculate the total orderItem for a customer.
SELECT CustomerId, SUM(UnitPrice * Quantity * (1 - Discount)) AS Total_Amt
FROM Orders AS O
INNER JOIN OrderItem AS OI
ON O.Id = OI.OrderId
WHERE YEAR(OrderDate) = '2013'
GROUP BY CustomerId
HAVING SUM(UnitPrice * Quantity * (1 - Discount)) > 7500

--35. Display the top two customers, based on the total dollar amount associated with 
-- their orders, per country. The dollar amount is calculated as 
-- OI.unitprice * OI.Quantity * (1 - OI.Discount). You might want to perform a query 
-- like this so you can reward these customers, since they buy the most per country.

SELECT ID, FirstName, LastName, Country
FROM (
	SELECT c.Id AS [ID], FirstName, LastName, Country, 
	SUM(UnitPrice * Quantity * (1-Discount)) AS Dollar_Amount,
	DENSE_RANK() OVER (PARTITION BY country 
						ORDER BY SUM(UnitPrice * Quantity * (1-Discount)) DESC ) AS Ranks
	FROM Customer AS C
	INNER JOIN Orders AS O
	ON c.Id = o.CustomerId
	INNER JOIN OrderItem AS OI
	ON O.Id = OI.OrderId
	GROUP BY C.Id, FirstName, LastName, Country
) AS X
WHERE Ranks <= 2;

-- Using cte:
WITH Customer_Order_Data
AS ( SELECT C.Id, FirstName, LastName, Country, 
    SUM(UnitPrice * Quantity * (1-Discount)) AS Dollar_Amount
    FROM Customer AS C
	INNER JOIN Orders AS O
	ON c.Id = o.CustomerId
	INNER JOIN OrderItem AS OI
	ON O.Id = OI.OrderId
	GROUP BY C.Id, FirstName, LastName, Country
), Customer_Ranks
AS ( SELECT*,
       DENSE_RANK() OVER (PARTITION BY Country ORDER BY Dollar_Amount DESC) AS Ranks
	   FROM Customer_Order_Data
    )
SELECT Id, FirstName, LastName, Country
FROM Customer_Ranks
WHERE Ranks < 3 ;


-- 36. Create a View of Products whose unit price is above average Price.
CREATE VIEW Products_View
AS
       SELECT ProductName, UnitPrice
       FROM Product
       WHERE UnitPrice > (SELECT AVG(UnitPrice) FROM Product)

SELECT* FROM Products_View

--37. Write a store procedure that performs the following action:
/*Check if Product_copy table (this is a copy of Product table) is present. 
If table exists, the procedure should drop this table first and recreated.
Add a column Supplier_name in this copy table. Update this column with that of
'CompanyName' column from Supplier tab */
CREATE PROCEDURE Prod_Supp
AS 
  IF 'Product_Copy' in (SELECT table_name FROM  INFORMATION_SCHEMA.TABLES)
  BEGIN
      DROP TABLE Product_Copy
      SELECT P.*, S.CompanyName AS Supplier_Name INTO Product_Copy2
	  FROM Product AS P
	  LEFT JOIN Supplier AS S
	  ON P.SupplierId = S.Id
  END

EXEC Prod_Supp

SELECT* FROM Product_Copy2
