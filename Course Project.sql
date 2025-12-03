/*
GitHub Link
https://github.com/MarkTretiak/OnlineStore.git
*/

--FOR DELETING ALL TABLES AND etc. FOR RUNNING ALL AGAIN
IF DB_ID('OnlineStore') IS NULL
BEGIN
    PRINT 'Database not found.';
    PRINT 'Database created.';
    CREATE DATABASE OnlineStore;
END
ELSE
BEGIN
    PRINT 'Database already exists.';
END
GO

USE OnlineStore;
GO

DROP TABLE IF EXISTS OrderItems, Payments, Orders, Products, Categories, Customers, Logs;

DROP VIEW IF EXISTS OrderDetails;
DROP TRIGGER IF EXISTS UpdateOrderTotal;
DROP PROCEDURE IF EXISTS GetOrdersPaged;
DROP FUNCTION IF EXISTS GetOrderTotal;

------------------------------------------------------------
-- 1. DATABASE
------------------------------------------------------------
------------------------------------------------------------
-- CREATING TABLES
------------------------------------------------------------

-- Customers
CREATE TABLE Customers (
    CustomerID INT IDENTITY(1,1) PRIMARY KEY,
    Name       VARCHAR(100) NOT NULL,
    Email      VARCHAR(120) NOT NULL UNIQUE,
    City       VARCHAR(60),
    Registered DATETIME DEFAULT GETDATE()
);

-- Categories
CREATE TABLE Categories (
    CategoryID   INT IDENTITY(1,1) PRIMARY KEY,
    CategoryName VARCHAR(100) NOT NULL
);

-- Products
CREATE TABLE Products (
    ProductID   INT IDENTITY(1,1) PRIMARY KEY,
    ProductName VARCHAR(120) NOT NULL,
    SKU         VARCHAR(40) NOT NULL UNIQUE,
    CategoryID  INT NOT NULL,
    Price       DECIMAL(10,2) NOT NULL,
    Stock       INT NOT NULL DEFAULT 0,
    FOREIGN KEY (CategoryID) REFERENCES Categories(CategoryID)
);

-- Orders
CREATE TABLE Orders (
    OrderID     INT IDENTITY(1,1) PRIMARY KEY,
    CustomerID  INT NOT NULL,
    OrderDate   DATETIME DEFAULT GETDATE(),
    Total       DECIMAL(10,2) DEFAULT 0,
    FOREIGN KEY (CustomerID) REFERENCES Customers(CustomerID)
);

-- Many-to-Many: OrderItems (Orders ↔ Products)
CREATE TABLE OrderItems (
    OrderItemID INT IDENTITY(1,1) PRIMARY KEY,
    OrderID     INT NOT NULL,
    ProductID   INT NOT NULL,
    Qty         INT NOT NULL,
    Price       DECIMAL(10,2) NOT NULL,
    UNIQUE (OrderID, ProductID),
    FOREIGN KEY (OrderID) REFERENCES Orders(OrderID),
    FOREIGN KEY (ProductID) REFERENCES Products(ProductID)
);

-- Payments
CREATE TABLE Payments (
    PaymentID   INT IDENTITY(1,1) PRIMARY KEY,
    OrderID     INT NOT NULL,
    Amount      DECIMAL(10,2) NOT NULL,
    PaidAt      DATETIME DEFAULT GETDATE(),
    Method      VARCHAR(20),
    FOREIGN KEY (OrderID) REFERENCES Orders(OrderID)
);

-- Table used for TRUNCATE
CREATE TABLE Logs (
    LogID       INT IDENTITY(1,1) PRIMARY KEY,
    Message     VARCHAR(200),
    CreatedAt   DATETIME DEFAULT GETDATE(),
    CustomerID INT FOREIGN KEY REFERENCES Customers(CustomerID)
);

------------------------------------------------------------
-- INDEXES
------------------------------------------------------------

CREATE UNIQUE INDEX INDEX_Customer_Email ON Customers(Email);
CREATE INDEX INDEX_Products_Name ON Products(ProductName);
CREATE INDEX INDEX_Orders_Date ON Orders(OrderDate);

SELECT * FROM Logs;
------------------------------------------------------------
-- 2. DATA MANIPULATION
------------------------------------------------------------

------------------------------------------------------------
-- INSERTING INFORAMTION TO THE TABLES
------------------------------------------------------------

SET NOCOUNT ON;

INSERT INTO Customers (Name, Email, City) 
VALUES ('John Doe', 'john@example.com', 'Vilnius'),
       ('Anna White', 'anna@example.com', 'Kaunas'),
       ('Johny Black', 'johny@example.com', 'Klaipeda'),
       ('Emma Myers', 'emma@example.com', 'Vilnius'),
       ('Skott Brown', 'skott@example', 'Kaunas');



INSERT INTO Categories (CategoryName) 
VALUES ('Laptops'),
       ('Smart Phones'),
       ('Accessories'),
       ('Watches'),
       ('Steering Wheels');


INSERT INTO Products (ProductName, SKU, CategoryID, Price, Stock) 
VALUES ('Lenovo Legion 5 Pro', 'SKU-L1', 1, 1600, 20),
       ('Asus Rog Zephyrus G14', 'SKU-L2', 1, 1500, 15),
       ('Xiaomi 12T Pro', 'SKU-SM1', 2, 900, 90),
       ('Mouse Wireless', 'SKU-A1', 3, 25, 200),
       ('Xiaomi Redmi Watch 5 Active', 'SKU-W1', 4, 30, 140),
       ('SPEED LINK steering wheel Trailblazer Racing PS4/3', 'SKU-SW', 5, 75, 20);


