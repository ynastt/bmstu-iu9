-- �������� ���� ������ --
USE master;
GO

IF DB_ID('lab6') IS NOT NULL
DROP DATABASE lab6;
GO

CREATE DATABASE lab6
ON 
( NAME = lab6_dat,
    FILENAME = 'C:\Program Files\Microsoft SQL Server\MSSQL15.SQLEXPRESS\MSSQL\DATA\lab6_dat.mdf',
    SIZE = 10,
    MAXSIZE = 50,
    FILEGROWTH = 5 )
LOG ON
( NAME = lab6_log,
    FILENAME = 'C:\Program Files\Microsoft SQL Server\MSSQL15.SQLEXPRESS\MSSQL\DATA\lab6_log.ldf',
    SIZE = 5MB,
    MAXSIZE = 25MB,
    FILEGROWTH = 5MB );
GO

-- 1 �������� ������� � ���������������� ��������� ������ --
-- �������� �������, ��������������� ��� ��������� ���������������� �������� IDENTITY.
-- 2 ���������� �����, ��� ������� ������������ ����������� (CHECK), �������� �� ��������� (DEFAULT), ���������� ������� ��� ���������� �������� --
USE lab6;
GO 

IF OBJECT_ID(N'Book', N'U') IS NOT NULL
	DROP TABLE Book;
GO

CREATE TABLE Book (
	BookID INT IDENTITY(1,1) PRIMARY KEY NOT NULL,
	ISBN  nvarchar(17) NOT NULL,
	Title nvarchar(50) NOT NULL,
	Genre nvarchar(50) NOT NULL CHECK (Genre IN ('��������', '������� ����������', '�����', '�����', '�����-������', '�������', '�����', '������', '����������� ����������')),
	PublishingYear numeric(4) NOT NULL CHECK (PublishingYear >= 1500 AND PublishingYear <= 2020),
	PublishingHouse nvarchar(20) NULL DEFAULT(N'����������'),
	Price smallmoney NOT NULL CHECK (Price > 0),
);
GO

INSERT INTO Book(ISBN, Title, Genre, PublishingYear, PublishingHouse, Price)
VALUES ('978-5-94387-772-8', '�++ �� ��������', '����������� ����������', 2019, '����� � �������', '1700'),
	('978-5-04-112699-5', '����������� �����', '�����', 2020, '�����', '621'),
	('978-5-04-159290-5', '� - �����', CONCAT_WS(' ','�������', '����������'), 2019, '�����', '780.99')
GO

INSERT INTO Book(ISBN, Title, Genre, PublishingYear, Price) 
VALUES ('978-5-9287-3237-0', '����������� ������� ������: ������ �����������', '��������', 2011, '1472'),
	('874-2-7586-1265-9', LOWER('�������� ������� ������� �������'), UPPER('�����'), 2002, '340.45')
GO

SELECT * FROM Book
GO

CREATE TABLE BookSecond (
	BookID INT IDENTITY(1,1) PRIMARY KEY NOT NULL,
	ISBN  nvarchar(17) NOT NULL,
	Title nvarchar(50) NOT NULL,
	Genre nvarchar(50) NOT NULL CHECK (Genre IN ('��������', '������� ����������', '�����', '�����', '�����-������', '�������', '�����', '������', '����������� ����������')),
	PublishingYear numeric(4) NOT NULL CHECK (PublishingYear >= 1500 AND PublishingYear <= 2020),
	PublishingHouse nvarchar(20) NULL DEFAULT('����������'),
	Price smallmoney NOT NULL CHECK (Price > 0),
);
GO

INSERT INTO BookSecond(ISBN, Title, Genre, PublishingYear, Price) 
VALUES ('345-2-1234-1265-8', UPPER('�������� ������� �������'), UPPER('�����'), 2002, '340')
GO

SELECT CAST(Price AS DECIMAL)  AS [TEST_CAST]
	FROM Book
	WHERE Price BETWEEN 300.00 AND 1000.00; 


SELECT IDENT_CURRENT('Book') AS [IDENT_CURRENT]
SELECT @@IDENTITY AS [@@IDENTITY]
SELECT SCOPE_IDENTITY() AS [SCOPE_IDENTITY]

-- 3 �������� ������� � ��������� ������ �� ������ ����������� ����������� �������������� --

IF OBJECT_ID(N'Author', N'U') IS NOT NULL
	DROP TABLE Author;
GO

CREATE TABLE Author (
	AuthorId UNIQUEIDENTIFIER PRIMARY KEY DEFAULT (NEWID()),
	FirstName nvarchar(20) NOT NULL,
	LastName nvarchar(20) NOT NULL,
	Patronymic nvarchar(20) NULL,
	BirthYear numeric(4) NOT NULL CHECK (BirthYear > 1500 AND BirthYear < 2000),
	DeathYear numeric(4) NULL, 
	Country nvarchar(30) NULL DEFAULT ('����������'),
);
GO

