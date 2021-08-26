--*************************************************************************--
-- Course: Foundations of Databases & SQL Programming
-- Title: Assignment07
-- Author: Daniel Hively
-- Desc: This file demonstrates how to use Functions
-- Change Log: When,Who,What
-- 2021-08-22, Daniel Hively, Created File
-- Github: https://github.com/danjhively/DBFoundations
--**************************************************************************--

/************************************************************************************************/
-- Start of assignment code that creates the database
-- used for the assignment questions
/************************************************************************************************/

Begin Try
	Use Master;
	If Exists(Select Name From SysDatabases Where Name = 'Assignment07DB_DHively')
	 Begin 
	  Alter Database [Assignment07DB_DHively] set Single_user With Rollback Immediate;
	  Drop Database Assignment07DB_DHively;
	 End
	Create Database Assignment07DB_DHively;
End Try
Begin Catch
	Print Error_Number();
End Catch
go
Use Assignment07DB_DHively;

-- Create Tables (Module 01)-- 
Create Table Categories
([CategoryID] [int] IDENTITY(1,1) NOT NULL 
,[CategoryName] [nvarchar](100) NOT NULL
);
go

Create Table Products
([ProductID] [int] IDENTITY(1,1) NOT NULL 
,[ProductName] [nvarchar](100) NOT NULL 
,[CategoryID] [int] NULL  
,[UnitPrice] [money] NOT NULL
);
go

Create Table Employees -- New Table
([EmployeeID] [int] IDENTITY(1,1) NOT NULL 
,[EmployeeFirstName] [nvarchar](100) NOT NULL
,[EmployeeLastName] [nvarchar](100) NOT NULL 
,[ManagerID] [int] NULL  
);
go

Create Table Inventories
([InventoryID] [int] IDENTITY(1,1) NOT NULL
,[InventoryDate] [Date] NOT NULL
,[EmployeeID] [int] NOT NULL
,[ProductID] [int] NOT NULL
,[ReorderLevel] int NOT NULL -- New Column 
,[Count] [int] NOT NULL
);
go

-- Add Constraints (Module 02) -- 
Begin  -- Categories
	Alter Table Categories 
	 Add Constraint pkCategories 
	  Primary Key (CategoryId);

	Alter Table Categories 
	 Add Constraint ukCategories 
	  Unique (CategoryName);
End
go 

Begin -- Products
	Alter Table Products 
	 Add Constraint pkProducts 
	  Primary Key (ProductId);

	Alter Table Products 
	 Add Constraint ukProducts 
	  Unique (ProductName);

	Alter Table Products 
	 Add Constraint fkProductsToCategories 
	  Foreign Key (CategoryId) References Categories(CategoryId);

	Alter Table Products 
	 Add Constraint ckProductUnitPriceZeroOrHigher 
	  Check (UnitPrice >= 0);
End
go

Begin -- Employees
	Alter Table Employees
	 Add Constraint pkEmployees 
	  Primary Key (EmployeeId);

	Alter Table Employees 
	 Add Constraint fkEmployeesToEmployeesManager 
	  Foreign Key (ManagerId) References Employees(EmployeeId);
End
go

Begin -- Inventories
	Alter Table Inventories 
	 Add Constraint pkInventories 
	  Primary Key (InventoryId);

	Alter Table Inventories
	 Add Constraint dfInventoryDate
	  Default GetDate() For InventoryDate;

	Alter Table Inventories
	 Add Constraint fkInventoriesToProducts
	  Foreign Key (ProductId) References Products(ProductId);

	Alter Table Inventories 
	 Add Constraint ckInventoryCountZeroOrHigher 
	  Check ([Count] >= 0);

	Alter Table Inventories
	 Add Constraint fkInventoriesToEmployees
	  Foreign Key (EmployeeId) References Employees(EmployeeId);
End 
go

-- Adding Data (Module 04) -- 
Insert Into Categories 
(CategoryName)
Select CategoryName 
 From Northwind.dbo.Categories
 Order By CategoryID;
