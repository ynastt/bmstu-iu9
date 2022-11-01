-- Создание базы данных --
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

-- 1 Создание таблицы с автоинкрементным первичным ключом --
-- Изучение функций, предназначенных для получения сгенерированного значения IDENTITY.
-- 2 Добавление полей, для которых используются ограничения (CHECK),
-- значения по умолчанию (DEFAULT), встроенные функции для вычисления значений --
USE lab6;
GO 

IF OBJECT_ID(N'Book', N'U') IS NOT NULL
	DROP TABLE Book;
GO

CREATE TABLE Book (
	BookID INT IDENTITY(1,1) PRIMARY KEY NOT NULL,
	ISBN  nvarchar(17) NOT NULL,
	Title nvarchar(50) NOT NULL,
	Genre nvarchar(50) NOT NULL CHECK (Genre IN ('Детектив', 'Научная фантастика', 'Драма', 'Роман', 'Роман-эпопея', 'Мистика', 'Пьеса', 'Сказка', 'Техническая литература')),
	PublishingYear numeric(4) NOT NULL CHECK (PublishingYear >= 1500 AND PublishingYear <= 2020),
	PublishingHouse nvarchar(20) NULL DEFAULT(N'Неизвестно'),
	Price smallmoney NOT NULL CHECK (Price > 0),
);
GO

INSERT INTO Book(ISBN, Title, Genre, PublishingYear, PublishingHouse, Price)
VALUES ('978-5-94387-772-8', 'С++ на примерах', 'Техническая литература', 2019, 'Наука и Техника', '1700'),
	('978-5-04-112699-5', 'Капитанская дочка', 'Роман', 2020, 'Эксмо', '621'),
	('978-5-04-159290-5', 'Я - робот', CONCAT_WS(' ','Научная', 'фантастика'), 2019, 'Эксмо', '780.99')
GO

INSERT INTO Book(ISBN, Title, Genre, PublishingYear, Price) 
VALUES ('978-5-9287-3237-0', 'Приключения Шерлока Холмса: Собака Баскервилей', 'Детектив', 2011, '1472'),
	('874-2-7586-1265-9', LOWER('Странная история доктора Джекила'), UPPER('Драма'), 2002, '340.45')
GO

SELECT * FROM Book
GO

CREATE TABLE BookSecond (
	BookID INT IDENTITY(1,1) PRIMARY KEY NOT NULL,
	ISBN  nvarchar(17) NOT NULL,
	Title nvarchar(50) NOT NULL,
	Genre nvarchar(50) NOT NULL CHECK (Genre IN ('Детектив', 'Научная фантастика', 'Драма', 'Роман', 'Роман-эпопея', 'Мистика', 'Пьеса', 'Сказка', 'Техническая литература')),
	PublishingYear numeric(4) NOT NULL CHECK (PublishingYear >= 1500 AND PublishingYear <= 2020),
	PublishingHouse nvarchar(20) NULL DEFAULT('Неизвестно'),
	Price smallmoney NOT NULL CHECK (Price > 0),
);
GO

INSERT INTO BookSecond(ISBN, Title, Genre, PublishingYear, Price) 
VALUES ('345-2-1234-1265-8', UPPER('Странная история лягушек'), UPPER('пьеса'), 2002, '340')
GO

SELECT CAST(Price AS DECIMAL)  AS [TEST_CAST]
	FROM Book
	WHERE Price BETWEEN 300.00 AND 1000.00; 


SELECT IDENT_CURRENT('Book') AS [IDENT_CURRENT]
SELECT @@IDENTITY AS [@@IDENTITY]
SELECT SCOPE_IDENTITY() AS [SCOPE_IDENTITY]

-- 3 Создание таблицы с первичным ключом на основе глобального уникального идентификатора --

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
	Country nvarchar(30) NULL DEFAULT ('Неизвестна'),
);
GO

INSERT INTO Author(FirstName, LastName, Patronymic, BirthYear, DeathYear, Country)
VALUES ('Артур','Конан Дойл', NULL, 1859, 1930, 'Великобритания'),
	   ('Чарльз','Диккенс', NULL, 1812, 1870, 'Великобритания'),
	   ('Оскар','Уайльд', NULL, 1854, 1900, 'Ирландия'),
	   ('Стивен','Кинг', NULL, 1947, NULL, 'США'),	
	   ('Александр', 'Пушкин', 'Сергеевич', 1799, 1837, 'Россия')
GO

INSERT INTO Author(AuthorId, FirstName, LastName, Patronymic, BirthYear, DeathYear, Country)
VALUES
    (NEWID(), 'Антуан','де Сент-Экзюпери', NULL, 1900, 1944, 'Франция'),
    (NEWID(), 'Иван', 'Тургенев', 'Сергеевич',1813, 1883, 'Россия')
GO

SELECT * FROM Author
GO

-- 4 Создание таблицы с первичным ключом на основе последовательности --

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
VALUES (NEXT VALUE FOR seq, 'Лабиринт', 'labirint@mail.ru', 'labirint.ru', '84999209525'),
	(NEXT VALUE FOR seq, 'Москва', 'info@moscowbooks.ru', 'moscowbooks.ru', '84957978716')
GO

SELECT * FROM BookStore
GO

-- 5 Создание двух связанных таблиц, и тестирование на них различных вариантов действий --
-- для ограничений ссылочной целостности (NO ACTION | CASCADE | SET | SET DEFAULT). --

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
VALUES ('89573652341','Иванов','Петр', 'Сергеевич', 'petya92@gmail.com', 'Москва'),
	('89342435152','Сергеева','Ирина', 'Ивановна', 'sergiriv@gmail.com', 'Казань'),
	('89649245160','Зурхарниева','Ольга', 'Игоревна', 'zoi73@gmail.com', 'Ульяновск'),
	('89876245331','Петров','Сергев', 'Андреевич', 'kvakva@gmail.com', 'Саратов')	-- нет связи с Orders
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
	--ON DELETE NO ACTION -- (Если связанных строк нет, то удаление будет выполнено)
);
GO

INSERT INTO Orders(PaymentType, DeliveryDate, customer_id) 
VALUES ('наличные', CONVERT(date, N'10-12-2022'), 2),
	('по карте', CONVERT(date, N'05-11-2022'), 1),
	('по карте', CONVERT(date, N'07-12-2022'), 3)
GO

SELECT * FROM Orders
GO



DELETE FROM Customer
WHERE City='Казань'
GO

SELECT * FROM Orders
GO

SELECT * FROM Customer
GO

/*DELETE FROM Customer	-- для NO ACTION
WHERE City='Саратов'
GO

SELECT * FROM Orders
GO

SELECT * FROM Customer
GO*/
