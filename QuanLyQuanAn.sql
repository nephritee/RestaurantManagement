﻿CREATE DATABASE QuanLyQuanAn
GO

USE QuanLyQuanAn
GO

-- Table
-- Food
-- FoodCategory
-- Account
-- Bill
-- BillInfo

CREATE TABLE TableFood
(
	id INT IDENTITY PRIMARY KEY,
	name NVARCHAR(100) NOT NULL DEFAULT N'Bàn chưa có tên',
	status NVARCHAR(100) NOT NULL DEFAULT N'Trống' --- Có người || Trống
)
GO

CREATE TABLE Account
(
	UserName NVARCHAR(100) PRIMARY KEY,
	DisplayName NVARCHAR(100) NOT NULL DEFAULT N'Khách hàng',
	PassWord NVARCHAR(1000) NOT NULL DEFAULT 0,
	Type INT NOT NULL DEFAULT 0 -- 1 là admin && 0 là staff
)
GO


CREATE TABLE FoodCategory
(
	id INT IDENTITY PRIMARY KEY,
	name NVARCHAR(100) NOT NULL DEFAULT N'Chưa đặt tên'
)
GO

CREATE TABLE Food
(
	id INT IDENTITY PRIMARY KEY,
	name NVARCHAR(100) NOT NULL DEFAULT N'Chưa có tên',
	idCategory INT NOT NULL,
	price FLOAT NOT NULL DEFAULT 0,

	FOREIGN KEY (idCategory) REFERENCES dbo.FoodCategory(id)
)
GO

CREATE TABLE Bill
(
	id INT IDENTITY PRIMARY KEY,
	DateCheckIn DATE NOT NULL DEFAULT GETDATE(),
	DateCheckOut DATE,
	idTable INT NOT NULL,
	status INT NOT NULL DEFAULT 0, -- 1: Đã thanh toán, 0: Chưa thanh toán

	FOREIGN KEY (idTable) REFERENCES dbo.TableFood(id)
)
GO

CREATE TABLE BillInfo
(
	id INT IDENTITY PRIMARY KEY,
	idBill INT NOT NULL,
	idFood INT NOT NULL,
	count INT NOT NULL DEFAULT 0,

	FOREIGN KEY (idBill) REFERENCES dbo.Bill(id),
	FOREIGN KEY (idFood) REFERENCES dbo.Food(id)
)
GO

INSERT INTO dbo.Account
		(	UserName,
			DisplayName,
			PassWord,
			TYPE
		)
VALUES ( N'tintin5b',
		 N'Nephrite',
		 N'123',
		 1
		)

INSERT INTO dbo.Account
		(	UserName,
			DisplayName,
			PassWord,
			TYPE
		)
VALUES ( N'staff',
		 N'Shenronis',
		 N'123',
		 0
		)
GO

CREATE PROC USP_GetAccountByUserName
@userName nvarchar(100)
AS
BEGIN
	SELECT * FROM dbo.Account WHERE UserName = @userName
END
GO

EXEC dbo.USP_GetAccountByUserName @userName = N'Khách hàng' -- nvarchar(100)

CREATE PROC USP_Login
@userName nvarchar(100), @passWord nvarchar(100)
AS
Begin
	SELECT * FROM dbo.Account WHERE UserName = @userName AND PassWord = @passWord
END
GO

--thêm bàn
DECLARE @i INT = 0
WHILE @i <= 15
BEGIN
	INSERT dbo.TableFood (name) VALUES (N'Bàn ' + CAST(@i AS NVARCHAR(100)))
	SET @i = @i + 1
END
GO

CREATE PROC USP_GetTableList
AS SELECT * FROM dbo.TableFood
GO

UPDATE dbo.TableFood SET STATUS = N'Có người' where id = 7
GO

EXEC dbo.USP_GetTableList
GO

--thêm Category
INSERT dbo.FoodCategory
		( name )
VALUES	( N'Hải sản') -- name - nvarchar(100)

INSERT dbo.FoodCategory
		( name )
VALUES	( N'Nông sản')

INSERT dbo.FoodCategory
		( name )
VALUES	( N'Lâm sản')

INSERT dbo.FoodCategory
		( name )
VALUES	( N'Nước uống')

--thêm món ăn
INSERT dbo.Food
		( name, idCategory, price )
VALUES	( N'Mực nướng', 1, 50000)

INSERT dbo.Food
		( name, idCategory, price )
VALUES	( N'Nghêu hấp xả', 1, 50000)

INSERT dbo.Food
		( name, idCategory, price )