go

Insert Into Products
(ProductName, CategoryID, UnitPrice)
Select ProductName,CategoryID, UnitPrice 
 From Northwind.dbo.Products
  Order By ProductID;
go

Insert Into Employees
(EmployeeFirstName, EmployeeLastName, ManagerID)
Select E.FirstName, E.LastName, IsNull(E.ReportsTo, E.EmployeeID) 
 From Northwind.dbo.Employees as E
  Order By E.EmployeeID;
go

Insert Into Inventories
(InventoryDate, EmployeeID, ProductID, ReorderLevel, [Count])
Select '20170101' as InventoryDate, 5 as EmployeeID, ProductID, ReorderLevel, ABS(CHECKSUM(NewId())) % 100 as RandomValue
From Northwind.dbo.Products
Union
Select '20170201' as InventoryDate, 7 as EmployeeID, ProductID, ReorderLevel, ABS(CHECKSUM(NewId())) % 100 as RandomValue
From Northwind.dbo.Products
Union
Select '20170301' as InventoryDate, 9 as EmployeeID, ProductID, ReorderLevel, ABS(CHECKSUM(NewId())) % 100 as RandomValue
From Northwind.dbo.Products
Order By 1, 2
go

-- Adding Views (Module 06) -- 
Create View vCategories With SchemaBinding
 AS
  Select CategoryID, CategoryName From dbo.Categories;
go
Create View vProducts With SchemaBinding
 AS
  Select ProductID, ProductName, CategoryID, UnitPrice From dbo.Products;
go
Create View vEmployees With SchemaBinding
 AS
  Select EmployeeID, EmployeeFirstName, EmployeeLastName, ManagerID From dbo.Employees;
go
Create View vInventories With SchemaBinding 
 AS
  Select InventoryID, InventoryDate, EmployeeID, ProductID, ReorderLevel, [Count] From dbo.Inventories;
go

-- Show the Current data in the Categories, Products, and Inventories Tables
Select * From vCategories;
go
Select * From vProducts;
go
Select * From vEmployees;
go
Select * From vInventories;
go

/************************************************************************************************/
-- End of assignment code that creates the database
-- used for the assignment questions
/************************************************************************************************/


/********************************* Questions and Answers *******************************************************************/
/*
NOTES------------------------------------------------------------------------------------ 
 1) You must use the BASIC views for each table.
 2) Remember that Inventory Counts are Randomly Generated. So, your counts may not match mine
 3) To make sure the Dates are sorted correctly, you can use Functions in the Order By clause!
------------------------------------------------------------------------------------------
*/
/**********************************************************************************************************************/
-- Question 1 (5% of pts):
-- show a list of Product names and the price of each product
-- Use a function to format the price as US dollars?
-- Order the result by the product name.

/*
-- Initial check of table
Go
Select * From vProducts;
Go

-- Narrow down columns
Go
Select ProductName, UnitPrice From vProducts;
Go

-- Implement US dollars formatting
Go
Select ProductName, Format(UnitPrice, 'c', 'en-US') As 'UnitPrice' From vProducts;
Go
*/

/******************************************   Answer 1   ******************************************/
-- Add ordering by product name
Go
Select ProductName, Format(UnitPrice, 'c', 'en-US') As 'UnitPrice' From vProducts
	Order By ProductName;
Go

/**********************************************************************************************************************/
-- Question 2 (10% of pts): 
-- Show a list of Category and Product names, and the price of each product
-- Format the price as US dollars.
-- Order the result by the Category and Product.

/*
-- Starting from Answer 1 we get a list of products names, prices in US dollars, ordered by product
Go
Select ProductName, Format(UnitPrice, 'c', 'en-US') As 'UnitPrice' From vProducts
	Order By ProductName;
Go

-- We next add in category names
Go
Select vCategories.CategoryName, vProducts.ProductName, Format(vProducts.UnitPrice, 'c', 'en-US') As 'UnitPrice' 
From vProducts
	Inner Join vCategories
		On vProducts.CategoryID = vCategories.CategoryID
	Order By vProducts.ProductName;
Go
*/

