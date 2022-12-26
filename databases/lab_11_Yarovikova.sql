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

USE BooksOnlineService;
GO 

DROP TABLE IF EXISTS Customer;
DROP TABLE IF EXISTS BookStore;
DROP TABLE IF EXISTS Orders;
DROP TABLE IF EXISTS OrderLineBook;
DROP TABLE IF EXISTS Book;
DROP TABLE IF EXISTS Author;
DROP TABLE IF EXISTS BookByAuthor;
GO


CREATE TABLE Customer (
	CustomerID int IDENTITY(1,1) PRIMARY KEY,
	Phone char(11) NOT NULL,
	LastName nvarchar(20) NOT NULL,
	FirstName nvarchar(20) NOT NULL,
	Patronymic nvarchar(20) NOT NULL,
	Email varchar(100) UNIQUE NOT NULL,
	City nvarchar(20) NOT NULL
);
GO

CREATE TABLE BookStore (
	BookStoreID INT PRIMARY KEY,
	BookStoreName nvarchar(20) NOT NULL,
	Email varchar(100) NOT NULL,
	URL_ varchar(2048) NOT NULL,
	Phone char(11) NULL
);
GO

-- для  PaymentType лучше использовать int /* Enum 1- по карте, 2 - наличными ...*/
CREATE TABLE Orders (
	OrderID INT  PRIMARY KEY,
	PaymentType nvarchar(30) NOT NULL DEFAULT('по карте'),
	MakingOrderDate date NOT NULL  DEFAULT(CONVERT(date,GETDATE())),
	DeliveryDate date NOT NULL,
	customer_id int,
	bookstore_id int,
	CONSTRAINT FK_Customer FOREIGN KEY (customer_id) REFERENCES Customer (CustomerID) 
	ON DELETE CASCADE,
	CONSTRAINT FK_BookStore FOREIGN KEY (bookstore_id) REFERENCES BookStore (BookStoreID) 
	ON DELETE CASCADE
);
GO

-- для Genre тоже лучше использовать  int
CREATE TABLE Book (
	BookID INT PRIMARY KEY,
	ISBN  nvarchar(17) NOT NULL,
	Title nvarchar(50) NOT NULL,
	Genre nvarchar(50) NOT NULL CHECK (Genre IN ('Детектив', 'Научная фантастика', 'Драма', 'Роман',
										'Роман-эпопея', 'Мистика', 'Пьеса', 'Сказка', 'Техническая литература')),
	PublishingYear numeric(4) NOT NULL CHECK (PublishingYear >= 1500 AND PublishingYear <= 2023),
	PublishingHouse nvarchar(20) NULL DEFAULT(N'Неизвестно'),
	Price smallmoney NOT NULL CHECK (Price > 0),
);
GO

CREATE TABLE OrderLineBook (
	OrderID int NOT NULL FOREIGN KEY REFERENCES Orders(OrderID),
	LineID INT NOT NULL,
	Quantity int NOT NULL,
	ExtendedPrice smallmoney,
	book_id INT NOT NULL FOREIGN KEY REFERENCES Book (BookID), 
	CONSTRAINT FK_Book FOREIGN KEY (book_id) REFERENCES Book (BookID) 
	ON DELETE CASCADE,
	PRIMARY KEY(OrderID, LineID)
);
GO

CREATE TABLE Author (
	AuthorId INT IDENTITY(1,1) PRIMARY KEY,
	FirstName nvarchar(20) NOT NULL,
	LastName nvarchar(20) NOT NULL,
	Patronymic nvarchar(20) NULL,
	BirthYear numeric(4) NOT NULL CHECK (BirthYear > 1500 AND BirthYear < 2000),
	DeathYear numeric(4) NULL, 
	Country nvarchar(30) NULL DEFAULT ('Неизвестна')
);
GO

