-- 1 creation of a database --
USE master;
GO

IF DB_ID('BooksOnlineService') IS NOT NULL
DROP DATABASE BooksOnlineService;
GO

CREATE DATABASE BooksOnlineService
ON 
( NAME = BooksOnlineService_dat,
    FILENAME = 'C:\Program Files\Microsoft SQL Server\MSSQL15.SQLEXPRESS\MSSQL\DATA\BooksOnlineService_dat.mdf',
    SIZE = 10,
    MAXSIZE = 50,
    FILEGROWTH = 5 )
LOG ON
( NAME = BooksOnlineService_log,
    FILENAME = 'C:\Program Files\Microsoft SQL Server\MSSQL15.SQLEXPRESS\MSSQL\DATA\BooksOnlineService_log.ldf',
    SIZE = 5MB,
    MAXSIZE = 25MB,
    FILEGROWTH = 5MB );
GO

-- 2 creation of an arbitrary table--
USE BooksOnlineService;
GO 

CREATE TABLE Customer (
	CustomerID INT IDENTITY(1,1) PRIMARY KEY NOT NULL,
	Phone char(11) NOT NULL,
	LastName nvarchar(20) NOT NULL,
	FirstName nvarchar(20) NOT NULL,
	Patronymic nvarchar(20) NOT NULL,
	Email varchar(100) NOT NULL,
	City nvarchar(20) NOT NULL
);
GO

INSERT INTO Customer(Phone, LastName, FirstName, Patronymic, Email, City) 
VALUES ('89573652341','Èâàíîâ','Ïåòð', 'Ñåðãååâè÷', 'petya92@gmail.com', 'Ìîñêâà')
GO

INSERT INTO Customer(Phone, LastName, FirstName, Patronymic, Email, City) 
VALUES ('89342435152','Ñåðãååâà','Èðèíà', 'Èâàíîâíà', 'sergiriv@gmail.com', 'Êàçàíü')
GO

SELECT * FROM Customer
GO

-- 3 Add a file group and a data file --
USE master;
GO

ALTER DATABASE BooksOnlineService
ADD FILEGROUP lab5_filegroup
GO

ALTER DATABASE BooksOnlineService
ADD FILE
(
	NAME = lab5_data1,
	FILENAME = 'C:\Program Files\Microsoft SQL Server\MSSQL15.SQLEXPRESS\MSSQL\DATA\lab5_data1.mdf',
	SIZE = 10MB,
	MAXSIZE = 100MB,
	FILEGROWTH = 5MB
)
TO FILEGROUP lab5_filegroup
GO

-- 4 assignment the created file group as a default file group --
ALTER DATABASE BooksOnlineService
MODIFY FILEGROUP lab5_filegroup DEFAULT;
GO

-- 5 creation of another arbitrary table --
USE BooksOnlineService;
GO 

CREATE TABLE BookStore (
	BookStoreID INT IDENTITY(1,1) PRIMARY KEY NOT NULL,
	BookStoreName nvarchar(20) NOT NULL,
	Email varchar(100) NOT NULL,
	URL_ varchar(2048) NOT NULL,
	Phone char(11) NULL
);
GO

INSERT INTO BookStore(BookStoreName, Email, URL_, Phone) 
VALUES ('Ëàáèðèíò', 'labirint@mail.ru', 'labirint.ru', '84999209525')
GO

SELECT * FROM BookStore
GO

-- 6 removalof a manually created file group --

ALTER DATABASE BooksOnlineService
MODIFY FILEGROUP [PRIMARY] DEFAULT;
GO

USE BooksOnlineService;
GO 

DROP TABLE BookStore
GO

ALTER DATABASE BooksOnlineService
REMOVE FILE lab5_data1
GO

ALTER DATABASE BooksOnlineService
REMOVE FILEGROUP lab5_filegroup
GO

-- 7 Schema creation, moving one of the tables into it, removal of the schema --
USE BooksOnlineService;
GO 

CREATE SCHEMA shop
GO 

ALTER SCHEMA shop TRANSFER dbo.Customer
GO 

/*DROP TABLE shop.Customer
DROP SCHEMA shop
GO */