/******************************************   Answer 2   ******************************************/
-- Lastly we also add category to the ordering
Go
Select vCategories.CategoryName, vProducts.ProductName, Format(vProducts.UnitPrice, 'c', 'en-US') As 'UnitPrice' 
From vProducts
	Inner Join vCategories
		On vProducts.CategoryID = vCategories.CategoryID
	Order By vCategories.CategoryName, vProducts.ProductName;
Go

/**********************************************************************************************************************/
-- Question 3 (10% of pts): 
-- Use functions to show a list of Product names, each Inventory Date, and the Inventory Count
-- Format the date like 'January, 2017'.
-- Order the results by the Product, Date, and Count.

/*
-- Start with looking at Inventories
Go
Select * From vInventories;
Go

-- Narrow down the columns
Go
Select ProductID, InventoryDate, Count As 'InventoryCount' From vInventories;
Go

-- Implement date formatting
Go
Select ProductID, Format(InventoryDate, 'MMMM, yyyy') As InventoryDate, Count As InventoryCount From vInventories;
Go

-- Add in product names
Go
Select vProducts.ProductName, Format(vInventories.InventoryDate, 'MMMM, yyyy') As 'InventoryDate', vInventories.Count As 'InventoryCount' 
From vInventories
	Inner Join vProducts
		On vInventories.ProductID = vProducts.ProductID;
Go
*/

/******************************************   Answer 3   ******************************************/
-- Add ordering
Go
Select vProducts.ProductName, Format(vInventories.InventoryDate, 'MMMM, yyyy') As 'InventoryDate', vInventories.Count As 'InventoryCount' 
From vInventories
	Inner Join vProducts
		On vInventories.ProductID = vProducts.ProductID
	Order By vProducts.ProductName, vInventories.InventoryDate, vInventories.Count;
Go

/**********************************************************************************************************************/
-- Question 4 (10% of pts): 
-- CREATE A VIEW called vProductInventories 
-- Shows a list of Product names, each Inventory Date, and the Inventory Count, 
-- Format the date like 'January, 2017'.
-- Order the results by the Product, Date, and Count!

/*
-- Starting from Answer 3, we get a select statement that fulfills the critera but needs to be converted to a view
Go
Select vProducts.ProductName, Format(vInventories.InventoryDate, 'MMMM, yyyy') As 'InventoryDate', vInventories.Count As 'InventoryCount' 
From vInventories
	Inner Join vProducts
		On vInventories.ProductID = vProducts.ProductID
	Order By vProducts.ProductName, vInventories.InventoryDate, vInventories.Count;
Go
*/

/******************************************   Answer 4   ******************************************/
-- The Select statement is made into a view
Go
Create View vProductInventories
As
	Select Top 100000 vProducts.ProductName, Format(vInventories.InventoryDate, 'MMMM, yyyy') As 'InventoryDate', vInventories.Count As 'InventoryCount' 
	From vInventories
		Inner Join vProducts
			On vInventories.ProductID = vProducts.ProductID
		Order By vProducts.ProductName, vInventories.InventoryDate, vInventories.Count;
Go

-- Checks the view
Go
Select * From vProductInventories;
Go

/**********************************************************************************************************************/
-- Question 5 (10% of pts): 
-- CREATE A VIEW called vCategoryInventories. 
-- Shows a list of Category names, Inventory Dates, and a TOTAL Inventory Count BY CATEGORY
-- Format the date like 'January, 2017'.

