-- 2 ������������� ���������� ����������� �
-- �������������� sys.dm_tran_locks

USE lab10;
GO

-- 1)
/*
BEGIN TRANSACTION;
	UPDATE Book SET PublishingHouse = '�����������' WHERE BookID = 5;
	WAITFOR DELAY '00:00:05';
	-- �������� ������� ��� ������� (ROLLBACK;)
	
	SELECT * FROM Book;
	SELECT * FROM sys.dm_tran_locks;
    COMMIT TRANSACTION
GO
*/

-- 2)
/*
BEGIN TRANSACTION;
	UPDATE Book SET PublishingHouse = '�������' WHERE BookID = 5;
	WAITFOR DELAY '00:00:05';
	
	SELECT * FROM Book;
	SELECT * FROM sys.dm_tran_locks;
    COMMIT TRANSACTION
GO
*/

-- 3)
/*
BEGIN TRANSACTION;
	UPDATE Book SET PublishingHouse = '���' WHERE BookID = 5;
	INSERT INTO Book(ISBN, Title, Genre, PublishingYear, PublishingHouse, Price) 
	VALUES ('978-5-17-092624-4', '����������� �������', '�����', '2020', '���', 298);
	SELECT * FROM sys.dm_tran_locks;
    COMMIT TRANSACTION
GO
*/

-- 4)
/*
BEGIN TRANSACTION;
	UPDATE Book SET PublishingHouse = '���' WHERE BookID = 5;
	INSERT INTO Book(ISBN, Title, Genre, PublishingYear, PublishingHouse, Price) 
	VALUES ('978-5-699-50605-7', '��������� �����', '������', '2011', '�����', 600);
	SELECT * FROM sys.dm_tran_locks;
    COMMIT TRANSACTION
GO
*/