USE master;
GO

IF DB_ID('lab9') IS NOT NULL
DROP DATABASE lab9;
GO

CREATE DATABASE lab9
ON PRIMARY
( NAME = lab9_dat,
    FILENAME = 'C:\Program Files\Microsoft SQL Server\MSSQL15.SQLEXPRESS\MSSQL\DATA\lab9_dat.mdf',
    SIZE = 10,
    MAXSIZE = 50,
    FILEGROWTH = 5 )
LOG ON
( NAME = lab9_log,
    FILENAME = 'C:\Program Files\Microsoft SQL Server\MSSQL15.SQLEXPRESS\MSSQL\DATA\lab9_log.ldf',
    SIZE = 5MB,
    MAXSIZE = 25MB,
    FILEGROWTH = 5MB );
GO

USE lab9;
GO

--таблицы
CREATE TABLE Customer (
	CustomerID UNIQUEIDENTIFIER PRIMARY KEY DEFAULT NEWID(),
	Phone char(11) NULL,
	LastName nvarchar(25) NOT NULL,
	FirstName nvarchar(25) NOT NULL,
	Patronymic nvarchar(25) NOT NULL,
	Email varchar(100) NOT NULL UNIQUE
);
GO

CREATE TABLE Orders (
	OrderID UNIQUEIDENTIFIER PRIMARY KEY DEFAULT NEWID(),
	PaymentType nvarchar(30) NOT NULL DEFAULT('по карте'),
	MakingOrderDate date NOT NULL  DEFAULT(CONVERT(date,GETDATE())),
	DeliveryDate date NOT NULL,
	customer_id UNIQUEIDENTIFIER,
	CONSTRAINT FK_Customer FOREIGN KEY (customer_id) REFERENCES Customer (CustomerID) 
	ON DELETE CASCADE
);
GO

-- 1. Для одной из таблиц создать триггеры на вставку, удаление и обновление,
-- при выполнении заданных условий один из триггеров
-- должен инициировать возникновение ошибки (RAISERROR / THROW).

--
--	вставка
--
CREATE TRIGGER Insert_Customer ON Customer
	AFTER INSERT 
	AS
	INSERT INTO Orders(DeliveryDate, customer_id)
	SELECT CONVERT(date, N'01-01-2023'), CustomerID FROM inserted
GO

INSERT INTO Customer(Phone, LastName, FirstName, Patronymic, Email)
VALUES('89477975430','Соколова','Ольга', 'Владимировна', 'olg3@gmail.com'),
	('89573652341','Иванов','Петр', 'Сергеевич', 'petya92@gmail.com'),
	('89342435152','Сергеева','Ирина', 'Ивановна', 'sergiriv@gmail.com'),
	('89876245331','Петров','Сергев', 'Андреевич', 'kvakva@gmail.com');
GO

SELECT * FROM Customer
GO

SELECT * FROM Orders
GO
--
--	удаление
--
CREATE TRIGGER Delete_Customer ON Customer
	FOR DELETE 
	AS
	DECLARE @idt UNIQUEIDENTIFIER
	DECLARE @name nvarchar(25)
	DECLARE @time datetime
	SET @idt = (SELECT CustomerId FROM deleted);
	SET @name = (SELECT LastName FROM deleted);
	SET @time = GETDATE()
	PRINT FORMATMESSAGE('Удален пользователь %s, id: %s, дата операции: %s', @name, CONVERT(varchar(255), @idt), CONVERT(varchar(11), @time))
GO  

DELETE FROM Customer WHERE LastName='Соколова';
GO

SELECT * FROM Customer
GO