/*
-- Start with looking at Inventories
Go
Select * From vInventories;
Go

-- Narrow down the columns to use
Go
Select ProductID, InventoryDate, Count From vInventories;
Go

-- Add date formatting
Go
Select ProductID, Format(InventoryDate, 'MMMM, yyyy') As 'InventoryDate', Count From vInventories;
Go

-- Links tables to get category name
Go
Select vCategories.CategoryName, Format(vInventories.InventoryDate, 'MMMM, yyyy') As 'InventoryDate', vInventories.Count 
From vInventories
	Inner Join vProducts
		On vInventories.ProductID = vProducts.ProductID
	Inner Join vCategories
		On vProducts.CategoryID = vCategories.CategoryID;
Go

-- Implements total inventory count by category field
Go
Select vCategories.CategoryName, Format(vInventories.InventoryDate, 'MMMM, yyyy') As 'InventoryDate', 
	Sum(vInventories.Count) As 'InventoryCountByCategory'
From vInventories
	Inner Join vProducts
		On vInventories.ProductID = vProducts.ProductID
	Inner Join vCategories
		On vProducts.CategoryID = vCategories.CategoryID
	Group By vCategories.CategoryName, vInventories.InventoryDate;
Go

-- Adds ordering
Go
Select vCategories.CategoryName, Format(vInventories.InventoryDate, 'MMMM, yyyy') As 'InventoryDate', 
	Sum(vInventories.Count) As 'InventoryCountByCategory'
From vInventories
	Inner Join vProducts
		On vInventories.ProductID = vProducts.ProductID
	Inner Join vCategories
		On vProducts.CategoryID = vCategories.CategoryID
	Group By vCategories.CategoryName, vInventories.InventoryDate
	Order By vCategories.CategoryName, vInventories.InventoryDate;
Go
*/

/******************************************   Answer 5   ******************************************/
-- Turns Select statement into a view
Go
Create View vCategoryInventories
As
	Select Top 100000 vCategories.CategoryName, Format(vInventories.InventoryDate, 'MMMM, yyyy') As 'InventoryDate', 
		Sum(vInventories.Count) As 'InventoryCountByCategory'
	From vInventories
		Inner Join vProducts
			On vInventories.ProductID = vProducts.ProductID
		Inner Join vCategories
			On vProducts.CategoryID = vCategories.CategoryID
		Group By vCategories.CategoryName, vInventories.InventoryDate
		Order By vCategories.CategoryName, vInventories.InventoryDate;
Go

-- Checks the view
Go
Select * From vCategoryInventories;
Go

/**********************************************************************************************************************/
-- Question 6 (10% of pts): 
-- CREATE ANOTHER VIEW called vProductInventoriesWithPreviouMonthCounts 
-- Show a list of Product names, Inventory Dates, Inventory Count, AND the Previous Month Count.
-- Use functions to set any January NULL counts to zero. 
-- Order the results by the Product, Date, and Count. 
-- This new view must use your vProductInventories view!

/*
-- Starting from the existing view
Go
Select * From vProductInventories;
Go

-- Specifiy the columns
Go
Select ProductName, InventoryDate, InventoryCount From vProductInventories;
Go

-- Adds previous month count and a zeroing out of Jan values
Go
Select ProductName, InventoryDate, InventoryCount, 
	[PreviousMonthCount] = IIF(Month(InventoryDate) = 1, 0, Lag(Sum(InventoryCount)) Over (Order By ProductName, Month(InventoryDate)))
From vProductInventories
	Group By ProductName, InventoryDate, InventoryCount;
Go
*/

/******************************************   Answer 6   ******************************************/
-- Turns Select statement into a view
Go
Create View vProductInventoriesWithPreviousMonthCounts
As
	Select Top 100000 ProductName, InventoryDate, InventoryCount, 
		[PreviousMonthCount] = IIF(Month(InventoryDate) = 1, 0, Lag(Sum(InventoryCount)) Over (Order By ProductName, Month(InventoryDate)))
	From vProductInventories
		Group By ProductName, InventoryDate, InventoryCount;
Go

-- Checks the view
Go
Select * From vProductInventoriesWithPreviousMonthCounts;
Go

