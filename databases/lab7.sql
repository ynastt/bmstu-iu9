-- 1 Создание представления на основе одной из таблиц 
-- задания 6

USE lab6;
GO

DROP VIEW IF EXISTS BookView;
GO

CREATE VIEW BookView AS
	SELECT b.ISBN, b.Title, b.Genre, b.PublishingYear, b.Price
	FROM Book AS b
	WHERE PublishingYear BETWEEN 1900 AND 2014;
GO

SELECT * FROM BookView
GO

-- 2 Создание представления на основе полей обеих  
-- связанных таблиц задания 6

DROP VIEW IF EXISTS CustomerOrderView;
GO

CREATE VIEW CustomerOrderView AS
	SELECT c.LastName, c.FirstName, c.Patronymic, c.Email,
		   o.MakingOrderDate, o.DeliveryDate, o.PaymentType
	FROM Customer as c INNER JOIN Orders as o ON c.CustomerID = o.customer_id
	-- WHERE o.DeliveryDate > GETDATE() 
	WITH CHECK OPTION 
GO

SELECT * FROM CustomerOrderView
GO

-- 3 Создание индекса для одной из таблиц задания 6, 
-- включив в него дополнительные неключевые поля

IF EXISTS (SELECT * FROM sys.indexes  WHERE name = N'AuthorNameIndex')  
    DROP INDEX AuthorNameIndex ON Author;  
GO
 
CREATE INDEX AuthorNameIndex   
    ON Author (LastName, Firstname DESC)
	INCLUDE (BirthYear, Country);
GO

SELECT LastName, FirstName, BirthYear, Country FROM Author WHERE LastName = 'Диккенс' and FirstName = 'Чарльз';
GO

-- 4 Создание индексированного представления --

DROP VIEW IF EXISTS AuthorIndexView;
GO

CREATE VIEW AuthorIndexView 
WITH SCHEMABINDING AS
	SELECT LastName, FirstName, BirthYear, DeathYear, Country
	FROM dbo.Author
	WHERE BirthYear > 1850;
GO


/*UPDATE  Author
SET LastName = 'kva'
WHERE Country = 'Ирландия';*/ -- работает

IF EXISTS (SELECT * FROM sys.indexes  WHERE name = N'AuthorIndex')  
    DROP INDEX AuthorIndex ON Author;  
GO

DROP INDEX AuthorNameIndex ON Author;
GO 

CREATE UNIQUE CLUSTERED INDEX AuthorIndex  
    ON AuthorIndexView (LastName, BirthYear);
GO

/*CREATE INDEX AuthorYearIndex   
    ON Author (LastName)
	INCLUDE (Country);
GO*/ 
-- новый индекс после уникального кластеризованного работает, перед ним -  нет

SELECT * FROM AuthorIndexView
GO