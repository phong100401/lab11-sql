CREATE DATABASE Lab13
GO
USE AdventureWorks2012
GO

SELECT ProductID,Name,Color INTO Lab13.dbo.Product FROM Production.Product
GO
USE Lab13
GO

SELECT * FROM Product
CREATE TRIGGER UpdateProduct
ON Product
FOR UPDATE
AS
	BEGIN
		IF(UPDATE(Name))
		BEGIN
			PRINT'Khong duoc phep thay doi ten san pham';
			ROLLBACK TRANSACTION;
		END
	END

UPDATE Product SET Name = 'Cocacola' WHERE ProductID = 1