VALUES	( N'Bò beefsteak', 2, 75000)

INSERT dbo.Food
		( name, idCategory, price )
VALUES	( N'Cơm gà xối mỡ', 2, 60000)

INSERT dbo.Food
		( name, idCategory, price )
VALUES	( N'Coca', 4, 10000)

INSERT dbo.Food
		( name, idCategory, price )
VALUES	( N'Coffe', 4, 15000)

INSERT dbo.Food
		( name, idCategory, price )
VALUES	( N'Cơm chiên dương châu', 3, 50000)

INSERT dbo.Food
		( name, idCategory, price )
VALUES	(N'Cơm hấp lá khoai', 3, 45000)

--thêm bill
INSERT dbo.Bill
		(DateCheckIn,
		 DateCheckOut,
		 idTable,
		 status
		)
VALUES	(GETDATE(),
		 NULL,
		 1,
		 0
		)
				
INSERT dbo.Bill
		(DateCheckIn,
		 DateCheckOut,
		 idTable,
		 status
		)
VALUES	(GETDATE(),
		 NULL,
		 2,
		 0
		)

INSERT dbo.Bill
		(DateCheckIn,
		 DateCheckOut,
		 idTable,
		 status
		)
VALUES	(GETDATE(),
		 GETDATE(),
		 3,
		 1
		)

--thêm bill info
INSERT dbo.BillInfo
	   ( idBill, idFood, count )
VALUES ( 1, 1, 2)

INSERT dbo.BillInfo
	   ( idBill, idFood, count )
VALUES ( 1, 4, 1)

INSERT dbo.BillInfo
	   ( idBill, idFood, count )
VALUES ( 2, 2, 4)

INSERT dbo.BillInfo
	   ( idBill, idFood, count )
VALUES ( 3, 4, 2)
GO

ALTER PROC USP_InsertBill
@idTable INT
AS
BEGIN
	INSERT dbo.Bill
		( DateCheckIn,
		  DateCheckOut,
		  idTable,
		  status,
		  discount
		)
	VALUES 
		( GETDATE(),
		  NULL,
		  @idTable,
		  0,
		  0
		)
END
GO

ALTER TABLE dbo.Bill
ADD discount INT

UPDATE dbo.Bill SET discount = 0
GO

CREATE PROC USP_InsertBillInfo
@idBill INT, @idFood INT, @count INT
AS
BEGIN
	DECLARE @isExitsBillInfo INT
	DECLARE @foodCount INT = 1

	SELECT @isExitsBillInfo = id, @foodCount = b.count 
	FROM dbo.BillInfo AS b
	WHERE idBill = @idBill AND idFood = @idFood

	IF (@isExitsBillInfo > 0)
	BEGIN
		DECLARE @newCount INT = @foodCount + @count
		IF (@newCount > 0)
			UPDATE dbo.BillInfo SET count = @foodCount + @count WHERE idFood = @idFood
		ELSE
			DELETE dbo.BillInfo WHERE idBill = @idBill AND idFood = @idFood
	END
	ELSE
	BEGIN
		INSERT dbo.BillInfo
			 ( idBill, idFood, count )
		VALUES	 ( @idBill, @idFood, @count)
	END
END
GO

DELETE dbo.BillInfo

DELETE dbo.Bill

CREATE TRIGGER UTG_UpdateBillInfo
ON dbo.BillInfo FOR INSERT, UPDATE
AS
BEGIN
	DECLARE @idBill INT
	
	SELECT @idBill = idBill FROM Inserted
	
	DECLARE @idTable INT
	
	SELECT @idTable = idTable FROM dbo.Bill WHERE id = @idBill AND status = 0	
	
	DECLARE @count INT
	SELECT	@count = COUNT(*) FROM dbo.BillInfo WHERE idBill = @idBill

	IF (@count >0)
	BEGIN

		PRINT @idTable
		PRINT @idBill
		PRINT @count
		
		UPDATE dbo.TableFood SET status = N'Có người' WHERE id = @idTable
	END

	ELSE
	BEGIN

		PRINT @idTable
		PRINT @idBill
		PRINT @count

		UPDATE dbo.TableFood SET status = N'Trống' WHERE id = @idTable
	END
END
GO