/**********************************************************************************************************************/
-- Question 7 (15% of pts): 
-- CREATE a VIEW called vProductInventoriesWithPreviousMonthCountsWithKPIs
-- Show columns for the Product names, Inventory Dates, Inventory Count, Previous Month Count. 
-- The Previous Month Count is a KPI. The result can show only KPIs with a value of either 1, 0, or -1. 
-- Display months with increased counts as 1, same counts as 0, and decreased counts as -1. 
-- Order the results by the Product, Date, and Count!

/*
-- Starting from the existing view
Go
Select * From vProductInventoriesWithPreviousMonthCounts;
Go

-- Specify the columns
Go
Select ProductName, InventoryDate, InventoryCount, PreviousMonthCount From vProductInventoriesWithPreviousMonthCounts;
Go

-- Add the KPI field by comparing current count vs previous count
Go
Select ProductName, InventoryDate, InventoryCount, PreviousMonthCount, [CountVsPreviousCountKPI] = Case
	When InventoryCount > PreviousMonthCount Then 1
	When InventoryCount = PreviousMonthCount Then 0
	When InventoryCount < PreviousMonthCount Then -1
	End
From vProductInventoriesWithPreviousMonthCounts;
Go
*/

/******************************************   Answer 7   ******************************************/
-- Turns Select statement into a view
Go
Create View vProductInventoriesWithPreviousMonthCountsWithKPIs
As
	Select Top 10000 ProductName, InventoryDate, InventoryCount, PreviousMonthCount, [CountVsPreviousCountKPI] = Case
		When InventoryCount > PreviousMonthCount Then 1
		When InventoryCount = PreviousMonthCount Then 0
		When InventoryCount < PreviousMonthCount Then -1
		End
	From vProductInventoriesWithPreviousMonthCounts;
Go

-- Checks the view
Go
Select * From vProductInventoriesWithPreviousMonthCountsWithKPIs;
Go

/**********************************************************************************************************************/
-- Question 8 (25% of pts): 
-- CREATE a User Defined Function (UDF) called fProductInventoriesWithPreviousMonthCountsWithKPIs.
-- Show columns for the Product names, Inventory Dates, Inventory Count, the Previous Month Count. 
-- The Previous Month Count is a KPI. The result can show only KPIs with a value of either 1, 0, or -1. 
-- Display months with increased counts as 1, same counts as 0, and decreased counts as -1. 
-- The function must use the ProductInventoriesWithPreviousMonthCountsWithKPIs view!

/*
-- Starting from the existing view
Go
Select * From vProductInventoriesWithPreviousMonthCountsWithKPIs;
Go

-- Test Select of a pull with restricted values
Go
Select * From vProductInventoriesWithPreviousMonthCountsWithKPIs
	Where CountVsPreviousCountKPI = 1;
Select * From vProductInventoriesWithPreviousMonthCountsWithKPIs
	Where CountVsPreviousCountKPI = 0;
Select * From vProductInventoriesWithPreviousMonthCountsWithKPIs
	Where CountVsPreviousCountKPI = -1;
Go
*/

/******************************************   Answer 8   ******************************************/
-- Turns Select statement into a Function
Go
Create Function dbo.fProductInventoriesWithPreviousMonthCountsWithKPIs(@cKPI int)
	Returns Table
	As
		Return(
			Select ProductName, InventoryDate, InventoryCount, PreviousMonthCount, CountVsPreviousCountKPI
			From Assignment07DB_DHively.dbo.vProductInventoriesWithPreviousMonthCountsWithKPIs
				Where CountVsPreviousCountKPI = @cKPI
		);
Go

-- Checks the function
Go
Select * From fProductInventoriesWithPreviousMonthCountsWithKPIs(1);
Select * From fProductInventoriesWithPreviousMonthCountsWithKPIs(0);
Select * From fProductInventoriesWithPreviousMonthCountsWithKPIs(-1);
Go

/***************************************************************************************/
