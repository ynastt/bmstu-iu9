-- Создать в базах данных пункта 1 задания 13 связанные таблицы.
USE master;
GO

IF DB_ID('db1') IS NOT NULL
DROP DATABASE db1;
GO

IF DB_ID('db2') IS NOT NULL
DROP DATABASE db2;
GO

CREATE DATABASE db1
ON 
( NAME = db1_dat,
    FILENAME = 'C:\Program Files\Microsoft SQL Server\MSSQL15.SQLEXPRESS\MSSQL\DATA\db1_dat.mdf',
    SIZE = 10,
    MAXSIZE = 50,
    FILEGROWTH = 5 )
LOG ON
( NAME = db1_log,
    FILENAME = 'C:\Program Files\Microsoft SQL Server\MSSQL15.SQLEXPRESS\MSSQL\DATA\db1_log.ldf',
    SIZE = 5MB,
    MAXSIZE = 25MB,
    FILEGROWTH = 5MB );
GO 

CREATE DATABASE db2
ON 
( NAME = db2_dat,
    FILENAME = 'C:\Program Files\Microsoft SQL Server\MSSQL15.SQLEXPRESS\MSSQL\DATA\db2_dat.mdf',
    SIZE = 10,
    MAXSIZE = 50,
    FILEGROWTH = 5 )
LOG ON
( NAME = db2_log,
    FILENAME = 'C:\Program Files\Microsoft SQL Server\MSSQL15.SQLEXPRESS\MSSQL\DATA\db2_log.ldf',
    SIZE = 5MB,
    MAXSIZE = 25MB,
    FILEGROWTH = 5MB );
GO

USE db1
GO

DROP TABLE IF EXISTS Customer;
GO

CREATE TABLE Customer (
	CustomerID INT PRIMARY KEY,
	Phone char(11) NOT NULL,
	LastName nvarchar(20) NOT NULL,
	FirstName nvarchar(20) NOT NULL,
	Patronymic nvarchar(20) NOT NULL,
	Email varchar(100) UNIQUE NOT NULL
);
GO

USE db2
GO

DROP TABLE IF EXISTS Orders;
GO

CREATE TABLE Orders (
	OrderID INT PRIMARY KEY,
	PaymentType int NOT NULL DEFAULT(1),
	MakingOrderDate date NOT NULL  DEFAULT(CONVERT(date,GETDATE())),
	DeliveryDate date NOT NULL,
	customer_id int NOT NULL,
);
GO

-- Создать необходимые элементы базы данных (представления, триггеры), обеспечивающие работу
-- с данными связанных таблиц (выборку, вставку, изменение, удаление).
DROP VIEW IF EXISTS CustomerOrdersView
GO

CREATE VIEW CustomerOrdersView AS
	SELECT one.CustomerID, one.Phone, one.LastName, one.FirstName, one.Patronymic, one.Email,
		   two.OrderID, two.PaymentType, two.MakingOrderDate, two.DeliveryDate 
	FROM db1.dbo.Customer one, db2.dbo.Orders two
	WHERE one.CustomerID = two.customer_id
GO

USE db1
GO

-- вставка без особенностей
DROP TRIGGER IF EXISTS CustomerUpd -- нельзя менять ID
DROP TRIGGER IF EXISTS CustomerDel -- удалить заказы покупателя
GO

CREATE TRIGGER CustomerUpd ON Customer
FOR UPDATE
AS
	IF UPDATE(CustomerID)
		BEGIN
			RAISERROR('ERROR - YOU ARE NOT ALLOWED TO CHANGE CustomerID', 16, 1, 'CustomerUpd')
			ROLLBACK
		END
GO

CREATE TRIGGER CustomerDel ON Customer
FOR DELETE
AS
	DELETE table2 FROM db2.dbo.Orders as table2
		INNER JOIN deleted as del on
		table2.customer_id = del.CustomerID
GO

USE db2
GO

DROP TRIGGER IF EXISTS OrdersIns -- вставка только, если есть покупатель
DROP TRIGGER IF EXISTS OrdersUpd --  нельзя менять ID  и изменение только если есть соответствующий покупатель
GO

CREATE TRIGGER OrdersIns ON Orders
FOR INSERT
AS
	IF EXISTS (SELECT * FROM db1.dbo.Customer, inserted  
				WHERE db1.dbo.Customer.CustomerID = inserted.customer_id)
				PRINT('все ок вставка заказа существующего покупателя')
	ELSE
		BEGIN
			RAISERROR('ERROR - CUSTOMER DOES NOT EXIST. YOU ARE NOT ALLOWED TO ADD ORDERS', 16, 1, 'OrdersIns')
			ROLLBACK
		END
GO

CREATE TRIGGER OrdersUpd ON Orders
FOR UPDATE
AS
	IF UPDATE(OrderID)
		BEGIN
			RAISERROR('ERROR - YOU ARE NOT ALLOWED TO CHANGE OrderID', 16, 1, 'OrdersUpd')
			ROLLBACK
		END
	IF UPDATE(customer_id) AND EXISTS (SELECT 1 FROM db1.dbo.Customer RIGHT JOIN inserted 
				ON db1.dbo.Customer.CustomerID = inserted.customer_id 
				WHERE db1.dbo.Customer.CustomerID IS NULL)
		BEGIN
			RAISERROR('ERROR - CUSTOMER DOES NOT EXIST. YOU ARE NOT ALLOWED TO ADD ORDERS', 16, 2, 'OrdersUpd')
			ROLLBACK
		END
GO

INSERT INTO db1.dbo.Customer(CustomerID, Phone, LastName, FirstName, Patronymic, Email)  
VALUES (1, '89573652341','Иванов','Иван', 'Иванович', 'ivva92@gmail.com'),
	(2, '89342435152','Сергеев','Сергей', 'Сергеевич', 'sergiriv@gmail.com'),
	(3, '89649245160','Зурхарниева','Ольга', 'Игоревна', 'zoi73@gmail.com')
GO

INSERT INTO Orders(OrderID, DeliveryDate, customer_id)
VALUES (1, CONVERT(date, N'01-01-2023'), 2),
		(2, CONVERT(date, N'12-01-2023'), 1)
GO

--raiserror
--INSERT INTO Orders(OrderID, DeliveryDate, customer_id)
--VALUES (1, CONVERT(date, N'11-01-2023'), 4)
--GO

SELECT * FROM CustomerOrdersView ORDER BY CustomerID
GO

--raiserror
--UPDATE db1.dbo.Customer SET CustomerID = 7 WHERE Email = 'zoi73@gmail.com'

UPDATE db1.dbo.Customer SET LastName = 'Буканова' WHERE CustomerID = 2

--raiserror
--UPDATE Orders SET OrderID = 4 WHERE OrderID = 1;

UPDATE Orders SET customer_id = 3 WHERE OrderID = 1;

--raiserror
--UPDATE Orders SET customer_id = 5 WHERE OrderID = 1;

SELECT * FROM CustomerOrdersView ORDER BY CustomerID

SELECT * FROM db1.dbo.Customer
GO

DELETE FROM db1.dbo.Customer WHERE CustomerID = 2

SELECT * FROM db1.dbo.Customer
GO

SELECT * FROM CustomerOrdersView ORDER BY CustomerID
GO

SELECT * FROM Orders
GO

DELETE FROM Orders WHERE customer_id = 3

SELECT * FROM Orders
GO