CREATE TABLE BookByAuthor (
	BookID int FOREIGN KEY REFERENCES Book(BookID),
	AuthorID int NOT NULL FOREIGN KEY REFERENCES Author(AuthorID),
	ISBN  nvarchar(17) NOT NULL,
	PRIMARY KEY(BookID, AuthorID),
	CONSTRAINT Book_FK FOREIGN KEY (BookID) REFERENCES Book(BookID)
    ON DELETE CASCADE,
	CONSTRAINT Author_FK FOREIGN KEY (AuthorID) REFERENCES Author(AuthorID)
    ON DELETE CASCADE
);
GO

-- тригеры
DROP TRIGGER IF EXISTS Insert_OrderLine
GO

CREATE TRIGGER Insert_OrderLine ON OrderLineBook
	INSTEAD OF INSERT 
	AS

	INSERT INTO OrderLineBook(OrderID, LineID, Quantity, ExtendedPrice, book_id)
	SELECT i.OrderID, i.LineID, i.Quantity, (i.Quantity * b.Price) , i.book_id 
	FROM inserted as i
	INNER JOIN Book as b ON i.book_id = b.BookID
GO

DROP TRIGGER IF EXISTS Insert_Author
DROP TRIGGER IF EXISTS Insert_Book
GO

CREATE TRIGGER Insert_Book ON Book
	INSTEAD OF INSERT
	AS
	RAISERROR('ERROR - YOU ARE NOT ALLOWED TO ADD BOOK WITHOUT AUTHOR. PLEASE USE ConnectBookAndAuthor VIEW', 16, 1, 'Insert_Book')
	ROLLBACK
GO

CREATE TRIGGER Insert_Author ON Author
	INSTEAD OF INSERT
	AS
	RAISERROR('ERROR - YOU ARE NOT ALLOWED TO ADD AUTHOR WITHOUT BOOK. PLEASE USE ConnectBookAndAuthor VIEW', 16, 2, 'Insert_Author')
	ROLLBACK
GO


DROP VIEW IF EXISTS ConnectBookAndAuthor
DROP TRIGGER IF EXISTS ViewIns
GO

CREATE VIEW ConnectBookAndAuthor AS
	SELECT b.BookID, b.ISBN, b.Title, b.Genre, b.PublishingYear, b.PublishingHouse, b.Price,
	ba.AuthorID, a.FirstName, a.LastName, a.Patronymic, a.BirthYear, a.DeathYear, a.Country
	FROM Book AS b INNER JOIN BookByAuthor AS ba ON b.ISBN = ba.ISBN
	INNER JOIN Author AS a ON ba.AuthorID = a.AuthorID
GO

DROP TRIGGER IF EXISTS ViewIns
GO
CREATE TRIGGER ViewIns ON ConnectBookAndAuthor
	INSTEAD OF INSERT
	AS
		BEGIN
			ALTER TABLE Book DISABLE TRIGGER Insert_Book
			INSERT INTO Book(BookID, ISBN, Title, Genre, PublishingYear, PublishingHouse, Price)
			SELECT DISTINCT i.BookID, i.ISBN, i.Title, i.Genre, i.PublishingYear, i.PublishingHouse, i.Price FROM inserted i
			ALTER TABLE Book ENABLE  TRIGGER Insert_Book
				
			ALTER TABLE Author DISABLE TRIGGER Insert_Author
			INSERT INTO Author(FirstName, LastName, Patronymic, BirthYear, DeathYear, Country)
			SELECT DISTINCT i.FirstName, i.LastName, i.Patronymic, i.BirthYear, i.DeathYear, i.Country FROM inserted i
			ALTER TABLE Author ENABLE TRIGGER Insert_Author

			INSERT INTO BookByAuthor(BookID, AuthorID, ISBN) SELECT i.BookID, i.AuthorID, i.ISBN FROM inserted i
		END
GO

-- нужен триггер на удаление тк 1:1
-- тригер на удаление книги - проверить, что осталась хотя бы одна книга этого автора 
-- суть в том, что в ЛР 4 я сделала так, что у автора 1 или несколько книг. 
-- Поэтому при удалении книги, нужно проверить, есть ли у автора еще книги. Если нет - ошибка и откатить назад
-- если у автора еще есть книги, то можно удалять
DROP TRIGGER IF EXISTS BookDel
GO
 
