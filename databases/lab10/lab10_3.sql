-- 2 Накладываемые блокировки исследовать с
-- использованием sys.dm_tran_locks

USE lab10;
GO

-- 1)
/*
BEGIN TRANSACTION;
	UPDATE Book SET PublishingHouse = 'Просвещение' WHERE BookID = 5;
	WAITFOR DELAY '00:00:05';
	-- добавить роллбэк для откатки (ROLLBACK;)
	
	SELECT * FROM Book;
	SELECT * FROM sys.dm_tran_locks;
    COMMIT TRANSACTION
GO
*/

-- 2)
/*
BEGIN TRANSACTION;
	UPDATE Book SET PublishingHouse = 'МОРОЗКО' WHERE BookID = 5;
	WAITFOR DELAY '00:00:05';
	
	SELECT * FROM Book;
	SELECT * FROM sys.dm_tran_locks;
    COMMIT TRANSACTION
GO
*/

-- 3)
/*
BEGIN TRANSACTION;
	UPDATE Book SET PublishingHouse = 'БББ' WHERE BookID = 5;
	INSERT INTO Book(ISBN, Title, Genre, PublishingYear, PublishingHouse, Price) 
	VALUES ('978-5-17-092624-4', 'Двеннадцать стульев', 'Роман', '2020', 'АСТ', 298);
	SELECT * FROM sys.dm_tran_locks;
    COMMIT TRANSACTION
GO
*/

-- 4)
/*
BEGIN TRANSACTION;
	UPDATE Book SET PublishingHouse = 'БББ' WHERE BookID = 5;
	INSERT INTO Book(ISBN, Title, Genre, PublishingYear, PublishingHouse, Price) 
	VALUES ('978-5-699-50605-7', 'Маленький принц', 'Сказка', '2011', 'Эксмо', 600);
	SELECT * FROM sys.dm_tran_locks;
    COMMIT TRANSACTION
GO
*/