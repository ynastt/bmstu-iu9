-- Создать в базах данных пункта 1 задания 13 таблицы, содержащие вертикально
-- фрагментированные данные.

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

DROP TABLE IF EXISTS Author;
GO

CREATE TABLE Author (
	AuthorId INT PRIMARY KEY,
	FirstName nvarchar(20) NOT NULL,
	LastName nvarchar(20) NOT NULL,
	Patronymic nvarchar(20) NULL
);
GO

USE db2
GO

DROP TABLE IF EXISTS Author;
GO

CREATE TABLE Author (
	AuthorId INT PRIMARY KEY,
	BirthYear numeric(4) NOT NULL CHECK (BirthYear > 1500 AND BirthYear < 2000),
	DeathYear numeric(4) NULL, 
	Country nvarchar(30) NULL DEFAULT ('Неизвестна')
);
GO

-- Создать необходимые элементы базы данных (представления, триггеры), обеспечивающие работу
-- с данными вертикально фрагментированных таблиц (выборку, вставку, изменение, удаление).
DROP VIEW IF EXISTS sectionAuthorView
GO

CREATE VIEW sectionAuthorView AS
	SELECT one.AuthorID, one.FirstName, one.LastName, one.Patronymic, two.BirthYear, two.DeathYear, two.Country 
	FROM db1.dbo.Author one, db2.dbo.Author two
	WHERE one.AuthorID = two.AuthorID
GO

DROP TRIGGER IF EXISTS AuthorViewIns 
DROP TRIGGER IF EXISTS AuthorViewUpd 
DROP TRIGGER IF EXISTS AuthorViewDel 
GO

CREATE TRIGGER AuthorViewIns ON sectionAuthorView
INSTEAD OF INSERT
AS
	INSERT INTO db1.dbo.Author(AuthorId, FirstName, LastName, Patronymic)
		SELECT inserted.AuthorId, inserted.FirstName, inserted.LastName, inserted.Patronymic
		FROM inserted
	INSERT INTO db2.dbo.Author(AuthorId, BirthYear, DeathYear, Country)
		SELECT inserted.AuthorId, inserted.BirthYear, inserted.DeathYear, inserted.Country
		FROM inserted
GO

INSERT INTO sectionAuthorView(AuthorId, FirstName, LastName, Patronymic, BirthYear, DeathYear, Country)
VALUES (1, 'Артур','Конан Дойл', NULL, 1859, 1930, 'Великобритания'),
	   (5, 'Чарльз','Диккенс', NULL, 1812, 1870, 'Великобритания'),
	   (2, 'Оскар','Уайльд', NULL, 1854, 1900, 'Ирландия'),
	   (6, 'Стивен','Кинг', NULL, 1947, NULL, 'США'),	
	   (3,'Александр', 'Пушкин', 'Сергеевич', 1799, 1837, 'Россия'),
	   (7, 'Антуан','де Сент-Экзюпери', NULL, 1900, 1945, 'Франция'),
	   (4, 'Иван', 'Тургенев', 'Сергеевич',1813, 1883, 'Россия')
GO

SELECT COUNT(AuthorID) AS [Authors], Country FROM sectionAuthorView 
GROUP BY Country HAVING COUNT(AuthorId) > 0
ORDER BY Authors DESC
GO

SELECT * FROM db1.dbo.Author
SELECT * FROM db2.dbo.Author
GO

CREATE TRIGGER AuthorViewUpd ON sectionAuthorView
INSTEAD OF UPDATE
AS
	IF UPDATE(AuthorID)
		BEGIN
			RAISERROR('ERROR - YOU ARE NOT ALLOWED TO CHANGE AuthorID', 14, -1, 'AuthorViewUpd')
		END
	ELSE
		BEGIN
			UPDATE db1.dbo.Author
				SET FirstName = inserted.FirstName, LastName = inserted.LastName, Patronymic = inserted.Patronymic
					FROM inserted, db1.dbo.Author as table1
					WHERE table1.AuthorId = inserted.AuthorId
			UPDATE db2.dbo.Author
				SET BirthYear = inserted.BirthYear,	DeathYear = inserted.DeathYear, Country = inserted.Country
					FROM inserted, db2.dbo.Author as table2
					WHERE table2.AuthorId = inserted.AuthorId
		END
GO

-- RAISERROR
-- UPDATE sectionAuthorView SET AuthorId = 8 WHERE AuthorId = 3;

UPDATE sectionAuthorView SET DeathYear = 1944 WHERE AuthorId = 7;

SELECT * FROM db1.dbo.Author
SELECT * FROM db2.dbo.Author
GO

CREATE TRIGGER AuthorViewDel ON sectionAuthorView
INSTEAD OF DELETE
AS
	DELETE table1 FROM db1.dbo.Author as table1
		INNER JOIN deleted as del on
		table1.AuthorId = del.AuthorID
	DELETE table2 FROM db2.dbo.Author as table2
		INNER JOIN deleted as del on
		table2.AuthorId = del.AuthorID
GO

DELETE FROM sectionAuthorView WHERE DeathYear < 1900;

SELECT * FROM db1.dbo.Author
SELECT * FROM db2.dbo.Author
GO