CREATE TRIGGER UTG_UpdateBill
ON dbo.Bill FOR UPDATE
AS
BEGIN
	DECLARE @idBill INT
	
	SELECT @idBill = id FROM Inserted	
	
	DECLARE @idTable INT
	
	SELECT @idTable = idTable FROM dbo.Bill WHERE id = @idBill
	
	DECLARE @count int = 0
	
	SELECT @count = COUNT(*) FROM dbo.Bill WHERE idTable = @idTable AND status = 0
	
	IF (@count = 0)
		UPDATE dbo.TableFood SET status = N'Trống' WHERE id = @idTable
END
GO

CREATE PROC USP_SwitchTable
@idTable1 INT, @idTable2 INT
AS
BEGIN
	
	DECLARE @idFirstBill INT
	DECLARE @idSecondBill INT

	DECLARE @isFirstTableEmpty INT = 1
	DECLARE @isSecondTableEmpty INT = 1

	SELECT @idSecondBill = id FROM dbo.Bill WHERE idTable = @idTable2 AND status = 0
	SELECT @idFirstBill = id FROM dbo.Bill WHERE idTable = @idTable1 AND status = 0

	PRINT @idFirstBill
	PRINT @idSecondBill
	PRINT '----------'

	IF (@idFirstBill IS NULL)
	BEGIN
		PRINT '000001'
		INSERT dbo.Bill
				(  DateCheckIn,
				   DateCheckOut,
				   idTable,
				   status
				)
		VALUES	(  GETDATE(),
				   NULL,
				   @idTable1,
				   0
				)
		SELECT @idFirstBill = MAX(id) FROM dbo.Bill WHERE idTable = @idTable1 AND status = 0
		
	END

	SELECT @isFirstTableEmpty = COUNT(*) FROM dbo.BillInfo WHERE idBill = @idFirstBill
	
	PRINT @idFirstBill
	PRINT @idSecondBill
	PRINT '----------'

	IF (@idSecondBill IS NULL)
	BEGIN
		PRINT '000002'
		INSERT dbo.Bill
				(  DateCheckIn,
				   DateCheckOut,
				   idTable,
				   status
				)
		VALUES	(  GETDATE(),
				   NULL,
				   @idTable2,
				   0
				)
		SELECT @idSecondBill = MAX(id) FROM dbo.Bill WHERE idTable = @idTable2 AND status = 0
	END

	SELECT @isSecondTableEmpty = COUNT(*) FROM dbo.BillInfo WHERE idBill = @idSecondBill

	PRINT @idFirstBill
	PRINT @idSecondBill
	PRINT '----------'

	SELECT id INTO IDBillInfoTable FROM dbo.BillInfo WHERE idBill = @idSecondBill
	
	UPDATE dbo.BillInfo SET idBill = @idSecondBill WHERE idBill = @idFirstBill

	UPDATE dbo.BillInfo SET idBill = @idFirstBill WHERE id IN (SELECT * FROM IDBillInfoTable)

	DROP TABLE IDBillInfoTable

	IF (@isFirstTableEmpty = 0)
		UPDATE dbo.TableFood SET status = N'Trống' WHERE id = @idTable2

	IF (@isSecondTableEmpty = 0)
		UPDATE dbo.TableFood SET status = N'Trống' WHERE id = @idTable1
END
GO

ALTER PROC USP_GetListBillByDate
@checkIn date, @checkOut date
AS
BEGIN
	SELECT t.name AS [Tên bàn], b.totalPrice AS [Tổng tiền], DateCheckIn AS [Ngày vào], DateCheckOut AS [Ngày ra], discount AS [Giảm giá]
	FROM dbo.Bill AS b, dbo.TableFood AS t
	WHERE DateCheckIn >= @checkIn AND DateCheckOut <= @checkOut AND b.status = 1
	AND t.id = b.idTable
END
GO

CREATE PROC USP_UpdateAccount
@userName NVARCHAR(100), @displayName NVARCHAR(100), @passWord NVARCHAR(100), @newPassWord NVARCHAR (100)
AS
BEGIN
	DECLARE @isRightPass INT = 0

	SELECT @isRightPass = COUNT(*) FROM dbo.Account WHERE UserName = @userName AND PassWord = @passWord

	IF (@isRightPass = 1)
	BEGIN
		IF (@newPassWord = NULL OR @newPassWord = '')
		BEGIN
			UPDATE dbo.Account SET DisplayName = @displayName WHERE UserName = @userName
		END
		ELSE
			UPDATE dbo.Account SET DisplayName = @displayName, PassWord = @newPassWord WHERE UserName = @userName
	END
END
GO

