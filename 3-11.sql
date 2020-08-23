CREATE DATABASE lab11_trigger
GO
USE Northwind
GO

SELECT CustomerID, CompanyName, ContactName, ContactTitle, Address, City, Phone,Fax
INTO Lab11.dbo.Customers FROM Northwind.dbo.Customers
GO
USE lab11_trigger
GO
SELECT * FROM Customers

CREATE TRIGGER checkCustomerOnInsert
ON Customers
FOR INSERT 
AS 
    BEGIN 
	    if EXISTS (SELECT * FROM inserted WHERE Phone = NULL )
		BEGIN 
		 PRINT 'không thể chèn vào dữ liệu';
		 ROLLBACK TRANSACTION;
		 END
	END
GO

--2. Tạo một UPDATE trigger với tên là checkCustomerContryOnUpdate cho bảng Customers.
--Trigger này sẽ không cho phép người dùng thay đổi thông tin của những khách hàng mà có tên
--nước là France.

CREATE TRIGGER checkCustomerContryOnUpdate
ON Customers
FOR UPDATE
AS 
   BEGIN 
      Update Customers SET City='London' 
	  BEGIN 
	     PRINT 'không được thay đổi thông tin khách hàng';
		 ROLLBACK TRANSACTION;
	  END
	END
GO
UPDATE Customers SET CompanyName = 'Around the Urn' WHERE CustomerID='AROUT'
select CustomerID,CompanyName
from dbo.Customers where City = 'London'


--Chèn thêm một cột mới có tên là Active vào bảng Customers và cài đặt giá trị mặc định cho nó là
--1. Tạo một trigger có tên là checkCustomerInsteadOfDelete nhằm chuyển giá trị của cột Active
--thành 0 thay vì tiến hành xóa dữ liệu thực sự ra khỏi bảng khi thao tác xóa dữ liệu được tiến hành. 
SELECT *
from Customers
ALTER TABLE Customers 
ADD Active int NOT NULL DEFAULT (1)

CREATE TRIGGER checkCustomerInsteadOfDelete
ON Customers
FOR DELETE
AS 
    BEGIN 
	 UPDATE Customers Set Active = 0 WHERE CustomerID IN(SELECT CustomerID FROM deleted)
	 ROLLBACK TRANSACTION;
	END
GO

SELECT MAX(checkCustomerContryOnUpdate)
    FROM Customers