USE master;
GO

IF DB_ID('lab8') IS NOT NULL
DROP DATABASE lab8;
GO

CREATE DATABASE lab8
ON PRIMARY
( NAME = lab8_dat,
    FILENAME = 'C:\Program Files\Microsoft SQL Server\MSSQL15.SQLEXPRESS\MSSQL\DATA\lab8_dat.mdf',
    SIZE = 10,
    MAXSIZE = 50,
    FILEGROWTH = 5 )
LOG ON
( NAME = lab8_log,
    FILENAME = 'C:\Program Files\Microsoft SQL Server\MSSQL15.SQLEXPRESS\MSSQL\DATA\lab8_log.ldf',
    SIZE = 5MB,
    MAXSIZE = 25MB,
    FILEGROWTH = 5MB );
GO

USE lab8;
GO

DROP TABLE IF EXISTS Book;
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
	('978-5-04-159290-5', '� - �����', '������� ����������', 2019, '�����', '780.99'),
	('956-5-04-129278-4', '� ������ �����', '������', 2010, '������', '450.99')
GO

INSERT INTO Book(ISBN, Title, Genre, PublishingYear, Price) 
VALUES ('978-5-9287-3237-0', '����������� ������� ������: ������ �����������', '��������', 2011, '1472'),
	('874-2-7586-1265-9', '�������� ������� ������� �������', '�����', 2002, '340.45')
GO

SELECT * FROM Book
GO

-- 1 ������� �������� ���������, ������������ �������
-- �� ��������� ������� � ������������ ���������
-- ������� � ���� �������.

DROP PROCEDURE IF EXISTS dbo.BookProc;
GO

CREATE PROCEDURE dbo.BookProc
	@cursor_book CURSOR VARYING OUTPUT
AS
	SET @cursor_book = CURSOR 
		SCROLL STATIC FOR	-- ��������� ������, �� 3 ����� �������
		SELECT Title, Genre, Price 
		FROM Book;
	OPEN @cursor_book;
GO

DECLARE @cursor CURSOR;
EXEC dbo.BookProc @cursor_book = @cursor OUTPUT;
--OPEN @cursor_book; -- ������ ������, �.�. ������ ��� ������

-- ������� �������, ����� ��������, ��� ������ ����������� � ��������� ������� �� �������� �� �������
UPDATE  Book
SET Genre = UPPER(Genre)
WHERE PublishingHouse = '����������';

FETCH NEXT FROM @cursor;
WHILE @@FETCH_STATUS = 0 --The FETCH statement was successful.
	BEGIN
		FETCH NEXT FROM @cursor;
	END

CLOSE @cursor;
DEALLOCATE @cursor;
GO

-- 2 �������������� �������� ��������� �.1. �����
-- �������, ����� ������� �������������� �
-- ������������� �������, �������� ��������
-- ����������� ���������������� ��������.

DROP FUNCTION IF EXISTS dbo.PriceConvert;
GO

CREATE FUNCTION dbo.PriceConvert(@bookPrice smallmoney)
RETURNS decimal 
AS
BEGIN
	DECLARE @res decimal;
	SELECT @res = CAST(b.Price AS decimal) FROM Book AS b
	WHERE b.Price = @bookPrice;
	RETURN @res;
END;
GO

DROP PROCEDURE IF EXISTS dbo.BookProcWithFunc;
GO

CREATE PROCEDURE dbo.BookProcWithFunc
	@cur CURSOR VARYING OUTPUT
AS
	SET @cur = CURSOR 
		FORWARD_ONLY STATIC FOR
		SELECT ISBN, Title, Genre, dbo.PriceConvert(Price) AS Price
		FROM Book;
	OPEN @cur;
GO

DECLARE @cursor_book CURSOR;
EXEC dbo.BookProcWithFunc @cur = @cursor_book OUTPUT;

FETCH NEXT FROM @cursor_book;
WHILE @@FETCH_STATUS = 0 
	BEGIN
		FETCH NEXT FROM @cursor_book;
	END

CLOSE @cursor_book;
DEALLOCATE @cursor_book;
GO

-- 3 ������� �������� ���������, ���������� ���������
-- �.1., �������������� ��������� �������������
-- ������� � ��������� ���������, �������������� ��
-- ������� ��� ���������� �������, ��������� ��� �����
-- ���������������� ��������.

DROP FUNCTION IF EXISTS dbo.isCheap;
GO

CREATE FUNCTION dbo.IsCheap(@bookPrice smallmoney)
RETURNS bit
AS
BEGIN
	IF @bookPrice < 500
		RETURN 1
	RETURN 0
END;
GO

DROP PROCEDURE IF EXISTS dbo.GetCheapBooks;
GO

CREATE PROCEDURE dbo.GetCheapBooks
AS
	DECLARE @cursorBook CURSOR
	DECLARE @Title nvarchar(50)
	DECLARE @Genre nvarchar(50)
	DECLARE @Price smallmoney

	EXEC dbo.BookProc @cursor_book = @cursorBook OUTPUT

	FETCH LAST FROM @cursorBook INTO @Title, @Genre, @Price
	WHILE @@FETCH_STATUS = 0
		BEGIN
			IF dbo.IsCheap(@Price) = 1
				 PRINT FORMATMESSAGE(N'��������� �����: �������� = "%s", ���� = %s', @Title, CAST(@Price AS varchar))
			FETCH PRIOR FROM @cursorBook INTO @Title, @Genre, @Price
		END
	CLOSE @cursorBook
	DEALLOCATE @cursorBook
GO	

EXEC dbo.GetCheapBooks
GO

-- ������� �������
UPDATE  Book
SET Genre = CONCAT_WS('', SUBSTRING(Genre, 1, 1), SUBSTRING(LOWER(Genre), 2, 24))
WHERE PublishingHouse = '����������';


-- 4 �������������� �������� ��������� �.2. �����
-- �������, ����� ������� ������������� � �������
-- ��������� �������.

DROP FUNCTION IF EXISTS dbo.BookTableFunc;
GO

--inline
CREATE FUNCTION dbo.BookTableFunc()
RETURNS TABLE
AS
RETURN
(
	SELECT b.ISBN, b.Title, b.Genre, dbo.PriceConvert(b.Price) AS Price
	FROM Book AS b
);
GO

DROP PROCEDURE IF EXISTS dbo.BookProcWithTableFunc;
GO

CREATE PROCEDURE dbo.BookProcWithTableFunc
	@cur CURSOR VARYING OUTPUT
AS
	SET @cur = CURSOR 
		FORWARD_ONLY STATIC FOR
		SELECT * FROM dbo.BookTableFunc()
	OPEN @cur;
GO

DECLARE @cursor_table_book CURSOR;
EXEC dbo.BookProcWithTableFunc @cur = @cursor_table_book OUTPUT;

FETCH NEXT FROM @cursor_table_book;
WHILE @@FETCH_STATUS = 0 
	BEGIN
		FETCH NEXT FROM @cursor_table_book;
	END

CLOSE @cursor_table_book;
DEALLOCATE @cursor_table_book;
GO