CREATE TRIGGER BookDel ON Book
INSTEAD OF DELETE
AS
	
	IF 1 >= (SELECT COUNT(BookID) from Book WHERE BookID IN (SELECT BookID FROM BookByAuthor WHERE AuthorID IN (SELECT AuthorID FROM BookByAuthor ba INNER JOIN deleted b ON b.BookID = ba.BookID) ))
		BEGIN
			RAISERROR('ERROR - THERE IS NO BOOKS OF THIS AUTHOR LEFT', 16, 1, 'BookDel')
			ROLLBACK
		END	
	ELSE
	BEGIN
		DELETE FROM Book WHERE BookID IN (SELECT BookID FROM deleted)
	END
GO


INSERT INTO Customer(Phone, LastName, FirstName, Patronymic, Email, City) 
VALUES ('89573652341','Иванов','Петр', 'Сергеевич', 'petya92@gmail.com', 'Москва'),
	('89342435152','Сергеева','Ирина', 'Ивановна', 'sergiriv@gmail.com', 'Казань'),
	('89649245160','Зурхарниева','Ольга', 'Игоревна', 'zoi73@gmail.com', 'Ульяновск'),
	('89876245331','Петров','Сергев', 'Андреевич', 'kvakva@gmail.com', 'Саратов'),
	('89764845132','Иванова','Инга', 'Ивановна', 'iviv@gmail.com', 'Ульяновск'),
	('89996545365','Васильев','Василий', 'Васильевич', 'vasssslv@gmail.com', 'Сызрань')
GO

INSERT INTO BookStore(BookStoreID, BookStoreName, Email, URL_, Phone) 
VALUES (1, 'Лабиринт', 'labirint@mail.ru', 'labirint.ru', '84999209525'),
		(2, 'Читай-Город', 'chitaigorod@yandex.ru', 'chitai-gorod.ru', '89777209037')
GO

INSERT INTO Orders(OrderID, DeliveryDate, customer_id, bookstore_id)
VALUES (1, CONVERT(date, N'01-01-2023'), 2, 2),
		(2, CONVERT(date, N'12-01-2023'), 1, 2)
GO

INSERT INTO ConnectBookAndAuthor(BookID, ISBN, Title, Genre, PublishingYear, PublishingHouse, Price, AuthorID, FirstName, LastName, Patronymic, BirthYear, DeathYear, Country)
VALUES (1, '978-5-9555-1339-3', 'Евгений Онегин', 'Роман', 2010, 'Дрофа Плюс', '600', 1, 'Александр', 'Пушкин', 'Сергеевич', 1799, 1837, 'Россия'),
	(2, '978-5-04-112699-5', 'Капитанская дочка', 'Роман', 2020, 'Эксмо', '621', 1, 'Александр', 'Пушкин', 'Сергеевич', 1799, 1837, 'Россия'),
	(3, '978-5-9287-3237-0', 'Приключения Шерлока Холмса: Собака Баскервилей', 'Детектив', 2011, NULL,'1472', 2, 'Артур','Конан Дойл', NULL, 1859, 1930, 'Великобритания'),
	(4, '978-5-45-828618-3', 'Задачи и упражнения по мат анализу для ВТУЗов', 'Техническая литература', 1972, 'Наука', '790', 3, 'Борис', 'Демидович', 'Павлович', 1906, 1977, 'Россия'),
	(4, '978-5-45-828618-3', 'Задачи и упражнения по мат анализу для ВТУЗов', 'Техническая литература', 1972, 'Наука', '790', 4, 'Алексей','Ефимов','Владимирович',1896, 1971,'Азербайджан'),      
	(5, '978-5-17-113039-8', 'Приключения Оливера Твиста', 'Роман', 2021, 'АСТ', '590', 5, 'Чарлз','Диккенс', NULL, 1812, 1870, 'Великобритания')
GO

