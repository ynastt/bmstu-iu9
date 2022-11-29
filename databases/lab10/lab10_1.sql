USE master

DROP DATABASE IF EXISTS lab10 
GO

CREATE DATABASE lab10
ON PRIMARY
( NAME = lab10_table_dat,
    FILENAME = 'C:\Program Files\Microsoft SQL Server\MSSQL15.SQLEXPRESS\MSSQL\DATA\lab10_table_dat.mdf',
    SIZE = 10,
    MAXSIZE = 50,
    FILEGROWTH = 5 )
LOG ON
( NAME = lab10_table_log,
    FILENAME = 'C:\Program Files\Microsoft SQL Server\MSSQL15.SQLEXPRESS\MSSQL\DATA\lab10_table_log.ldf',
    SIZE = 5MB,
    MAXSIZE = 25MB,
    FILEGROWTH = 5MB );
GO

USE lab10;
GO

DROP TABLE IF EXISTS Book;
GO

CREATE TABLE Book (
	BookID INT IDENTITY(1,1) PRIMARY KEY NOT NULL,
	ISBN  nvarchar(17) NOT NULL,
	Title nvarchar(50) NOT NULL,
	Genre nvarchar(50) NOT NULL CHECK (Genre IN ('��������', '������� ����������', '�����', '�����', '�����-������', '�������', '�������', '�����', '������', '����������� ����������')),
	PublishingYear numeric(4) NOT NULL CHECK (PublishingYear >= 1500 AND PublishingYear <= 2020),
	PublishingHouse nvarchar(20) NULL DEFAULT(N'����������'),
	Price smallmoney NOT NULL CHECK (Price > 0),
);
GO

INSERT INTO Book(ISBN, Title, Genre, PublishingYear, PublishingHouse, Price)
VALUES ('978-5-94387-772-8', '�++ �� ��������', '����������� ����������', 2019, '����� � �������', '1700'),
	('978-5-04-112699-5', '����������� �����', '�����', 2020, '�����', '621'),
	('978-5-04-159290-5', '� - �����', '������� ����������', 2019, '�����', '780.99'),
	('956-5-04-129278-4', '� ������ �����', '������', 2010, '������', '450.99')
GO

INSERT INTO Book(ISBN, Title, Genre, PublishingYear, Price) 
VALUES ('978-5-9287-3237-0', '����������� ������� ������: ������ �����������', '��������', 2011, '1472'),
	('874-2-7586-1265-9', '�������� ������� ������� �������', '�����', 2002, '340.45'),
	('110-9-8765-4321-0', '��� ����� ������� �� ��9', '�����-������', 2020, '1000')
GO

SELECT * FROM Book
GO