INSERT INTO Author(FirstName, LastName, Patronymic, BirthYear, DeathYear, Country)
VALUES ('�����','����� ����', NULL, 1859, 1930, '��������������'),
	   ('������','�������', NULL, 1812, 1870, '��������������'),
	   ('�����','������', NULL, 1854, 1900, '��������'),
	   ('������','����', NULL, 1947, NULL, '���'),	
	   ('���������', '������', '���������', 1799, 1837, '������')
GO

INSERT INTO Author(AuthorId, FirstName, LastName, Patronymic, BirthYear, DeathYear, Country)
VALUES
    (NEWID(), '������','�� ����-��������', NULL, 1900, 1944, '�������'),
    (NEWID(), '����', '��������', '���������',1813, 1883, '������')
GO

SELECT * FROM Author
GO

-- 4 �������� ������� � ��������� ������ �� ������ ������������������ --

IF EXISTS (SELECT * FROM sys.sequences WHERE NAME = N'seq' AND TYPE='SO') 
DROP SEQUENCE seq
GO

CREATE SEQUENCE seq
	START WITH 1
	INCREMENT BY 1
	MAXVALUE 10;
GO

IF OBJECT_ID(N'BookStore') is NOT NULL
	DROP TABLE BookStore;
GO


CREATE TABLE BookStore (
	BookStoreID int PRIMARY KEY NOT NULL,
	BookStoreName nvarchar(20) NOT NULL,
	Email varchar(100) NOT NULL,
	URL_ varchar(2048) NOT NULL,
	Phone char(11) NULL
);
GO

INSERT INTO BookStore(BookStoreID, BookStoreName, Email, URL_, Phone) 
VALUES (NEXT VALUE FOR seq, '��������', 'labirint@mail.ru', 'labirint.ru', '84999209525'),
	(NEXT VALUE FOR seq, '������', 'info@moscowbooks.ru', 'moscowbooks.ru', '84957978716')
GO

SELECT * FROM BookStore
GO

-- 5 �������� ���� ��������� ������, � ������������ �� ��� ��������� ��������� �������� --
-- ��� ����������� ��������� ����������� (NO ACTION | CASCADE | SET | SET DEFAULT). --

IF OBJECT_ID(N'FK_Customer') is NOT NULL
	ALTER TABLE Orders DROP CONSTRAINT FK_Customer
IF OBJECT_ID(N'Customer') is NOT NULL
	DROP TABLE Customer;
IF OBJECT_ID(N'Orders') is NOT NULL
	DROP TABLE Orders;
GO

CREATE TABLE Customer (
	CustomerID int IDENTITY(1,1) PRIMARY KEY NOT NULL,
	Phone char(11) NOT NULL,
	LastName nvarchar(20) NOT NULL,
	FirstName nvarchar(20) NOT NULL,
	Patronymic nvarchar(20) NOT NULL,
	Email varchar(100) NOT NULL,
	City nvarchar(20) NOT NULL
);
GO

INSERT INTO Customer(Phone, LastName, FirstName, Patronymic, Email, City) 
VALUES ('89573652341','������','����', '���������', 'petya92@gmail.com', '������'),
	('89342435152','��������','�����', '��������', 'sergiriv@gmail.com', '������'),
	('89649245160','�����������','�����', '��������', 'zoi73@gmail.com', '���������'),
	('89876245331','������','������', '���������', 'kvakva@gmail.com', '�������')	-- ��� ����� � Orders
GO

SELECT * FROM Customer
GO

CREATE TABLE Orders (
	OrderNumber INT IDENTITY(1,1) PRIMARY KEY NOT NULL,
	PaymentType nvarchar(30) NOT NULL,
	MakingOrderDate date NOT NULL  DEFAULT(CONVERT(date,GETDATE())),
	DeliveryDate date NOT NULL,
	customer_id int NULL DEFAULT 1,
	CONSTRAINT FK_Customer FOREIGN KEY (customer_id) REFERENCES Customer (CustomerID) 
	ON DELETE CASCADE
	--ON DELETE SET NULL
	--ON DELETE SET DEFAULT,
	--ON DELETE NO ACTION -- �� �������  � (���� ��������� ����� ���, �� �������� ����� ���������)
);
GO

INSERT INTO Orders(PaymentType, DeliveryDate, customer_id) 
VALUES ('��������', CONVERT(date, N'10-12-2022'), 2),
	('�� �����', CONVERT(date, N'05-11-2022'), 1),
	('�� �����', CONVERT(date, N'07-12-2022'), 3)
GO

SELECT * FROM Orders
GO



DELETE FROM Customer
WHERE City='������'
GO

SELECT * FROM Orders
GO

SELECT * FROM Customer
GO

/*DELETE FROM Customer	-- ��� NO ACTION
WHERE City='�������'
GO

SELECT * FROM Orders
GO

SELECT * FROM Customer
GO*/
