CREATE DATABASE QuanLyQuanAn
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
WHILE @i <= 35
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

CREATE PROC USP_InsertBill
@idTable INT
AS
BEGIN
	INSERT dbo.Bill
		( DateCheckIn,
		  DateCheckOut,
		  idTable,
		  status
		)
	VALUES 
		( GETDATE(),
		  NULL,
		  @idTable,
		  0
		)
END
GO

ALTER PROC USP_InsertBillInfo
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

SELECT f.name, bi.count, f.price, f.price*bi.count AS totalPrice FROM dbo.BillInfo AS bi, dbo.Bill AS b, dbo.Food AS f
WHERE bi.idBill = b.id AND bi.idFood = f.id AND b.idTable = 3


SELECT MAX(id) FROM dbo.Bill

SELECT * FROM dbo.Bill
SELECT * FROM dbo.BillInfo
SELECT * FROM dbo.Food
SELECT * FROM dbo.FoodCategory


SELECT * FROM Food WHERE idCategory = 4