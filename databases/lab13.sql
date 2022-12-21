-- ������� ��� ���� ������ �� ����� ���������� ���� SQL Server

USE master;
GO

IF DB_ID('lab13db1') IS NOT NULL
DROP DATABASE lab13db1;
GO

IF DB_ID('lab13db2') IS NOT NULL
DROP DATABASE lab13db2;
GO

CREATE DATABASE lab13db1
ON 
( NAME = lab13db1_dat,
    FILENAME = 'C:\Program Files\Microsoft SQL Server\MSSQL15.SQLEXPRESS\MSSQL\DATA\lab13db1_dat.mdf',
    SIZE = 10,
    MAXSIZE = 50,
    FILEGROWTH = 5 )
LOG ON
( NAME = lab13db1_log,
    FILENAME = 'C:\Program Files\Microsoft SQL Server\MSSQL15.SQLEXPRESS\MSSQL\DATA\lab13db1_log.ldf',
    SIZE = 5MB,
    MAXSIZE = 25MB,
    FILEGROWTH = 5MB );
GO 

CREATE DATABASE lab13db2
ON 
( NAME = lab13db2_dat,
    FILENAME = 'C:\Program Files\Microsoft SQL Server\MSSQL15.SQLEXPRESS\MSSQL\DATA\lab13db2_dat.mdf',
    SIZE = 10,
    MAXSIZE = 50,
    FILEGROWTH = 5 )
LOG ON
( NAME = lab13db2_log,
    FILENAME = 'C:\Program Files\Microsoft SQL Server\MSSQL15.SQLEXPRESS\MSSQL\DATA\lab13db2_log.ldf',
    SIZE = 5MB,
    MAXSIZE = 25MB,
    FILEGROWTH = 5MB );
GO

-- ������� � ����� ������ �.1. ������������� ����������������� �������.
USE lab13db1
GO

DROP TABLE IF EXISTS Author;
GO

CREATE TABLE Author (
	AuthorId INT PRIMARY KEY CHECK (AuthorID < 4),
	FirstName nvarchar(20) NOT NULL,
	LastName nvarchar(20) NOT NULL,
	Patronymic nvarchar(20) NULL,
	BirthYear numeric(4) NOT NULL CHECK (BirthYear > 1500 AND BirthYear < 2000),
	DeathYear numeric(4) NULL, 
	Country nvarchar(30) NULL DEFAULT ('����������'),
);
GO


USE lab13db2
GO

DROP TABLE IF EXISTS Author;
GO

CREATE TABLE Author (
	AuthorId INT PRIMARY KEY CHECK (AuthorID >= 4),
	FirstName nvarchar(20) NOT NULL,
	LastName nvarchar(20) NOT NULL,
	Patronymic nvarchar(20) NULL,
	BirthYear numeric(4) NOT NULL CHECK (BirthYear > 1500 AND BirthYear < 2000),
	DeathYear numeric(4) NULL, 
	Country nvarchar(30) NULL DEFAULT ('����������'),
);
GO

--������� ���������������� �������������, �������������� ������ � ������� ������
-- (�������, �������, ���������, ��������).
DROP VIEW IF EXISTS sectionAuthorView
GO

CREATE VIEW sectionAuthorView AS
	SELECT * FROM lab13db1.dbo.Author
	UNION ALL
	SELECT * FROM lab13db2.dbo.Author
GO


INSERT INTO sectionAuthorView(AuthorId, FirstName, LastName, Patronymic, BirthYear, DeathYear, Country)
VALUES (1, '�����','����� ����', NULL, 1859, 1930, '��������������'),
	   (5, '������','�������', NULL, 1812, 1870, '��������������'),
	   (2, '�����','������', NULL, 1854, 1900, '��������'),
	   (6, '������','����', NULL, 1947, NULL, '���'),	
	   (3,'���������', '������', '���������', 1799, 1837, '������'),
	   (7, '������','�� ����-��������', NULL, 1900, 1944, '�������'),
	   (4, '����', '��������', '���������',1813, 1883, '������')
GO
/*
-- ��� ��� ������ � IDENTITY
INSERT INTO sectionAuthorView(FirstName, LastName, Patronymic, BirthYear, DeathYear, Country)
VALUES ('�����','����� ����', NULL, 1859, 1930, '��������������'),
	   ('������','�������', NULL, 1812, 1870, '��������������'),
	   ('�����','������', NULL, 1854, 1900, '��������'),
	   ('������','����', NULL, 1947, NULL, '���'),	
	   ('���������', '������', '���������', 1799, 1837, '������'),
	   ('������','�� ����-��������', NULL, 1900, 1944, '�������'),
	   ('����', '��������', '���������',1813, 1883, '������')
GO
*/
SELECT COUNT(AuthorID) AS [Authors], Country FROM sectionAuthorView 
GROUP BY Country HAVING COUNT(AuthorId) > 0
ORDER BY Authors DESC
GO

SELECT * FROM lab13db1.dbo.Author
SELECT * FROM lab13db2.dbo.Author
GO

-- ���� ������������ IDENTITY � AuthorID, �� ������
-- "���������� �������� ���������������� ������������� "lab13db2.dbo.sectionAuthorView", ��� ��� �� ������� �������� ��� ������� ��������������� "AuthorId"."
UPDATE sectionAuthorView
SET AuthorId = 8 WHERE AuthorId = 3
GO

SELECT * FROM lab13db1.dbo.Author
SELECT * FROM lab13db2.dbo.Author
GO

DELETE FROM sectionAuthorView
WHERE DeathYear < 1900
GO 

SELECT * FROM lab13db1.dbo.Author
SELECT * FROM lab13db2.dbo.Author
GO