SELECT * FROM Orders
GO
--
--	обновление
--
CREATE TRIGGER Update_Customer ON Customer         
	AFTER UPDATE 
	AS
	IF EXISTS( SELECT 1 FROM inserted WHERE FirstName LIKE N'%Ъ')
		BEGIN
			RAISERROR ('!ERROR!', 15, -1, 'Update_Customer');
			ROLLBACK
		END
	ELSE
	BEGIN
		IF UPDATE(Phone)
			BEGIN 
				UPDATE Customer SET Phone = (SELECT TOP 1 Phone FROM inserted) WHERE CustomerID IN (SELECT CustomerID FROM deleted)
			END
		IF UPDATE(LastName)
			BEGIN 
				UPDATE Customer SET LastName = (SELECT TOP 1 LastName FROM inserted) WHERE CustomerID IN (SELECT CustomerID FROM deleted)
			END
		IF UPDATE(FirstName)
			BEGIN 
				UPDATE Customer SET FirstName = (SELECT TOP 1 FirstName FROM inserted) WHERE CustomerID IN (SELECT CustomerID FROM deleted)
			END
		IF UPDATE(Patronymic)
			BEGIN 
				UPDATE Customer SET Patronymic = (SELECT TOP 1 Patronymic FROM inserted) WHERE CustomerID IN (SELECT CustomerID FROM deleted)
			END
		IF UPDATE(Email)
			BEGIN 
				UPDATE Customer SET Email = (SELECT TOP 1 Email FROM inserted) WHERE CustomerID IN (SELECT CustomerID FROM deleted)
			END
	END
GO

--raiserror
--UPDATE Customer SET FirstName = 'Петръ' WHERE LastName='Иванов';

UPDATE Customer SET FirstName = 'Иван' WHERE LastName='Иванов';
GO

SELECT * FROM Customer
GO

-- 2. Для представления создать триггеры на вставку, удаление и добавление,
-- обеспечивающие возможность выполнения операций с данными 
-- непосредственно через представление.

-- отключаем триггеры с предыдущего пункта
DISABLE TRIGGER Insert_Customer ON Customer
GO

DISABLE TRIGGER Delete_Customer ON Customer
GO

DISABLE TRIGGER Update_Customer ON Customer
GO
-- таблицы
DROP TABLE IF EXISTS Doctor;
GO

DROP TABLE IF EXISTS Specialization;
GO

CREATE TABLE Doctor (
	DoctorID UNIQUEIDENTIFIER PRIMARY KEY DEFAULT NEWID(),
	Phone char(11) NULL,
	DoctorName nvarchar(255) NOT NULL,
	DateOfBirth date NOT NULL  DEFAULT(CONVERT(date,GETDATE())),
	Email nvarchar(100) NOT NULL UNIQUE
);
GO

CREATE TABLE Specialization (
	SpecID UNIQUEIDENTIFIER PRIMARY KEY DEFAULT NEWID(),
	SpecDescription nvarchar(MAX) NOT NULL,
	doctor_id UNIQUEIDENTIFIER,
	CONSTRAINT FK_Doctor FOREIGN KEY (doctor_id) REFERENCES Doctor (DoctorID) 
	ON DELETE CASCADE
);
GO

INSERT INTO Doctor(Phone, DoctorName, DateOfBirth, Email)
    VALUES ('84958888888', 'Алексеев Алексей Алексеевич', CONVERT(date, N'06-11-2000'), 'alexsha@gmail.com'),
           ('84958888881', 'Величко Егор', CONVERT(date, N'01-01-1967'), 'veleg9@gmail.com');
GO

INSERT INTO Specialization(SpecDescription, doctor_id)
	VALUES ('врач-хирург', (SELECT DoctorID FROM Doctor WHERE Doctor.Email = 'alexsha@gmail.com')),
		   ('врач-кардиолог', (SELECT DoctorID FROM Doctor WHERE Doctor.Email = 'veleg9@gmail.com'));
GO

-- представление
DROP VIEW IF EXISTS SpecView;
GO

CREATE VIEW SpecView(SpecializationDescription, DoctorName, DoctorEmail) WITH SCHEMABINDING
	AS
	SELECT s.SpecDescription, d.DoctorName, d.Email   
	FROM dbo.Specialization AS s INNER JOIN dbo.Doctor AS d 
	ON d.DoctorID = s.doctor_id
GO

SELECT * FROM SpecView
GO

--
--	вставка
--