-- raiserror
-- INSERT INTO Book(BookID, ISBN, Title, Genre, PublishingYear, PublishingHouse, Price)
-- VALUES (1, '978-5-94387-772-8', 'С++ на примерах', 'Техническая литература', 2019, 'Наука и Техника', '1700')	
-- GO

-- raiserror
-- INSERT INTO Author(FirstName, LastName, Patronymic, BirthYear, DeathYear, Country)
-- VALUES ('Оскар','Уайльд', NULL, 1854, 1900, 'Ирландия')	   
-- GO

INSERT INTO OrderLineBook(OrderID, LineID, Quantity, book_id)
VALUES(1, 1, 3, 2),
	(1, 2, 1, 3),
	(2, 1, 2, 4)
GO

SELECT * FROM Customer
SELECT * FROM BookStore
SELECT * FROM Orders
SELECT * FROM OrderLineBook
SELECT * FROM Book
SELECT * FROM Author
SELECT * FROM BookByAuthor
GO

-- raiserror
--DELETE FROM Book WHERE BookID = 3

DELETE FROM Book WHERE BookID = 2
SELECT * FROM Book
SELECT * FROM Author
SELECT * FROM BookByAuthor
GO


DELETE FROM Author WHERE AuthorID = 5
SELECT * FROM Book
SELECT * FROM Author
SELECT * FROM BookByAuthor
GO

--4
SELECT DISTINCT PublishingHouse FROM Book

SELECT Orders.OrderID, Orders.DeliveryDate, Customer.LastName, Customer.FirstName
FROM Orders LEFT JOIN Customer ON Orders.customer_id = Customer.CustomerID

SELECT Orders.OrderID, Orders.DeliveryDate, Customer.LastName, Customer.FirstName
FROM Orders RIGHT JOIN Customer ON Orders.customer_id = Customer.CustomerID

SELECT Orders.OrderID, Orders.DeliveryDate, BookStore.BookStoreName
FROM Orders FULL OUTER JOIN BookStore ON Orders.bookstore_id = BookStore.BookStoreID

SELECT * FROM Book WHERE Price BETWEEN 300 AND 1000 ORDER BY PublishingYear ASC

SELECT * FROM Book WHERE  Genre IN ('Детектив', 'Драма', 'Роман') ORDER BY Price DESC

SELECT * FROM Author WHERE FirstName LIKE 'А%'

SELECT COUNT(AuthorID) AS [Alive authors] FROM Author WHERE DeathYear IS NULL 

SELECT COUNT(AuthorID) AS [authors from same country], Country  FROM Author GROUP BY Country HAVING COUNT(AuthorID) > 1

SELECT Genre, MAX(Price) as [max price for genre] FROM Book GROUP BY Genre HAVING MIN(Price) > 500

SELECT Genre, MIN(Price) as [min price for genre] FROM Book GROUP BY Genre HAVING MAX(Price) < 500

SELECT Genre, AVG(Price) as [avg price for genre] FROM Book GROUP BY Genre HAVING AVG(Price) BETWEEN 500 AND 900

SELECT Genre, AVG(Price) as [avg price for genre fro books whole sum < 1000] FROM Book GROUP BY Genre HAVING SUM(Price) < 1000

SELECT * FROM Customer WHERE CustomerID BETWEEN 4 AND 6
UNION 
SELECT * FROM Customer WHERE CustomerID IN (3, 5, 6)
ORDER BY CustomerID
GO

SELECT * FROM Customer WHERE CustomerID BETWEEN 4 AND 6
UNION ALL
SELECT * FROM Customer WHERE CustomerID IN (3, 5)
ORDER BY CustomerID
GO

SELECT * FROM Customer WHERE CustomerID BETWEEN 2 AND 6
EXCEPT
SELECT * FROM Customer WHERE CustomerID IN (3, 5)
ORDER BY CustomerID
GO

SELECT * FROM Customer WHERE CustomerID BETWEEN 2 AND 4
INTERSECT
SELECT * FROM Customer WHERE CustomerID BETWEEN 3 AND 6
ORDER BY CustomerID
GO 
