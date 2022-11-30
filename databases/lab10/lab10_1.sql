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
	Genre nvarchar(50) NOT NULL CHECK (Genre IN ('Детектив', 'Научная фантастика', 'Драма', 'Роман', 'Роман-эпопея', 'Комедия', 'Мистика', 'Пьеса', 'Сказка', 'Техническая литература')),
	PublishingYear numeric(4) NOT NULL CHECK (PublishingYear >= 1500 AND PublishingYear <= 2020),
	PublishingHouse nvarchar(20) NULL DEFAULT(N'Неизвестно'),
	Price smallmoney NOT NULL CHECK (Price > 0),
);
GO

INSERT INTO Book(ISBN, Title, Genre, PublishingYear, PublishingHouse, Price)
VALUES ('978-5-94387-772-8', 'С++ на примерах', 'Техническая литература', 2019, 'Наука и Техника', '1700'),
	('978-5-04-112699-5', 'Капитанская дочка', 'Роман', 2020, 'Эксмо', '621'),
	('978-5-04-159290-5', 'Я - робот', 'Научная фантастика', 2019, 'Эксмо', '780.99'),
	('956-5-04-129278-4', 'В стране чудес', 'Сказка', 2010, 'Эскимо', '450.99')
GO

INSERT INTO Book(ISBN, Title, Genre, PublishingYear, Price) 
VALUES ('978-5-9287-3237-0', 'Приключения Шерлока Холмса: Собака Баскервилей', 'Детектив', 2011, '1472'),
	('874-2-7586-1265-9', 'Странная история доктора Джекила', 'Драма', 2002, '340.45'),
	('110-9-8765-4321-0', 'Как Настя училась на ИУ9', 'Роман-эпопея', 2020, '1000')
GO

SELECT * FROM Book
GO
