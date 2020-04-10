USE AdventureWorks2008R2
GO

--Lab 3-1
/* Modify the following query to add a ranking column with gaps based on the total purchase in the descending order.
 Also partition by territory.Give the new column an alias to make the report more attractive. */
SELECT
CustomerID,TerritoryID, ROUND(SUM(TotalDue),2) as TotalPurchase,
COUNT(SalesOrderid)[Total # of Orders], 
RANK() OVER (PARTITION BY TerritoryID ORDER BY ROUND(SUM(TotalDue),2) DESC) as RankofOrders
FROM
Sales.SalesOrderHeader WHERE DATEPART(year,OrderDate)=2007
GROUP BY
CustomerID,TerritoryID;

--Lab 3-2
/* Modify the following query to add a column that identifies the
frequency of repeat customers. The new column will contain
the following values based on the number of orders during 2007:
'One Time' for the order count = 1'Regular' for the order count range of 2-5
'Loyal' for the order count greater than >5 
Give the new column an alias to make the report more readable. */

SELECT
	CustomerID,ROUND(SUM(TotalDue),2)[Total Purchase],COUNT(SalesOrderid)[Total # of Orders],
CASE 
WHEN COUNT(SalesOrderid) = 1
THEN 'One Time'
WHEN COUNT(SalesOrderid)>=2 AND COUNT(SalesOrderid) <=5
THEN 'Regular'
WHEN COUNT(SalesOrderid)>5
THEN 'Loyal'
END as Frequency
FROM
Sales.SalesOrderHeader 
WHERE
DATEPART(year,OrderDate)=2007
GROUP BY
CustomerID
ORDER BY 
COUNT(SalesOrderid)
--Lab 3-3
/* Retrieve the product id and product name of the top selling (by total quantity sold) product of each date.
 Sort the returned data by date in the ascending order. */
 WITH abc (a,b,c,d,e)
 AS
 (
 SELECT p.ProductID,[Name],OrderDate,SUM(OrderQty) as MaxNo,DENSE_RANK() OVER( Partition by OrderDate ORDER BY SUM(OrderQty) DESC) [rank]
 FROM Production.Product p INNER JOIN Sales.SalesOrderDetail sod ON p.ProductID = sod.ProductID
 INNER JOIN Sales.SalesOrderHeader soh ON sod.SalesOrderID=soh.SalesOrderID
 GROUP BY p.ProductID,[Name], OrderDate 
 )

 SELECT a [ProductID],b[Name],c[OrderDate],d[MaxNo],e[rank]
 FROM abc 
 WHERE e=1
 ORDER BY c 


 --Lab 3-4
 /* Write a query to retrieve the territory id, territory name, and total sale amount for each territory. 
 Use TotalDue of SalesOrderHeader to calculate the total sale.
 Sort the returned data by the total sale in the descending order.*/

 SELECT soh.TerritoryID,[Name],SUM(TotalDue) as TotalSaleAmount--,DENSE_RANK() OVER (PARTITION BY soh.TerritoryID ORDER BY SUM(TotalDue) DESC) [rank]
 FROM 
 Sales.SalesOrderHeader soh INNER JOIN Sales.SalesTerritory st ON soh.TerritoryID = st.TerritoryID
 GROUP BY
 soh.TerritoryID, [Name] 
 ORDER BY SUM(TotalDue) DESC
 
 --Lab 3-5
 /* Write a query that returns the salesperson(s) who received the
 highest bonus amount and calculate the highest bonus amount’s percentage of the total bonus amount for salespeople. Your
 solution must be able to retrieve all salespersons who received
 the highest bonus amount assuming there may be more than one salesperson who received the highest bonus amount.
 Include the salesperson’s last name and first name, highest bonus amount, percentage in the report. */

 SELECT LastName, FirstName,(Select MAX(Bonus) 
 FROM Sales.SalesPerson) as MaxBonus, (Select MAX(Bonus) FROM Sales.SalesPerson)/(SELECT SUM(BONUS) FROM Sales.SalesPerson) as PercentOfTotal 
 FROM Sales.SalesPerson sp INNER JOIN Person.Person p ON sp.BusinessEntityID=p.BusinessEntityID
 WHERE Bonus = (Select MAX(Bonus) 
 FROM Sales.SalesPerson)