CREATE TRIGGER UTG_DeleteBillInfo
ON dbo.BillInfo FOR DELETE
AS 
BEGIN
	DECLARE @idBillInfo INT
	DECLARE @idBill INT
	SELECT @idBillInfo = id, @idBill = Deleted.idBill FROM Deleted
	
	DECLARE @idTable INT
	SELECT @idTable = idTable FROM dbo.Bill WHERE id = @idBill
	
	DECLARE @count INT = 0
	
	SELECT @count = COUNT(*) FROM dbo.BillInfo AS bi, dbo.Bill AS b WHERE b.id = bi.idBill AND b.id = @idBill AND b.status = 0
	
	IF (@count = 0)
		UPDATE dbo.TableFood SET status = N'Trống' WHERE id = @idTable
END
GO

CREATE FUNCTION [dbo].[fuConvertToUnsign1] ( @strInput NVARCHAR(4000) ) RETURNS NVARCHAR(4000) AS BEGIN IF @strInput IS NULL RETURN @strInput IF @strInput = '' RETURN @strInput DECLARE @RT NVARCHAR(4000) DECLARE @SIGN_CHARS NCHAR(136) DECLARE @UNSIGN_CHARS NCHAR (136) SET @SIGN_CHARS = N'ăâđêôơưàảãạáằẳẵặắầẩẫậấèẻẽẹéềểễệế ìỉĩịíòỏõọóồổỗộốờởỡợớùủũụúừửữựứỳỷỹỵý ĂÂĐÊÔƠƯÀẢÃẠÁẰẲẴẶẮẦẨẪẬẤÈẺẼẸÉỀỂỄỆẾÌỈĨỊÍ ÒỎÕỌÓỒỔỖỘỐỜỞỠỢỚÙỦŨỤÚỪỬỮỰỨỲỶỸỴÝ' +NCHAR(272)+ NCHAR(208) SET @UNSIGN_CHARS = N'aadeoouaaaaaaaaaaaaaaaeeeeeeeeee iiiiiooooooooooooooouuuuuuuuuuyyyyy AADEOOUAAAAAAAAAAAAAAAEEEEEEEEEEIIIII OOOOOOOOOOOOOOOUUUUUUUUUUYYYYYDD' DECLARE @COUNTER int DECLARE @COUNTER1 int SET @COUNTER = 1 WHILE (@COUNTER <=LEN(@strInput)) BEGIN SET @COUNTER1 = 1 WHILE (@COUNTER1 <=LEN(@SIGN_CHARS)+1) BEGIN IF UNICODE(SUBSTRING(@SIGN_CHARS, @COUNTER1,1)) = UNICODE(SUBSTRING(@strInput,@COUNTER ,1) ) BEGIN IF @COUNTER=1 SET @strInput = SUBSTRING(@UNSIGN_CHARS, @COUNTER1,1) + SUBSTRING(@strInput, @COUNTER+1,LEN(@strInput)-1) ELSE SET @strInput = SUBSTRING(@strInput, 1, @COUNTER-1) +SUBSTRING(@UNSIGN_CHARS, @COUNTER1,1) + SUBSTRING(@strInput, @COUNTER+1,LEN(@strInput)- @COUNTER) BREAK END SET @COUNTER1 = @COUNTER1 +1 END SET @COUNTER = @COUNTER +1 END SET @strInput = replace(@strInput,' ','-') RETURN @strInput END

ALTER PROC USP_GetListBillByDateAndPage
@checkIn date, @checkOut date, @page INT
AS
BEGIN
	DECLARE @pageRows INT = 10
	DECLARE @selectRows INT = @pageRows
	DECLARE @exceptRows INT = (@page - 1) * @pageRows
	
	;WITH BillShow AS (SELECT b.id, t.name AS [Tên bàn], b.totalPrice AS [Tổng tiền], DateCheckIn AS [Ngày vào], DateCheckOut AS [Ngày ra], discount AS [Giảm giá]
	FROM dbo.Bill AS b, dbo.TableFood AS t
	WHERE DateCheckIn >= @checkIn AND DateCheckOut <= @checkOut AND b.status = 1
	AND t.id = b.idTable)

	SELECT TOP (@selectRows) * FROM BillShow WHERE id NOT IN (SELECT TOP (@exceptRows) id FROM BillShow)

END
GO

CREATE PROC USP_GetNumBillByDate
@checkIn date, @checkOut date
AS
BEGIN
	SELECT count (*)
	FROM dbo.Bill AS b, dbo.TableFood AS t
	WHERE DateCheckIn >= @checkIn AND DateCheckOut <= @checkOut AND b.status = 1
	AND t.id = b.idTable
END
GO