-- ДО ТРИГЕРА МЫ ПОЛУЧИМ ОШИБКУ 
-- "Невозможно обновить представление или функцию "SpecView", так как изменение влияет на несколько базовых таблиц."
--INSERT INTO SpecView (SpecializationDescription, DoctorName, DoctorEmail)
--VALUES ('Врач-оториноларинголог', 'Исаева Ольга Иваовна', 'olg@mail.ru');
--GO

CREATE TRIGGER Insert_SpecView ON SpecView
	INSTEAD OF INSERT
	AS
	INSERT INTO Doctor(DoctorName, Email)
    SELECT DISTINCT inserted.DoctorName, inserted.DoctorEmail FROM inserted 
    WHERE NOT EXISTS(SELECT d.Email FROM Doctor as d
						WHERE d.Email = inserted.DoctorEmail)

    INSERT INTO Specialization(SpecDescription, doctor_id)
        SELECT ins.SpecializationDescription, d.DoctorID
        FROM Doctor AS d
		INNER JOIN inserted AS ins 
		ON d.Email = ins.DoctorEmail
GO

INSERT INTO SpecView (SpecializationDescription, DoctorName, DoctorEmail)
VALUES ('врач-терапевт', 'Куцзнецов Кузя Кузьмич', 'test1@gmail.com'),
	('врач-хирург','Васнецов Василий Васильевич', 'test2@gmail.com');

SELECT * FROM Doctor

SELECT * FROM Specialization
GO

--
--	удаление
--
CREATE TRIGGER Delete_SpecView ON SpecView
    INSTEAD OF DELETE
    AS
    DELETE FROM s 
		FROM Specialization as s
		INNER JOIN deleted as del on del.SpecializationDescription = s.SpecDescription
		INNER JOIN Doctor as d on d.Email = del.DoctorEmail
    WHERE s.Doctor_id = d.DoctorID
	

	DELETE FROM Doctor WHERE DoctorName IN (
		SELECT del.DoctorName
		FROM deleted as del
		INNER JOIN Doctor as d
		ON d.Email = del.DoctorEmail)
GO

DELETE FROM SpecView WHERE SpecView.DoctorEmail = 'test1@gmail.com'

SELECT * FROM Doctor
SELECT * FROM Specialization
GO

--
--	обновление
--
CREATE TRIGGER Update_SpecView ON SpecView
	INSTEAD OF UPDATE
	AS
	IF UPDATE(SpecializationDescription)
		BEGIN
			UPDATE Specialization
			SET SpecDescription = inserted.SpecializationDescription FROM
			Doctor as d 
			INNER JOIN Specialization as s ON s.doctor_id = d.DoctorID
			INNER JOIN inserted ON inserted.DoctorEmail = d.Email
			INNER JOIN deleted ON deleted.DoctorEmail = d.Email
			WHERE SpecID = s.SpecID AND SpecDescription = deleted.SpecializationDescription
		END
	IF UPDATE(DoctorName)
		BEGIN
			UPDATE Doctor
			SET DoctorName = inserted.DoctorName FROM inserted WHERE Doctor.Email = inserted.DoctorEmail
		END
	IF UPDATE(DoctorEmail)
		BEGIN
			RAISERROR ('YOU ARE NOT ALLOWED TO CHANGE UNIQUE FIELD "Doctor.Email" VIA SpecView', 16, -1, 'Update_SpecView');
			ROLLBACK
		END
GO

--raiserror
--UPDATE SpecView set SpecView.DoctorEmail = 'badtest@gmail.com' WHERE SpecView.SpecializationDescription = 'Врач-хирург'


UPDATE SpecView set SpecView.SpecializationDescription = 'врач-офтальмолог' WHERE SpecView.DoctorEmail = 'test2@gmail.com'
UPDATE SpecView set SpecView.DoctorName = 'Степан Степанович' WHERE SpecView.SpecializationDescription = 'врач-хирург'

UPDATE Doctor SET Doctor.Email = 'step1@mail.ru' WHERE DoctorName = 'Степан Степанович'

SELECT * FROM Doctor
SELECT * FROM Specialization
SELECT * FROM SpecView
GO