INSERT INTO Orders (CustomerID) 
VALUES (1), 
       (2),
       (3);


INSERT INTO OrderItems (OrderID, ProductID, Qty, Price) 
VALUES (1, 1, 1, 1200),
       (1, 2, 2, 90),
       (2, 2, 1, 90),
       (3, 3, 2, 25);


INSERT INTO Payments (OrderID, Amount, Method)
VALUES (1, 1250, 'CARD'), 
       (2, 90, 'CASH'),
       (3, 25, 'CASH');


INSERT INTO Logs (CustomerID, Message)
VALUES 
(1, 'Order processed'),
(2, 'Payment received'),
(1, 'System check');

SET NOCOUNT OFF;

/*
SELECT * FROM Customers;
SELECT * FROM Categories;
SELECT * FROM Products;
SELECT * FROM Orders;
SELECT * FROM OrderItems;
SELECT * FROM Payments;
SELECT * FROM Logs;
*/

------------------------------------------------------------
-- UPDATING
------------------------------------------------------------
SELECT * FROM Products;

UPDATE Products SET Price = Price * 0.9 WHERE CategoryID = 3;

SELECT * FROM Products;

UPDATE Products SET Stock = Stock + 50 WHERE SKU = 'SKU-A1';

SELECT * FROM Products;
------------------------------------------------------------
-- DELETING AND TRUNCATING
------------------------------------------------------------

SELECT * FROM Payments;
SET NOCOUNT ON;

DELETE FROM Payments WHERE Method = 'CASH';

SET NOCOUNT OFF;
SELECT * FROM Payments;


SELECT * FROM Logs;

TRUNCATE TABLE Logs;

SELECT * FROM Logs;

/*
SELECT * FROM Customers;
SELECT * FROM Categories;
SELECT * FROM Products;
SELECT * FROM Orders;
SELECT * FROM OrderItems;
SELECT * FROM Payments;
SELECT * FROM Logs;
*/

------------------------------------------------------------
-- 3. SELECT QUERIES
------------------------------------------------------------

-- Aggregates (COUNT, SUM, AVG) + GROUP BY + ORDER BY
SELECT 
    c.CategoryName,
    COUNT(*)     AS TotalProducts,
    AVG(p.Price) AS AvgPrice,
    SUM(p.Stock) AS TotalStock
FROM Products p
JOIN Categories c ON p.CategoryID = c.CategoryID
GROUP BY c.CategoryName
ORDER BY AvgPrice DESC;

-- Pagination
SELECT ProductID, ProductName, Price
FROM Products
ORDER BY ProductID
OFFSET 0 ROWS FETCH NEXT 2 ROWS ONLY;

-- Aggregate customer spending
SELECT 
    cu.Name,
    SUM(o.Total) AS TotalSpent
FROM Customers cu
LEFT JOIN Orders o ON cu.CustomerID = o.CustomerID
GROUP BY cu.Name
ORDER BY TotalSpent DESC;

------------------------------------------------------------
-- 4. JOINS
------------------------------------------------------------

-- Join two tables
SELECT cu.Name, o.OrderID, o.OrderDate
FROM Customers cu
JOIN Orders o ON cu.CustomerID = o.CustomerID;

-- Join three tables
SELECT cu.Name, p.ProductName, oi.Qty
FROM Customers cu
JOIN Orders o ON cu.CustomerID = o.CustomerID
JOIN OrderItems oi ON oi.OrderID = o.OrderID
JOIN Products p ON p.ProductID = oi.ProductID;

-- View (3+ tables)
GO
CREATE VIEW OrderDetails AS
SELECT cu.Name, o.OrderID, p.ProductName, oi.Qty, oi.Price, oi.Qty * oi.Price AS LineTotal
FROM Customers cu
JOIN Orders o ON cu.CustomerID = o.CustomerID
JOIN OrderItems oi ON oi.OrderID = o.OrderID
JOIN Products p ON oi.ProductID = p.ProductID;
GO

SELECT * FROM OrderDetails;

------------------------------------------------------------
-- 5. PROCEDURE / FUNCTION / TRIGGER / TRANSACTION
------------------------------------------------------------

-- Function: calculates order total
GO
CREATE OR ALTER FUNCTION GetOrderTotal(@OrderID INT)
RETURNS DECIMAL(10,2)
AS
BEGIN
    RETURN (SELECT SUM(Qty * Price) FROM OrderItems WHERE OrderID = @OrderID);
END;
GO

-- Trigger: updates Orders.Total when OrderItems change
GO
CREATE OR ALTER TRIGGER UpdateOrderTotal ON OrderItems
AFTER INSERT, UPDATE, DELETE
AS
BEGIN
    UPDATE Orders
    SET Total = dbo.GetOrderTotal(Orders.OrderID)
    FROM Orders
    WHERE Orders.OrderID IN (SELECT OrderID FROM inserted UNION SELECT OrderID FROM deleted);
END;
GO

/*
SELECT * FROM Customers;
SELECT * FROM Categories;
SELECT * FROM Products;
SELECT * FROM Orders;
SELECT * FROM OrderItems;
SELECT * FROM Payments;
SELECT * FROM Logs;
*/